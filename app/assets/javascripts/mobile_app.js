// Mobile App JavaScript voor Hardlopen met Virgil
// Deze code voegt app-achtige functionaliteit toe

document.addEventListener('DOMContentLoaded', function() {
  // Force bottom navigation to be visible on mobile
  const bottomNav = document.querySelector('.app-bottom-nav');
  const topMenu = document.querySelector('.theme-menu');
  
  if (bottomNav) {
    // Check if mobile device
    const isMobile = window.innerWidth <= 768 || /Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    
    if (isMobile) {
      bottomNav.style.display = 'flex';
      bottomNav.style.visibility = 'visible';
      bottomNav.style.opacity = '1';
      console.log('Bottom navigation enabled for mobile device');
    }
  }
  
  // Force top menu to be visible on desktop
  if (topMenu) {
    const isDesktop = window.innerWidth > 768;
    if (isDesktop) {
      topMenu.style.display = 'block';
      topMenu.style.visibility = 'visible';
      topMenu.style.opacity = '1';
      console.log('Top menu enabled for desktop');
    }
  }

  // Service Worker registratie
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js')
      .then(function(registration) {
        console.log('Service Worker geregistreerd:', registration);
      })
      .catch(function(error) {
        console.log('Service Worker registratie mislukt:', error);
      });
  }

  // PWA Install prompt
  let deferredPrompt;
  const installButton = document.getElementById('install-button');
  
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    
    if (installButton) {
      installButton.style.display = 'block';
      installButton.addEventListener('click', () => {
        deferredPrompt.prompt();
        deferredPrompt.userChoice.then((choiceResult) => {
          if (choiceResult.outcome === 'accepted') {
            console.log('PWA geïnstalleerd');
          }
          deferredPrompt = null;
          installButton.style.display = 'none';
        });
      });
    }
  });

  // Bottom Navigation functionaliteit
  initBottomNavigation();
  
  // Pull to refresh functionaliteit
  initPullToRefresh();
  
  // Touch feedback voor knoppen
  initTouchFeedback();
  
  // Smooth scrolling
  initSmoothScrolling();
  
  // App-like loading states
  initLoadingStates();
});

// Bottom Navigation
function initBottomNavigation() {
  const bottomNav = document.querySelector('.app-bottom-nav');
  if (!bottomNav) return;
  
  const navItems = bottomNav.querySelectorAll('.app-bottom-nav__item');
  const currentPath = window.location.pathname;
  
  navItems.forEach(item => {
    const href = item.getAttribute('href');
    if (href === currentPath || (currentPath === '/' && href === '/')) {
      item.classList.add('active');
    }
    
    item.addEventListener('click', function(e) {
      navItems.forEach(nav => nav.classList.remove('active'));
      this.classList.add('active');
    });
  });
}

// Pull to Refresh
function initPullToRefresh() {
  let startY = 0;
  let currentY = 0;
  let pullDistance = 0;
  const threshold = 80;
  let isPulling = false;
  
  const pullIndicator = document.createElement('div');
  pullIndicator.className = 'app-pull-refresh';
  pullIndicator.textContent = 'Vernieuwen...';
  document.body.appendChild(pullIndicator);
  
  document.addEventListener('touchstart', function(e) {
    if (window.scrollY === 0) {
      startY = e.touches[0].clientY;
      isPulling = true;
    }
  });
  
  document.addEventListener('touchmove', function(e) {
    if (!isPulling) return;
    
    currentY = e.touches[0].clientY;
    pullDistance = currentY - startY;
    
    if (pullDistance > 0 && window.scrollY === 0) {
      e.preventDefault();
      
      if (pullDistance > threshold) {
        pullIndicator.classList.add('visible');
      } else {
        pullIndicator.classList.remove('visible');
      }
    }
  });
  
  document.addEventListener('touchend', function(e) {
    if (!isPulling) return;
    
    if (pullDistance > threshold) {
      // Trigger refresh
      window.location.reload();
    }
    
    pullIndicator.classList.remove('visible');
    isPulling = false;
    pullDistance = 0;
  });
}

// Touch Feedback
function initTouchFeedback() {
  const buttons = document.querySelectorAll('.app-btn, .theme-btn, button');
  
  buttons.forEach(button => {
    button.addEventListener('touchstart', function() {
      this.style.transform = 'scale(0.95)';
    });
    
    button.addEventListener('touchend', function() {
      this.style.transform = '';
    });
    
    button.addEventListener('touchcancel', function() {
      this.style.transform = '';
    });
  });
}

// Smooth Scrolling
function initSmoothScrolling() {
  const links = document.querySelectorAll('a[href^="#"]');
  
  links.forEach(link => {
    link.addEventListener('click', function(e) {
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

// Loading States
function initLoadingStates() {
  // Toon loading state bij form submissions
  const forms = document.querySelectorAll('form');
  forms.forEach(form => {
    form.addEventListener('submit', function() {
      const submitBtn = this.querySelector('input[type="submit"], button[type="submit"]');
      if (submitBtn) {
        const originalText = submitBtn.textContent;
        submitBtn.textContent = 'Laden...';
        submitBtn.disabled = true;
        
        // Reset na 5 seconden als fallback
        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        }, 5000);
      }
    });
  });
  
  // Toon loading state bij link clicks
  const links = document.querySelectorAll('a:not([href^="#"])');
  links.forEach(link => {
    link.addEventListener('click', function() {
      if (this.href && !this.href.includes('javascript:') && !this.href.includes('#')) {
        showPageLoading();
      }
    });
  });
}

// Page Loading Indicator
function showPageLoading() {
  const loading = document.createElement('div');
  loading.className = 'app-loading';
  loading.innerHTML = `
    <div class="app-loading__spinner"></div>
    <span>Laden...</span>
  `;
  
  document.body.appendChild(loading);
  
  // Verwijder na page load
  window.addEventListener('load', () => {
    if (loading.parentNode) {
      loading.parentNode.removeChild(loading);
    }
  });
}

// App-like notifications
function showNotification(message, type = 'info') {
  const notification = document.createElement('div');
  notification.className = `app-notification app-notification--${type}`;
  notification.textContent = message;
  
  // Styling
  notification.style.cssText = `
    position: fixed;
    top: 80px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--color-primary);
    color: var(--color-bg-alt);
    padding: 1rem 1.5rem;
    border-radius: 12px;
    font-weight: 600;
    z-index: 10000;
    box-shadow: 0 4px 20px rgba(0,0,0,0.2);
    opacity: 0;
    transition: opacity 0.3s ease;
  `;
  
  document.body.appendChild(notification);
  
  // Animate in
  setTimeout(() => {
    notification.style.opacity = '1';
  }, 100);
  
  // Auto remove
  setTimeout(() => {
    notification.style.opacity = '0';
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 300);
  }, 3000);
}

// Expose to global scope
window.AppUtils = {
  showNotification: showNotification,
  showPageLoading: showPageLoading
};

// Handle online/offline status
window.addEventListener('online', function() {
  AppUtils.showNotification('Je bent weer online!', 'success');
});

window.addEventListener('offline', function() {
  AppUtils.showNotification('Je bent offline. Sommige functies werken mogelijk niet.', 'warning');
}); 