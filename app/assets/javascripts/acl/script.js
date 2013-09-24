//refresh page on browser resize
$(window).bind('resize', function(e)
{
  if (window.RT) clearTimeout(window.RT);
  window.RT = setTimeout(function()
  {
    this.location.reload(false); /* false to get page from cache */
  }, 200);
});

$(function(){

    var H = 0;
    $(".stretch").each(function(i){
        var h = $(".stretch").eq(i).height();
        if(h > H) H = h;
    });
    $(".stretch").height(H);

    if ($('#map-onoff').hasClass('off')) {
    	$('#map').hide();
    };

    $('#map-onoff').mouseup(function(){
    	$('#map').slideToggle();
    });

    $("#sticker").sticky({
    	topSpacing:0
    });

    $(window).scroll(function() {
	    var y_scroll_pos = window.pageYOffset;
	    var scroll_pos_test = 450;  

	    if(y_scroll_pos > scroll_pos_test) {
	        if ($('#map-onoff').hasClass('on')) {
	        	$('#map').hide();
	        	$('#map-onoff').removeClass("on").addClass("off");
	        };
	    } else if(y_scroll_pos < 10) {
	    	if ($('#map-onoff').hasClass('off')) {
	        	$('#map').show();
	        	$('#map-onoff').removeClass("off").addClass("on");
	        };
	    }
	});
    	
});