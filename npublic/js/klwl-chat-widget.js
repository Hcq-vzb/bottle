(function () {
  var MESSAGE_POPBOX_ID = '1750211754649';
  function getWaUrl() {
    if (window.KlwlWhatsApp && window.KlwlWhatsApp.buildWaMeUrl) {
      return window.KlwlWhatsApp.buildWaMeUrl('8617751189576');
    }
    var fallback =
      'Hello! I found your company on bottleblowtech.com and would like to inquire about a product I saw on your website.';
    return 'https://wa.me/8617751189576?text=' + encodeURIComponent(fallback);
  }

  var MESSAGES = [
    {
      html:
        'Hello! 👋 Welcome to <strong>KlWL Machinery</strong>. How can we help you today?'
    },
    {
      html:
        '<strong>Jiangsu KlWL Machinery Manufacturing Group Co., Ltd.</strong> is a high-tech enterprise integrating research, production and sales of bottle blowing machine industrial equipment.'
    },
    {
      html:
        'KlWL Machinery was founded in <strong>2007</strong>. With 17+ years of experience, our PET and plastic bottle blowing machines are trusted in <strong>170+ countries and regions</strong> worldwide.',
      stats: [
        { num: '2007', label: 'Founded' },
        { num: '170+', label: 'Countries' },
        { num: '20M', label: 'Capital' }
      ]
    },
    {
      html:
        'From 5 ml to 50 L bottles, single to 12 cavities — we offer customized solutions for water, oil, medical and more. Chat with our sales manager on WhatsApp for a quick quote!'
    }
  ];

  var panel = null;
  var isOpen = false;
  var animating = false;

  function closeMessagePopbox() {
    var box = document.getElementById('c_popbox-' + MESSAGE_POPBOX_ID);
    if (!box) return;
    if (typeof window.closePopbox === 'function') {
      window.closePopbox(box);
    } else {
      box.style.display = 'none';
      box.classList.remove('fixed');
    }
  }

  function createPanel() {
    if (panel) return panel;

    var waUrl = getWaUrl();

    panel = document.createElement('div');
    panel.className = 'klwl-chat-panel';
    panel.setAttribute('role', 'dialog');
    panel.setAttribute('aria-label', 'KlWL customer service chat');
    panel.innerHTML =
      '<div class="klwl-chat-header">' +
      '  <div class="klwl-chat-avatar">KlWL</div>' +
      '  <div class="klwl-chat-header-text">' +
      '    <h4>KlWL Customer Service</h4>' +
      '    <p>Typically replies within minutes</p>' +
      '  </div>' +
      '  <button type="button" class="klwl-chat-close" aria-label="Close chat">&times;</button>' +
      '</div>' +
      '<div class="klwl-chat-body"></div>' +
      '<div class="klwl-chat-footer">' +
      '  <a class="klwl-chat-wa-btn" href="' +
      waUrl +
      '" target="_blank" rel="noopener noreferrer">' +
      '    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.435 9.884-9.882 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>' +
      '    Chat on WhatsApp' +
      '  </a>' +
      '  <p class="klwl-chat-footer-hint">Connect with our sales manager for quotes &amp; technical support</p>' +
      '</div>';

    document.body.appendChild(panel);

    panel.querySelector('.klwl-chat-close').addEventListener('click', closePanel);

    document.addEventListener('click', function (e) {
      if (!isOpen || !panel) return;
      if (panel.contains(e.target)) return;
      if (e.target.closest('.liuyantanceng')) return;
      if (e.target.closest('saf-onlinebtn')) return;
      closePanel();
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && isOpen) closePanel();
    });

    return panel;
  }

  function renderStats(stats) {
    if (!stats || !stats.length) return '';
    var html = '<div class="klwl-chat-stats">';
    stats.forEach(function (s) {
      html +=
        '<div class="klwl-chat-stat"><b>' +
        s.num +
        '</b>' +
        s.label +
        '</div>';
    });
    html += '</div>';
    return html;
  }

  function showTyping(body) {
    var el = document.createElement('div');
    el.className = 'klwl-chat-typing';
    el.innerHTML = '<span></span><span></span><span></span>';
    body.appendChild(el);
    body.scrollTop = body.scrollHeight;
    return el;
  }

  function playMessages() {
    var body = panel.querySelector('.klwl-chat-body');
    body.innerHTML = '';
    animating = true;

    var i = 0;

    function next() {
      if (i >= MESSAGES.length) {
        animating = false;
        return;
      }

      var typing = showTyping(body);

      setTimeout(function () {
        typing.remove();
        var msg = document.createElement('div');
        msg.className = 'klwl-chat-msg';
        msg.innerHTML = MESSAGES[i].html + renderStats(MESSAGES[i].stats);
        body.appendChild(msg);
        requestAnimationFrame(function () {
          msg.classList.add('is-visible');
          body.scrollTop = body.scrollHeight;
        });
        i += 1;
        setTimeout(next, i < MESSAGES.length ? 800 : 0);
      }, 600);
    }

    next();
  }

  function updatePanelPosition() {
    if (!panel) return;
    var gap = 16;
    var bottomPx = 180;
    var rightPx = 20;
    var triggers = document.querySelectorAll('.liuyantanceng, saf-onlinebtn, saf-online');
    var anchorBottom = 0;
    var anchorRight = 0;

    triggers.forEach(function (el) {
      var rect = el.getBoundingClientRect();
      if (rect.width < 8 || rect.height < 8) return;
      if (rect.bottom > anchorBottom) anchorBottom = rect.bottom;
      if (rect.right > anchorRight) anchorRight = rect.right;
    });

    if (anchorBottom > 0) {
      bottomPx = window.innerHeight - anchorBottom + gap;
    }
    if (anchorRight > 0) {
      rightPx = Math.max(12, window.innerWidth - anchorRight);
    }

    panel.style.bottom = bottomPx + 'px';
    panel.style.right = rightPx + 'px';
    panel.style.maxHeight =
      'min(480px, calc(100vh - ' + (bottomPx + 24) + 'px))';
  }

  function openPanel() {
    closeMessagePopbox();
    createPanel();
    updatePanelPosition();
    isOpen = true;
    panel.classList.add('is-open');
    if (!animating && !panel.querySelector('.klwl-chat-msg')) {
      playMessages();
    }
  }

  function closePanel() {
    if (!panel) return;
    isOpen = false;
    panel.classList.remove('is-open');
  }

  function togglePanel() {
    if (isOpen) closePanel();
    else openPanel();
  }

  function hijackOpenDialog() {
    var prev = window.openDialog;
    if (prev && prev.__klwlChat) return;

    window.openDialog = function (id) {
      if (String(id) === MESSAGE_POPBOX_ID) {
        togglePanel();
        return;
      }
      if (typeof prev === 'function') {
        return prev.apply(this, arguments);
      }
    };
    window.openDialog.__klwlChat = true;
  }

  function ensureFloatTrigger() {
    document.querySelectorAll('.liuyantanceng').forEach(function (el) {
      if (el.parentElement === document.body) return;
      if (el.dataset.klwlMoved === '1') return;
      el.dataset.klwlMoved = '1';
      document.body.appendChild(el);
    });
  }

  function bindTriggers() {
    ensureFloatTrigger();

    document.querySelectorAll('.liuyantanceng a').forEach(function (a) {
      if (a.dataset.klwlChatBound) return;
      a.dataset.klwlChatBound = '1';
      a.setAttribute('href', 'javascript:void(0)');
      a.addEventListener(
        'click',
        function (e) {
          e.preventDefault();
          e.stopPropagation();
          togglePanel();
        },
        true
      );
    });

    document.querySelectorAll('saf-onlinebtn').forEach(function (btn) {
      if (btn.dataset.klwlChatBound) return;
      btn.dataset.klwlChatBound = '1';
      btn.addEventListener(
        'click',
        function (e) {
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          togglePanel();
        },
        true
      );
    });
  }

  function init() {
    hijackOpenDialog();
    bindTriggers();
  }

  function boot() {
    init();
    hijackOpenDialog();
    bindTriggers();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }

  window.addEventListener('load', boot);
  window.addEventListener('resize', function () {
    ensureFloatTrigger();
    if (isOpen) updatePanelPosition();
  });

  var observer = new MutationObserver(function () {
    hijackOpenDialog();
    bindTriggers();
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });
})();
