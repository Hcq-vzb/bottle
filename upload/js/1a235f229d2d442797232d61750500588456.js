
	$('.index_4 .swiper-slide').mouseover(function(){										    
		$('.index_4_bg div').removeClass('on');
		$('.index_4_bg div').eq($('.index_4 .swiper-slide').index(this)).addClass('on');
	});

	var swiperindex_4 = new Swiper('.swiper-wrapper-index_4', {
		speed: 1000,
		slidesPerView: 6,
		allowTouchMove: true,
		loop: false,
		pagination: {
			el: '.swiper-pagination-index_4',
			clickable: true,
		},
		
      
      
      breakpoints: { 
        320: {  
          slidesPerView: 1,
        },
        768: { 
          slidesPerView: 1,
        },
        1280: { 
          slidesPerView: 6,
        }
      }
      

	});

$(".bg_ad").eq(0).addClass("on");

