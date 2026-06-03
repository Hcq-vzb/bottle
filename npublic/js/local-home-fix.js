(function () {
  function getOssPrefix() {
    var href = decodeURIComponent(location.href).replace(/\\/g, '/');
    var marker = '/bottleblowtech.com/';
    var idx = href.toLowerCase().indexOf(marker);
    if (idx === -1) return './';
    var after = href.substring(idx + marker.length).split(/[?#]/)[0];
    var depth = (after.match(/\//g) || []).length;
    return depth > 0 ? '../'.repeat(depth) : './';
  }

  function localOssUrl(url) {
    if (!url) return url;
    var prefix = getOssPrefix();
    return url
      .replace(/^https?:\/\/omo-oss-image1?\.thefastimg\.com\//i, prefix + 'omo-oss-image.thefastimg.com/')
      .replace(/^(?:\.\.\/|\.\/)*omo-oss-image1?\.thefastimg\.com\//i, prefix + 'omo-oss-image.thefastimg.com/');
  }

  function fixLazyImages() {
    document.querySelectorAll('img[lazy]').forEach(function (img) {
      var lazy = img.getAttribute('lazy');
      if (!lazy) return;
      img.src = localOssUrl(lazy);
      img.removeAttribute('lazy');
      img.removeAttribute('data-src');
      img.removeAttribute('loading');
    });
  }

  function fixBannerBackgrounds() {
    document.querySelectorAll('.e_bannerD-1 .p_slide[style*="background-image"]').forEach(function (slide) {
      var m = slide.getAttribute('style').match(/url\(([^)]+)\)/);
      if (!m) return;
      slide.style.backgroundImage = 'url(' + localOssUrl(m[1].replace(/['"]/g, '')) + ')';
    });
  }

  function initBannerA() {
    if (typeof Swiper === 'undefined') return;
    document.querySelectorAll('.e_bannerA-33 .swiper-container').forEach(function (el) {
      if (el.swiper) return;
      var root = el.closest('.e_bannerA-33') || el.parentElement;
      new Swiper(el, {
        autoplay: { delay: 4000, disableOnInteraction: false },
        speed: 600,
        loop: true,
        navigation: {
          nextEl: root.querySelector('.swiper-button-next'),
          prevEl: root.querySelector('.swiper-button-prev')
        }
      });
    });
  }

  function fixHonorImages() {
    document.querySelectorAll('#c_effect_112-1690623837699 .honorSwip img').forEach(function (img) {
      var wrap = img.closest('.showihonor');
      var dataSrc = wrap && wrap.getAttribute('data-src');
      var src = img.getAttribute('src') || '';
      if (dataSrc && (!src || /s\.png$/i.test(src))) {
        img.setAttribute('src', localOssUrl(dataSrc));
      }
      img.removeAttribute('lazy');
      img.removeAttribute('data-src');
    });
  }

  function fixBannerSwiperSize() {
    if (window.innerWidth > 1024) return;
    document.querySelectorAll('#c_static_001_P_1080-1647501045930 .swiper-container').forEach(function (el) {
      if (el.swiper && typeof el.swiper.update === 'function') {
        el.swiper.update();
      }
    });
  }

  function run() {
    fixLazyImages();
    fixBannerBackgrounds();
    fixHonorImages();
    initBannerA();
    fixBannerSwiperSize();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run);
  } else {
    run();
  }

  window.addEventListener('load', function () {
    run();
    fixBannerSwiperSize();
  });
  window.addEventListener('resize', fixBannerSwiperSize);
})();
