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

  function localHonorSrc(url) {
    if (!url) return url;
    var prefix = getOssPrefix();
    return url
      .replace(/^https?:\/\/omo-oss-image1?\.thefastimg\.com\//i, prefix + 'omo-oss-image.thefastimg.com/')
      .replace(/^(?:\.\.\/|\.\/)*omo-oss-image1?\.thefastimg\.com\//i, prefix + 'omo-oss-image.thefastimg.com/');
  }

  function fixHonorImages() {
    document.querySelectorAll('#c_effect_112-1690623837699 .honorSwip img').forEach(function (img) {
      var wrap = img.closest('.showihonor');
      var dataSrc = wrap && wrap.getAttribute('data-src');
      var src = img.getAttribute('src') || '';
      if (dataSrc && (!src || /s\.png$/i.test(src))) {
        img.setAttribute('src', localHonorSrc(dataSrc));
      }
      img.removeAttribute('lazy');
      img.removeAttribute('data-src');
    });
  }

  function initHonor() {
    if (typeof Swiper === 'undefined') return false;
    var el = document.querySelector('.honorSwip');
    if (!el) return false;

    fixHonorImages();

    if (el.swiper) {
      try { el.swiper.destroy(true, true); } catch (e) {}
    }

    new Swiper(el, {
      effect: 'coverflow',
      grabCursor: true,
      centeredSlides: true,
      slidesPerView: 'auto',
      loop: true,
      loopAdditionalSlides: 5,
      loopedSlides: 8,
      watchSlidesProgress: true,
      coverflowEffect: {
        rotate: 32,
        stretch: -52,
        depth: 260,
        modifier: 1.15,
        slideShadows: true
      },
      speed: 900,
      autoplay: {
        delay: 3500,
        disableOnInteraction: false
      },
      pagination: {
        el: el.querySelector('.swiper-pagination'),
        clickable: true
      }
    });
    return true;
  }

  function initFancybox() {
    if (typeof Fancybox === 'undefined') return;
    Fancybox.bind('.fancyboxIMHhonor .showihonor', {
      groupAll: true,
      Image: { wheel: 'slide' }
    });
  }

  var tries = 0;
  function attempt() {
    fixHonorImages();
    if (initHonor()) {
      initFancybox();
      return;
    }
    if (tries++ < 80) {
      setTimeout(attempt, 150);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', attempt);
  } else {
    attempt();
  }
  window.addEventListener('load', function onLoad() {
    window.removeEventListener('load', onLoad);
    if (!document.querySelector('.honorSwip.swiper-container-initialized')) {
      attempt();
    }
  });
})();
