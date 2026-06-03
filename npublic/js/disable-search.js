(function () {
  function blockSearch(e) {
    var el = e.target.closest(
      '.nav-search, .h_search, .seabtn, a[href*="result.html"], a[href*="result31dc.html"]'
    );
    if (!el) return;
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
    return false;
  }

  document.addEventListener('click', blockSearch, true);

  document.querySelectorAll('a[href*="result"]').forEach(function (a) {
    var href = a.getAttribute('href') || '';
    if (/result(\d*)?\.html/i.test(href)) {
      a.setAttribute('href', 'javascript:void(0)');
      a.setAttribute('aria-hidden', 'true');
      a.style.display = 'none';
    }
  });
})();
