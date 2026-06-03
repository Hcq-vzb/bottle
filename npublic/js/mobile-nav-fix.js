(function () {
  var NAV_ID = 'c_navigation_0061635239687823';
  var MOBILE_MAX = 1024;

  function isMobile() {
    return window.innerWidth <= MOBILE_MAX;
  }

  function getNavRoot() {
    return document.getElementById(NAV_ID);
  }

  function getNavBlock() {
    var root = getNavRoot();
    if (!root) return null;
    return root.querySelector('.e_navigationA-16');
  }

  function openNav() {
    var root = getNavRoot();
    var nav = getNavBlock();
    if (!root || !nav) return;
    root.classList.add('klwl-nav-open');
    nav.classList.add('klwl-nav-open');
    document.body.classList.add('klwl-nav-no-scroll');
  }

  function closeNav() {
    var root = getNavRoot();
    var nav = getNavBlock();
    if (root) root.classList.remove('klwl-nav-open');
    if (nav) nav.classList.remove('klwl-nav-open');
    document.body.classList.remove('klwl-nav-no-scroll');
  }

  function toggleNav() {
    var root = getNavRoot();
    if (root && root.classList.contains('klwl-nav-open')) closeNav();
    else openNav();
  }

  function bindNav() {
    var nav = getNavBlock();
    if (!nav || nav.dataset.klwlNavBound) return;
    nav.dataset.klwlNavBound = '1';

    var openBtn = nav.querySelector(':scope > .p_navButton');
    var content = nav.querySelector('.p_navContent');
    var closeBtn = content ? content.querySelector('.p_navButton') : null;

    if (openBtn) {
      openBtn.addEventListener(
        'click',
        function (e) {
          if (!isMobile()) return;
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          toggleNav();
        },
        true
      );
    }

    if (closeBtn) {
      closeBtn.addEventListener(
        'click',
        function (e) {
          if (!isMobile()) return;
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          closeNav();
        },
        true
      );
    }

    nav.querySelectorAll('.p_level1Item').forEach(function (item) {
      var menu = item.querySelector(':scope > .p_menu1Item');
      var sub = item.querySelector(':scope > .p_level2Box');
      if (!menu) return;

      if (sub) {
        menu.addEventListener('click', function (e) {
          if (!isMobile()) return;
          e.preventDefault();
          e.stopPropagation();
          var open = menu.classList.contains('klwl-submenu-open');
          nav.querySelectorAll('.p_menu1Item.klwl-submenu-open').forEach(function (m) {
            m.classList.remove('klwl-submenu-open');
          });
          if (!open) menu.classList.add('klwl-submenu-open');
        });
      }

      var arrow = menu.querySelector('.p_jtIcon');
      if (arrow) {
        arrow.addEventListener('click', function (e) {
          if (!isMobile()) return;
          e.preventDefault();
          e.stopPropagation();
          menu.classList.toggle('klwl-submenu-open');
        });
      }
    });

    content &&
      content.querySelectorAll('a[href]').forEach(function (a) {
        a.addEventListener('click', function () {
          if (isMobile()) closeNav();
        });
      });
  }

  function fixOpenIconColor() {
    var nav = getNavBlock();
    if (!nav) return;
    var icon = nav.querySelector(':scope > .p_navButton .p_openIcon');
    if (!icon) return;
    icon.style.fill = '#222222';
    icon.querySelectorAll('path').forEach(function (path) {
      path.setAttribute('fill', '#222222');
      path.style.fill = '#222222';
    });
  }

  function init() {
    bindNav();
    fixOpenIconColor();
    window.addEventListener('resize', function () {
      if (!isMobile()) closeNav();
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeNav();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  window.addEventListener('load', init);
})();
