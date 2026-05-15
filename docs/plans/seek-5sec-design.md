# Seek ±5s Design Spec

## Problem
No quick-skip buttons on player screen; user must drag seek bar or use hardware buttons.

## Solution
Add two small ±5-second seek buttons flanking the time display row inside `_PlayerSeekBar`.

## Design bullets (≤15)

- Two new StatelessWidget classes: `_SeekBack5Button` and `_SeekForward5Button`
- Icons: `Icons.replay_5` / `Icons.forward_5` (Material Icons)
- Visual style: 32×32 icon, 40×40 touch target, semi-transparent gold (`AppColors.goldMuted.withAlpha(120)`), circular with `InkWell` ripple
- Position: inside `_PlayerSeekBar`'s time-row `Row`, flanking the position/duration `Text` widgets (back-5 on left, forward-5 on right)
- Visibility: hidden (`const SizedBox.shrink()`) when `positionAsync` is loading / no position data yet
- Behavior: calls `audioPlayer.seek(positionMs ± 5000)` via the existing `onSeek` callback
- Boundary guards: clamp result to `[0, durationMs]` — no negative seek, no past-end seek
- Use `AudioPlayerService.seek(int positionMs)` signature (already in service)
- No change to any other file; no new dependencies
- Haptic feedback: `HapticFeedback.lightImpact()` on tap
- Disabled opacity (80% transparent gold) when boundary would be hit (e.g. at t=0, back button dimmed)
- Button order: [Back5] [position label] [duration label] [Forward5]
- Same gold color family as existing player UI
