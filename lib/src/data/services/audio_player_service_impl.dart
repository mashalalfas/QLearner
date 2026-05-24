import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart' as asvc;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:rxdart/rxdart.dart';

import '../../core/services/audio_player_service.dart';

/// AudioPlayerService implementation using just_audio + audio_service.
///
/// Features:
/// - Background playback (lock screen, notification, widget)
/// - Play/pause/seek + position/state streams
/// - Stream from everyayah.com (Alafasy recitation)
/// - Error handling with exponential backoff retry
///
/// NOTE: No DB access from this class — it runs across isolates.
/// Position persistence is handled by the UI layer (main isolate).
class AudioPlayerServiceImpl extends AudioPlayerService {
  final Future<_AudioHandlerImpl> _handlerFuture;

  // Domain streams
  final BehaviorSubject<int> _positionController = BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<String> _surahIdController = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<PlayerState> _stateController = BehaviorSubject<PlayerState>.seeded(
    const PlayerState(isPlaying: false, positionMs: 0, state: PlayerStateEnum.stopped),
  );

  int _consecutiveErrors = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  String _currentSurahId = '';
  bool _isDisposed = false;

  // Shared handler singleton
  static Future<_AudioHandlerImpl>? _sharedHandler;

  factory AudioPlayerServiceImpl.create() {
    final instance = AudioPlayerServiceImpl._();
    instance.initialize();
    return instance;
  }

  AudioPlayerServiceImpl._()
      : _handlerFuture = _getOrCreateHandler();

  static Future<_AudioHandlerImpl> _getOrCreateHandler() async {
    if (_sharedHandler != null) return await _sharedHandler!;
    _sharedHandler = asvc.AudioService.init(
      builder: () => _AudioHandlerImpl(),
      config: asvc.AudioServiceConfig(
        androidNotificationChannelId: 'qlearner.channel',
        androidNotificationChannelName: 'Quran Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        // Keep notification icon from being stripped by R8 resource shrinker.
        androidNotificationIcon: 'mipmap/ic_launcher',
        notificationColor: const Color(0xFF1A1A1A),
      ),
    );
    return await _sharedHandler!;
  }

  Future<_AudioHandlerImpl> _h() async {
    if (_isDisposed) throw StateError('Service disposed');
    return await _handlerFuture;
  }

  @override
  Future<void> initialize() async {
    if (_isDisposed) return;
    try {
      final h = await _h();

      h.position.listen((pos) {
        if (_isDisposed) return;
        final ms = pos.inMilliseconds;
        _positionController.add(ms);
        _stateController.add(_stateController.value.copyWith(positionMs: ms));
      });

      h.duration.listen((dur) {
        if (_isDisposed || dur == null) return;
        _stateController.add(_stateController.value.copyWith(durationMs: dur.inMilliseconds));
      });

      h.playbackState.listen((state) {
        if (_isDisposed) return;
        final isPlaying = state.playing;
        final ps = state.processingState;
        PlayerStateEnum s;
        if (ps == asvc.AudioProcessingState.ready) {
          s = isPlaying ? PlayerStateEnum.playing : PlayerStateEnum.paused;
        } else if (ps == asvc.AudioProcessingState.completed) {
          s = PlayerStateEnum.completed;
        } else if (ps == asvc.AudioProcessingState.idle) {
          s = PlayerStateEnum.stopped;
        } else if (ps == asvc.AudioProcessingState.loading || ps == asvc.AudioProcessingState.buffering) {
          s = PlayerStateEnum.buffering;
        } else {
          s = PlayerStateEnum.stopped;
        }
        _stateController.add(_stateController.value.copyWith(isPlaying: isPlaying, state: s));
      });

      h.mediaItem.listen((item) {
        if (_isDisposed || item == null) return;
        final id = item.id;
        if (id.isNotEmpty && id != _currentSurahId) {
          _currentSurahId = id;
          _surahIdController.add(id);
        }
      });

      h.playbackState
          .where((s) => s.processingState == asvc.AudioProcessingState.error)
          .listen((_) => _handleError());

    } catch (_) {}
  }

  @override
  Future<void> play(String url, {int? startMs, int? endMs, String? surahName, String? surahArabic}) async {
    if (_isDisposed) return;
    print('[AudioPlayer] play($url, startMs=$startMs)');
    try {
      _consecutiveErrors = 0;

      // Stop any in-flight playback before loading the new surah.
      // Without this, playFromUrl() calls setAudioSource() while the
      // previous just_audio source is still active, which can crash.
      final h = await _h();
      await h.stop();

      final surahId = _extractSurahId(url);

      final item = asvc.MediaItem(
        id: surahId ?? '',
        album: 'Quran',
        title: surahName ?? 'Surah ${surahId ?? 'Unknown'}',
        artist: surahArabic ?? 'Recitation',
        extras: {'url': url, 'startMs': startMs, 'endMs': endMs, 'surahId': surahId},
      );

      print('[AudioPlayer] calling playFromUrl...');
      await h.playFromUrl(url, mediaItem: item, startMs: startMs);
      print('[AudioPlayer] playFromUrl completed');

      // Update _currentSurahId AFTER playFromUrl so the MediaItem listener
      // always fires with the new ID (even when re-loading the same surah).
      if (surahId != null) {
        _currentSurahId = surahId;
        _surahIdController.add(surahId);
      }

      if (startMs != null) await seek(startMs);
    } catch (e) {
      print('[AudioPlayer] ERROR: $e');
      _consecutiveErrors++;
      if (_consecutiveErrors >= _maxRetries) {
        _consecutiveErrors = 0;
      } else {
        await Future.delayed(_retryDelay * _consecutiveErrors);
        if (!_isDisposed) await play(url, startMs: startMs, endMs: endMs);
      }
    }
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    print('[AudioPlayer] pause()');
    try { final h = await _h(); await h.pause(); } catch (e) { print('[AudioPlayer] pause ERROR: $e'); }
  }

  @override
  Future<void> resume() async {
    if (_isDisposed) return;
    print('[AudioPlayer] resume()');
    try { final h = await _h(); await h.play(); } catch (e) { print('[AudioPlayer] resume ERROR: $e'); }
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    try {
      final h = await _h();
      await h.stop();
    } catch (_) {}
  }

  @override
  Future<void> seek(int ms) async {
    if (_isDisposed) return;
    try { final h = await _h(); await h.seek(Duration(milliseconds: ms)); } catch (_) {}
  }

  @override
  Stream<int> get positionStream => _positionController.stream;

  @override
  Stream<PlayerState> get playerStateStream => _stateController.stream;

  @override
  Future<void> setSpeed(double speed) async {
    if (_isDisposed) return;
    try { final h = await _h(); await h.setSpeed(speed); } catch (_) {}
  }

  @override
  Future<void> setRepeatMode(int mode) async {
    if (_isDisposed) return;
    try { final h = await _h(); await h._setLoopMode(mode); } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _positionController.close();
    await _surahIdController.close();
    await _stateController.close();
  }

  Future<void> _handleError() async {
    _consecutiveErrors++;
    if (_consecutiveErrors >= _maxRetries) {
      _consecutiveErrors = 0;
    }
  }

  String? _extractSurahId(String url) {
    try {
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;
      final num = int.tryParse(filename.replaceAll('.mp3', ''));
      if (num != null && num >= 1 && num <= 114) {
        return num.toString().padLeft(3, '0');
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<String> get currentSurahIdStream => _surahIdController.stream;

  @override
  Stream<int> get currentPositionStream => _positionController.stream;

  String get currentSurahId => _currentSurahId;
}

/// AudioHandler implementation for audio_service.
class _AudioHandlerImpl extends asvc.BaseAudioHandler {
  final ja.AudioPlayer _player = ja.AudioPlayer();

  // Broadcast subjects for position/duration
  final _positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _durationSubject = BehaviorSubject<Duration?>.seeded(null);

  _AudioHandlerImpl() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.positionStream.pipe(_positionSubject);
    _player.durationStream.pipe(_durationSubject);
  }

  Stream<Duration> get position => _positionSubject.stream;
  Stream<Duration?> get duration => _durationSubject.stream;

  asvc.PlaybackState _transformEvent(ja.PlaybackEvent event) {
    return asvc.PlaybackState(
      controls: [
        asvc.MediaControl.rewind,
        if (_player.playing) asvc.MediaControl.pause else asvc.MediaControl.play,
        asvc.MediaControl.fastForward,
      ],
      systemActions: const<asvc.MediaAction>{},
      playing: _player.playing,
      processingState: const {
        ja.ProcessingState.idle: asvc.AudioProcessingState.idle,
        ja.ProcessingState.loading: asvc.AudioProcessingState.loading,
        ja.ProcessingState.buffering: asvc.AudioProcessingState.buffering,
        ja.ProcessingState.ready: asvc.AudioProcessingState.ready,
        ja.ProcessingState.completed: asvc.AudioProcessingState.completed,
      }[_player.processingState]!,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> playFromUrl(String url, {required asvc.MediaItem mediaItem, int? startMs}) async {
    // Stop any current playback before switching sources to prevent a race
    // condition in just_audio where setAudioSource is called while a previous
    // source is still active.
    await _player.stop();
    // Force a notification refresh: clear the media item first so
    // audio_service always sees a genuine change when we set the new one.
    // (Adding the same MediaItem reference again would be a no-op.)
    this.mediaItem.add(null);
    this.mediaItem.add(mediaItem);

    // Push the new queue entry so lock-screen controls reflect it.
    this.queue.add([mediaItem]);

    final source = ja.AudioSource.uri(Uri.parse(url), tag: mediaItem);
    await _player.setAudioSource(source);
    if (startMs != null) {
      await _player.seek(Duration(milliseconds: startMs));
    }
    await _player.play();
  }

  @override Future<void> play() => _player.play();
  @override Future<void> pause() => _player.pause();
  @override Future<void> stop() async { await _player.stop(); }
  @override Future<void> seek(Duration position) => _player.seek(position);
  @override Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> _setLoopMode(int mode) async {
    switch (mode) {
      case 0:
        _player.setLoopMode(ja.LoopMode.off);
        break;
      case 1:
        _player.setLoopMode(ja.LoopMode.one);
        break;
      case 2:
        _player.setLoopMode(ja.LoopMode.all);
        break;
      default:
        _player.setLoopMode(ja.LoopMode.off);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(asvc.AudioServiceShuffleMode mode) async {
    await _player.setShuffleModeEnabled(mode == asvc.AudioServiceShuffleMode.all);
  }

  @override Future<void> skipToNext() => _player.seekToNext();
  @override Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    final seq = _player.sequence;
    if (seq != null && index >= 0 && index < seq.length) {
      await _player.seek(Duration.zero, index: index);
    }
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> fastForward() async {
    final cur = _player.position;
    await _player.seek(cur + const Duration(seconds: 10));
  }

  @override
  Future<void> rewind() async {
    final cur = _player.position;
    await _player.seek(cur - const Duration(seconds: 10));
  }

  @override
  Future<void> click([asvc.MediaButton button = asvc.MediaButton.media]) async {
    switch (button) {
      case asvc.MediaButton.media:
        if (_player.playing) pause(); else play();
        break;
      case asvc.MediaButton.next:
        skipToNext();
        break;
      case asvc.MediaButton.previous:
        skipToPrevious();
        break;
    }
  }

  Future<void> setRating(asvc.Rating rating, [Map<String, dynamic>? extras]) async {}
}
