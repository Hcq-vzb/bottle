$(function () {
    var createVideoBoxAndPlay = function (videoHTML) {
        $("body").append("<div class='videoBox show'>" + videoHTML + "</div>");
        let video = $("body").children(".videoBox").find('.video')[0];
        $(video).attr('playsinline', 'true');
        $(video).attr('webkit-playsinline', 'true');
        const player = new Plyr(video);
        if (video.paused == true) {
            video.play();
        } else {
            video.pause();
        }

        $("body > .videoBox > .closeVideo").click(function () {
            $(this).parent().remove();
        });
    };

    $('.videoCock').on('click', function (event) {
        let e = $(event.target);
        let isE_Loopitem = e.closest('.p_loopitem').length > 0;
        let isE_RollSlide = e.closest('.p_rollSlide').length > 0;
        let isE_dataIndex = e.closest('[data-index]').length > 0;

        let $targetElement = null;
        if (isE_Loopitem) {
            $targetElement = e.closest('.p_loopitem');
        } else if (isE_RollSlide) {
            $targetElement = e.closest('.p_rollSlide');
        } else if (isE_dataIndex) {
            $targetElement = e.closest('[data-index]');
        }

        if ($targetElement !== null) {
            console.log($targetElement);
            let videoBox = $targetElement.find(".videoBox").html();
            createVideoBoxAndPlay(videoBox);
        }
    });

    $('.videoIBox').each(function () {
        let videoImgHref = $(this).find('.videoimg img').attr('src');
        $(this).find('.coverImage img').attr('src', videoImgHref);
    });
});
