(function () {
  function closePopbox(box) {
    if (!box) return;
    box.style.display = 'none';
    box.classList.remove('fixed');
    if (window.jQuery) {
      window.jQuery(box).hide().removeClass('fixed');
    }
    box.querySelectorAll('video').forEach(function (v) {
      try { v.pause(); } catch (e) { /* ignore */ }
    });
  }

  function openPopbox(id) {
    var box = document.getElementById('c_popbox-' + id);
    if (!box) return;
    box.style.display = 'block';
    box.classList.add('fixed');
    if (window.jQuery) {
      var $box = window.jQuery(box);
      $box.show().addClass('fixed');
      var h = $box.find('.pop_wrapper').height() || 0;
      $box.css({
        'margin-top': h ? -h / 2 : 0,
        'margin-left': 'auto',
        'margin-right': 'auto',
        'margin-bottom': 0
      });
      $box.find('.p_content').trigger('onVisible');
    }
  }

  window.closePopbox = closePopbox;
  window.openDialog = function (id) {
    openPopbox(id);
  };

  document.addEventListener('click', function (e) {
    var closeBtn = e.target.closest('.p_close');
    if (closeBtn) {
      var box = closeBtn.closest('div[id^="c_popbox"]');
      if (box) {
        e.preventDefault();
        e.stopPropagation();
        closePopbox(box);
        return;
      }
    }

    var bg = e.target.closest('div[id^="c_popbox"] .p_background');
    if (bg) {
      var popbox = bg.closest('div[id^="c_popbox"]');
      if (popbox && popbox.classList.contains('fixed')) {
        closePopbox(popbox);
      }
    }
  }, true);

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      document.querySelectorAll('div[id^="c_popbox"].fixed').forEach(closePopbox);
    }
  });
})();
