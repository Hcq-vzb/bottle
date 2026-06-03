scroll_animation = function(selectors, type) {
    history.scrollRestoration = 'manual';
    let body = $("body");
    if (!body.hasClass("wd-scroll-animation-init")) {
        $(".main>div,.s_title, .s_line, .s_img, .s_button4, .e_timeFormat-8, .e_richText-18, [class*='e_text'], .e_websiteShare-31, .swiper-slide, .swiper-pagination span").addClass("wd-scroll-animation");
        body.addClass("wd-scroll-animation-init");
        let num = 0;
        $(window).scroll(function() {
            num = 0;
        });

        function ani(a, t) {
            var top = a.offset().top;
            if (top < ($(window).height() + t - 100)) {
                setTimeout(function() {
                    a.addClass("wd-scroll-in");
                    a.addClass("wd-scrolled");
                }, 100 + num * 50);
                num++;
            }
        }

        function handle() {
            let t = $(window).scrollTop();
            let body_height = body.height();
            $(".wd-scroll-animation:not(.wd-scroll-in):not(.wd-no-scroll-animation)").each(function() {
                ani($(this), t);
            });
            if ($(window).height() + t + 200 >= body_height) {
                $(".wd-scroll-animation:not(.wd-scroll-in):not(.wd-no-scroll-animation)").each(function() {
                    $(this).addClass("wd-scroll-in").addClass("wd-scrolled");
                });
            }
            requestAnimationFrame(handle);
        }
        requestAnimationFrame(handle);
    }
    $(selectors).addClass("wd-scroll-animation").each(function() {
        if (type) {
            $(this).addClass(type)
        }
    });
    return scroll_animation;
};



  $(()=>{
 
  
  let body = $("body");
  if(isFrontEnv()) {
    body.addClass("cn-show");
  } else {
    body.addClass("cn-make");
  }
  
   
  $("#c_effect_112-1690623837699 .e_image-2, #c_effect_112-1690623837699 .e_loop-1 .p_list .swiper-slide,#c_grid-116273709439191,#c_grid-116273709439190,#c_static_794-1672108030693 .e_loop-84,#c_popbox-1650422312893,#c_new_list_175-1670482016935 .e_text-7,#c_static_001-16906260213710 .e_loop-1 .p_loopitem").addClass("wd-no-scroll-animation");
  scroll_animation("div[id*='c_banner_']")(".s_title")("#c_static_001-1655777530535 .e_container-4")(".header .lugRim")("div[class*='s_button']")("#c_static_527-1657100683465 .e_image-5")("#c_static_001-1659875643822 .e_loop-4 .p_loopitem")("#c_static_527-1657100683465 .e_container-4")("#c_static_001_P_2294-1659700724979 .e_loop-1 .p_loopitem")("#c_new_list_106-1659681562974 .e_container-5 > .p_item")("#c_new_list_106-1659681562974 .e_loop-15 .p_loopitem")("#c_static_001-1655741574821 .e_loop-4")("#c_static_001-16598844278640 .e_loop-4 .p_loopitem")("div[class*='e_richText']")("div[class*='e_richText'] p")("[class*='s_button']")("[class*='e_h3']")("[class*='e_h1']")("#c_static_001-1655745607156 .e_container-6")(".header .logorim")(".header ul.p_level1Box li.p_level1Item")(".header .cnhamburger")(".e_html-35")("[class*='e_breadcrumb']")(".p_page")("#c_static_001-16420726718590 .e_provider-26")("#c_static_001-16558006536120 .e_loop-5 .p_loopitem")("#c_static_001-1655807092949 .cnNews .cn_news")("#c_static_0011634881662748 .e_form-1 .form-group")("#c_static_001-1655826266487 .e_container-4 .p_item")("#c_static_001-1655826266487 .e_html-8")("#c_static_001-1656297310014 .e_container-4")("#c_static_001_P_3181-1656314082268 .e_container-4")("#c_static_001_P_1599-1656302229756 .e_container-28 > .p_item")("#c_static_001-16420726718590 .e_image-19")("#c_static_001_P_2294-16598812092420 .e_loop-1 .p_loopitem")("#c_static_001-16558110165530 .e_image-3")("#c_static_001-1655809875868 .e_image-8");
  
});



