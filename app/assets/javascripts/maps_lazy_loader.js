(function() {
  function trackPlausibleGoal(eventName) {
    if (typeof window.plausible === 'function') {
      window.plausible(eventName);
    }
  }

  function activateMap(container) {
    const lat = parseFloat(container.dataset.lat);
    const lng = parseFloat(container.dataset.lng);
    const zoom = parseInt(container.dataset.zoom) || 16;
    const address = container.dataset.address || '';

    const overlay = container.querySelector('[data-map-overlay]');
    const facade = container.querySelector('[data-map-facade]');
    const canvas = container.querySelector('[data-map-canvas]');

    overlay.style.display = 'none';
    facade.style.display = 'none';
    canvas.classList.remove('hidden');

    initialiseBasicMapWithMarker(canvas, { lat, lng, zoom, address });
    trackPlausibleGoal('Activate Interactive Map');
  }

  function activateStreetView(container) {
    const lat = parseFloat(container.dataset.lat);
    const lng = parseFloat(container.dataset.lng);
    const address = container.dataset.address || '';

    const overlay = container.querySelector('[data-streetview-overlay]');
    const facade = container.querySelector('[data-streetview-facade]');
    const canvas = container.querySelector('[data-streetview-canvas]');

    overlay.style.display = 'none';
    facade.style.display = 'none';
    canvas.classList.remove('hidden');

    initialisePano(canvas, { lat, lng, address });
    trackPlausibleGoal('Activate Street View');
  }

  function whenVisible(callback) {
    if (document.visibilityState === 'visible') {
      callback();
      return;
    }
    function onVisibilityChange() {
      if (document.visibilityState === 'visible') {
        document.removeEventListener('visibilitychange', onVisibilityChange);
        callback();
      }
    }
    document.addEventListener('visibilitychange', onVisibilityChange);
  }

  function promoteFacade(container) {
    container.querySelectorAll('img[data-src]').forEach(img => {
      if (!img.getAttribute('src')) {
        img.src = img.dataset.src;
      }
      img.removeAttribute('data-src');
    });
  }

  function bindListeners() {
    document.querySelectorAll('[data-map-activate]').forEach(button => {
      const fresh = button.cloneNode(true);
      button.replaceWith(fresh);
      fresh.addEventListener('click', () => activateMap(fresh.closest('[data-map-target]')));
    });

    document.querySelectorAll('[data-streetview-activate]').forEach(button => {
      const fresh = button.cloneNode(true);
      button.replaceWith(fresh);
      fresh.addEventListener('click', () => activateStreetView(fresh.closest('[data-streetview-target]')));
    });

    document.querySelectorAll('[data-map-target], [data-streetview-target]').forEach(container => {
      whenVisible(() => promoteFacade(container));
    });
  }

  document.addEventListener('DOMContentLoaded', bindListeners);
  document.addEventListener('turbo:load', bindListeners);
  document.addEventListener('page:load', bindListeners);
})();
