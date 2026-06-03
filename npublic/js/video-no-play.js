(function () {
  var VIDEO_COVER_PATHS = [
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/c505ecdb-730d-43c7-99a5-a483b9409593.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/ea036fdd-903a-4f14-a6f4-c854a69d252d.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/5ec615d0-4062-4cfd-a54b-fd3d2ba3e761.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/5a82caa7-9f41-4891-b243-9e08299adc25.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/82d0e9bb-e077-4130-8f83-c2ef83beb2f6.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/1728c12c-1f6f-42ae-abc3-e314af45d34a.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/2a05c46f-6963-4add-b4c1-9644a3077b3c.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/511e7099-4bc3-4a4a-a654-ce4f19eed713.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/ea8f73c4-eab6-43d5-a864-f41a5f73a076.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/f46ff6d5-2ac6-403f-bb24-afe7637acbb9.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/d334bb2b-ca8f-4256-8403-9174232ee2c5.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/f65fb267-8542-406c-abef-621ab29d6fa9.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/393f011c-17c9-4fa9-95d6-9e1db29264a3.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/26e039d3-4e12-4c80-95ab-2b73a2fd697b.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/f9eedc2b-39ea-46c9-b7e8-de1ac93583c4.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/0de2f7ce-5d31-48ed-b1a6-37cc9da2ec8c.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/b6860056-a4b6-40d2-ac9c-9c6300aa0c09.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/d204c33f-082b-4709-bf40-912b607ca218.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/5fa80a6a-6601-428d-aa78-3dba332a54cf.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/0b83e842-aff5-4491-a758-08483afaae1e.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/5c792b9a-7d7a-4097-9365-9dd6fba3a5e2.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/5cc20b37-1872-4d3a-b7ef-540d603d898e.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/04037b3e-8e9f-4732-b24f-43295785ab63.jpg',
    'omo-oss-image.thefastimg.com/portal-saas/pg2025032715012632289/cms/vedio/a238cb48-a5d4-43f9-9339-2aeeb2d56051.jpg'
  ];

  function getOssPrefix() {
    var href = decodeURIComponent(location.href).replace(/\\/g, '/');
    var marker = '/bottleblowtech.com/';
    var idx = href.toLowerCase().indexOf(marker);
    if (idx === -1) return './';
    var after = href.substring(idx + marker.length).split(/[?#]/)[0];
    var depth = (after.match(/\//g) || []).length;
    return depth > 0 ? '../'.repeat(depth) : './';
  }

  function pickRandomVideoCover() {
    return VIDEO_COVER_PATHS[Math.floor(Math.random() * VIDEO_COVER_PATHS.length)];
  }

  function applyShouhouVideoCovers() {
    var prefix = getOssPrefix();
    document.querySelectorAll('.shouhou-video-cover .coverImage img').forEach(function (img) {
      img.src = prefix + pickRandomVideoCover();
      img.removeAttribute('lazy');
      img.removeAttribute('data-src');
    });
  }

  function stripVideoSources(root) {
    root.querySelectorAll('video').forEach(function (video) {
      video.removeAttribute('src');
      video.querySelectorAll('source').forEach(function (source) {
        source.remove();
      });
      video.preload = 'none';
      video.controls = false;
    });
  }

  function disableVideoPlayback() {
    applyShouhouVideoCovers();
    stripVideoSources(document);

    if (typeof jQuery !== 'undefined') {
      jQuery('.videoCock, .shouhou-video-cover').off('click');
    }

    document.querySelectorAll('.videoCock, .shouhou-video-cover').forEach(function (el) {
      el.addEventListener(
        'click',
        function (event) {
          event.preventDefault();
          event.stopPropagation();
          event.stopImmediatePropagation();
          return false;
        },
        true
      );
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', disableVideoPlayback);
  } else {
    disableVideoPlayback();
  }

  if (typeof jQuery !== 'undefined') {
    jQuery(function () {
      disableVideoPlayback();
    });
  }

  window.addEventListener('load', disableVideoPlayback);
})();
