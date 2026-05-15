/**
 * Celestial Deep - Quran Streaming App
 * Starfield Animation & Interactive Effects
 */

class Starfield {
  constructor(canvasId, starCount = 150) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext('2d');
    this.stars = [];
    this.starCount = starCount;
    this.mouseX = 0;
    this.mouseY = 0;
    
    this.init();
    this.animate();
    this.setupEventListeners();
  }
  
  init() {
    this.resize();
    this.createStars();
  }
  
  resize() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }
  
  createStars() {
    this.stars = [];
    for (let i = 0; i < this.starCount; i++) {
      this.stars.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        size: Math.random() * 2 + 0.5,
        opacity: Math.random() * 0.8 + 0.2,
        twinkleSpeed: Math.random() * 0.02 + 0.005,
        twinklePhase: Math.random() * Math.PI * 2,
        color: this.getStarColor(),
        driftX: (Math.random() - 0.5) * 0.1,
        driftY: (Math.random() - 0.5) * 0.1
      });
    }
  }
  
  getStarColor() {
    const colors = [
      { r: 255, g: 249, b: 196 },  // Star gold
      { r: 232, g: 232, b: 232 },  // Moon white
      { r: 200, g: 190, b: 255 },  // Light nebula tint
      { r: 255, g: 255, b: 255 }   // Pure white
    ];
    return colors[Math.floor(Math.random() * colors.length)];
  }
  
  drawStar(star, time) {
    const twinkle = Math.sin(time * star.twinkleSpeed + star.twinklePhase);
    const currentOpacity = star.opacity * (0.6 + twinkle * 0.4);
    
    this.ctx.beginPath();
    this.ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
    this.ctx.fillStyle = `rgba(${star.color.r}, ${star.color.g}, ${star.color.b}, ${currentOpacity})`;
    this.ctx.fill();
    
    // Glow effect for brighter stars
    if (star.size > 1.5) {
      this.ctx.beginPath();
      this.ctx.arc(star.x, star.y, star.size * 2, 0, Math.PI * 2);
      const glowOpacity = currentOpacity * 0.3;
      this.ctx.fillStyle = `rgba(${star.color.r}, ${star.color.g}, ${star.color.b}, ${glowOpacity})`;
      this.ctx.fill();
    }
  }
  
  updateStars() {
    this.stars.forEach(star => {
      star.x += star.driftX;
      star.y += star.driftY;
      
      // Wrap around screen
      if (star.x < 0) star.x = this.canvas.width;
      if (star.x > this.canvas.width) star.x = 0;
      if (star.y < 0) star.y = this.canvas.height;
      if (star.y > this.canvas.height) star.y = 0;
    });
  }
  
  animate() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    const time = Date.now();
    this.stars.forEach(star => this.drawStar(star, time));
    this.updateStars();
    
    requestAnimationFrame(() => this.animate());
  }
  
  setupEventListeners() {
    window.addEventListener('resize', () => {
      this.resize();
      this.createStars();
    });
    
    document.addEventListener('mousemove', (e) => {
      this.mouseX = e.clientX;
      this.mouseY = e.clientY;
    });
  }
}

// Smooth scrolling for anchor links
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
}

// Intersection Observer for scroll animations
function initScrollAnimations() {
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);
  
  document.querySelectorAll('.pillar-card, .surah-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
    observer.observe(el);
  });
}

// Add animation class styles
const style = document.createElement('style');
style.textContent = `
  .animate-in {
    opacity: 1 !important;
    transform: translateY(0) !important;
  }
`;
document.head.appendChild(style);

// Initialize everything when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  // Initialize starfield
  new Starfield('starfield', 150);
  
  // Initialize smooth scrolling
  initSmoothScroll();
  
  // Initialize scroll animations
  setTimeout(initScrollAnimations, 100);
  
  // Add parallax effect to floating elements
  let ticking = false;
  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        const scrollY = window.scrollY;
        const moon = document.querySelector('.moon-float');
        if (moon) {
          moon.style.transform = `translateY(${scrollY * 0.3}px)`;
        }
        ticking = false;
      });
      ticking = true;
    }
  });
});
