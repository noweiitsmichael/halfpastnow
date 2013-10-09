$(function() {
	 
	var windowWidth = $(window).width();

	// image offset

    centerImage();
    $(window).resize(function() {
    	if(windowWidth != $(window).width()){
    		location.reload();
    		return;
    	}
        centerImage();
    });
    function centerImage() {
        var imgframes = $('.top-event a img.photo');
        imgframes.each(function(i){
            var imgVRelativeOffset = ($(this).height() - $(this).parent().parent().height()) / 2;
            var imgHRelativeOffset = ($(this).width() - $(this).parent().parent().width()) / 2;
            $(this).css({
                'position': 'absolute',
                'top': imgVRelativeOffset * -1,
                'left': imgHRelativeOffset * -1
            });
        });
    }

    // tabs

    var tabContainers = $('section.theevents > div.tab');
    tabContainers.hide().filter(':first').show();
      
    $('section.theevents ul.tabNavigation a').click(function () {
        tabContainers.hide();
        tabContainers.filter(this.hash).show();
        $('section.theevents ul.tabNavigation a').removeClass('selected');
        $(this).addClass('selected');
        centerImage();
        return false;
    }).filter(':first').click();

   
    // effect over menu

    $('.menuitem').hover(function() {
    	$(this).parent().parent().find('.menu-tagline').slideToggle();
    });

    // dropdown calendar
	var showMenu = function(el, menu) {
	        //get the position of the placeholder element
	        var pos = $(el).offset();
	        var eWidth = $(el).outerWidth();
	        var mWidth = $(menu).outerWidth();
	        var left = (pos.left + eWidth + 16) + "px";
	        var top = pos.top -20 + "px";
	        //show the menu directly over the placeholder
	        $(menu).css( {
	                position: 'absolute',
	                zIndex: 5000,
	                left: left,
	                top: top
	        } );
	       $(menu).fadeToggle();
	};

	$('#show-calendar').click(function(){
		showMenu('.calendar-image', '#calendar-widget');
	});
	
	// a primitive method to get the date --  needs to be improved. 

	var thedate = new Date();
	var day = thedate.getDate();
	var month = thedate.getMonth();
	var year = thedate.getFullYear();
	var today = (year + '-' + (month + 1) + '-' + day).toString();

	$('#date').DatePicker({
		flat: true,
		date: today,
		current: today,
		calendars: 1,
		starts: 1
	});

    //slider 
    if (jQuery.fn.cssOriginal!=undefined) 
        noConflict().fn.css = noConflict().fn.cssOriginal;

                    $('.fullwidthbanner').revolution(
                        {
                            delay:9000,
                            startwidth:960,
                            startheight:250,
                            onHoverStop:"on",
                            thumbWidth:50,
                            thumbHeight:50,
                            thumbAmount:5,
                            hideThumbs:0,
                            navigationType:"none",
                            navigationArrows:"none",
                            navigationStyle:"round",
                            navigationHAlign:"center",
                            navigationVAlign:"top",
                            navigationHOffset:0,
                            navigationVOffset:20,
                            soloArrowLeftHalign:"left",
                            soloArrowLeftValign:"center",
                            soloArrowLeftHOffset:20,
                            soloArrowLeftVOffset:0,
                            soloArrowRightHalign:"right",
                            soloArrowRightValign:"center",
                            soloArrowRightHOffset:20,
                            soloArrowRightVOffset:0,
                            touchenabled:"on",
                            stopAtSlide:-1,
                            stopAfterLoops:-1,
                            hideCaptionAtLimit:0,
                            hideAllCaptionAtLilmit:0,
                            hideSliderAtLimit:0,
                            fullWidth:"on",
                            shadow:0
                        });

});


