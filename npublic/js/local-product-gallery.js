(function () {
  function initGallery() {
    var wrapper = document.getElementById('magnifierWrapper');
    if (!wrapper || wrapper.getAttribute('data-local-gallery') === '1') return;
    wrapper.setAttribute('data-local-gallery', '1');

    var coverItems = wrapper.querySelectorAll('.images-cover .image-item');
    var thumbs = wrapper.querySelectorAll('.thumbnail_box li');
    var btnLeft = wrapper.querySelector('.magnifier-btn-left');
    var btnRight = wrapper.querySelector('.magnifier-btn-right');
    var zoomBtn = wrapper.querySelector('.image-bigger');
    var currentIndex = 0;

    if (!coverItems.length) return;

    function showIndex(i) {
      currentIndex = (i + coverItems.length) % coverItems.length;
      coverItems.forEach(function (item, idx) {
        item.style.display = idx === currentIndex ? 'flex' : 'none';
      });
      thumbs.forEach(function (li, idx) {
        if (idx === currentIndex) {
          li.classList.add('local-gallery-active');
        } else {
          li.classList.remove('local-gallery-active');
        }
      });
    }

    thumbs.forEach(function (li, idx) {
      li.style.cursor = 'pointer';
      li.addEventListener('click', function (e) {
        e.preventDefault();
        showIndex(idx);
      });
    });

    if (btnLeft) {
      btnLeft.style.cursor = 'pointer';
      btnLeft.addEventListener('click', function (e) {
        e.preventDefault();
        showIndex(currentIndex - 1);
      });
    }
    if (btnRight) {
      btnRight.style.cursor = 'pointer';
      btnRight.addEventListener('click', function (e) {
        e.preventDefault();
        showIndex(currentIndex + 1);
      });
    }

    function openZoom() {
      var img = coverItems[currentIndex].querySelector('img');
      if (!img || !img.src) return;
      var existing = document.getElementById('local-image-zoom-overlay');
      if (existing) existing.parentNode.removeChild(existing);

      var overlay = document.createElement('div');
      overlay.id = 'local-image-zoom-overlay';
      overlay.style.cssText =
        'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.88);z-index:999999;display:flex;align-items:center;justify-content:center;cursor:zoom-out;';

      var big = document.createElement('img');
      big.src = img.src;
      big.alt = img.alt || '';
      big.style.cssText = 'max-width:92%;max-height:92%;object-fit:contain;box-shadow:0 4px 24px rgba(0,0,0,0.4);';

      overlay.appendChild(big);
      overlay.addEventListener('click', function () {
        overlay.parentNode.removeChild(overlay);
      });
      document.addEventListener('keydown', function onKey(e) {
        if (e.key === 'Escape') {
          if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
          document.removeEventListener('keydown', onKey);
        }
      });
      document.body.appendChild(overlay);
    }

    if (zoomBtn) {
      zoomBtn.style.cursor = 'pointer';
      zoomBtn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        openZoom();
      });
    }

    var cover = wrapper.querySelector('.images-cover');
    if (cover) {
      cover.addEventListener('click', function (e) {
        if (e.target && e.target.tagName === 'IMG') openZoom();
      });
      cover.querySelectorAll('img').forEach(function (img) {
        img.style.cursor = 'zoom-in';
      });
    }

    showIndex(0);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initGallery);
  } else {
    initGallery();
  }
})();
