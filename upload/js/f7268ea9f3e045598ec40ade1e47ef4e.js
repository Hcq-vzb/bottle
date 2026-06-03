$(function () {
    $('.titleClick').click(function () {
        $(this).parent().find('.e_icon-8').toggle();
        $(this).parent().find('form').children().animate({
            height: 'toggle'
        });
        return true;
    });
});