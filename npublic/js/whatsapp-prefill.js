(function (global) {
  var SITE = 'bottleblowtech.com';
  var DEFAULT_PHONE = '8617751189576';

  function getPageTitle() {
    var t = (document.title || '').replace(/\s*\|\s*KlWL Machinery\s*$/i, '').trim();
    return t || 'PET bottle blowing machine';
  }

  function getPageUrl() {
    var canonical = document.querySelector('link[rel="canonical"]');
    if (canonical && canonical.href && canonical.href.indexOf(SITE) !== -1) {
      return canonical.href;
    }
    if (location.protocol === 'file:') {
      var name = location.pathname.split(/[/\\]/).pop() || 'index.html';
      return 'https://www.' + SITE + '/' + name.replace(/\\/g, '/');
    }
    return location.href;
  }

  function buildMessage() {
    var product = getPageTitle();
    return (
      'Hello! I found your company on bottleblowtech.com and would like to inquire about a product I saw on your website.\n\n' +
      'Product: ' +
      product +
      '\n' +
      'Page: ' +
      getPageUrl()
    );
  }

  function buildWaMeUrl(phone) {
    phone = String(phone || DEFAULT_PHONE).replace(/\D/g, '');
    return 'https://wa.me/' + phone + '?text=' + encodeURIComponent(buildMessage());
  }

  function buildApiUrl(phone) {
    phone = String(phone || DEFAULT_PHONE).replace(/\D/g, '');
    return 'https://api.whatsapp.com/send?phone=' + phone + '&text=' + encodeURIComponent(buildMessage());
  }

  function extractPhoneFromHref(href) {
    var m = href.match(/wa\.me\/(\d+)/i) || href.match(/[?&]phone=(\d+)/i);
    return m ? m[1] : DEFAULT_PHONE;
  }

  function applyLink(el) {
    var href = el.getAttribute('href') || '';
    if (!/wa\.me|api\.whatsapp\.com|whatsapp\.com\/send/i.test(href)) {
      return;
    }
    var phone = extractPhoneFromHref(href);
    if (/api\.whatsapp/i.test(href)) {
      el.setAttribute('href', buildApiUrl(phone));
    } else {
      el.setAttribute('href', buildWaMeUrl(phone));
    }
  }

  function applyAll() {
    var nodes = document.querySelectorAll(
      'a[href*="wa.me"], a[href*="api.whatsapp.com"], a[href*="whatsapp.com/send"], .wa-consult-btn, .whatsapp_top_btn a'
    );
    for (var i = 0; i < nodes.length; i++) {
      applyLink(nodes[i]);
    }
  }

  global.KlwlWhatsApp = {
    buildMessage: buildMessage,
    buildWaMeUrl: buildWaMeUrl,
    buildApiUrl: buildApiUrl,
    applyAll: applyAll
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', applyAll);
  } else {
    applyAll();
  }
})(typeof window !== 'undefined' ? window : this);
