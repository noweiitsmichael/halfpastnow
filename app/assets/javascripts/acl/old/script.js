//refresh page on browser resize
$(window).bind('resize', function(e)
{
  if (window.RT) clearTimeout(window.RT);
  window.RT = setTimeout(function()
  {
    this.location.reload(false); /* false to get page from cache */
  }, 200);
});

$(window).load(function(){

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
	    }; 
	});

    $(".big-event-container, .small-event-container").click(function(){
        window.location=$(this).find("a").attr("href");return false;
    });
    	
    $(".big-event-container, .small-event-container").hover(function(){
        $(this).find(".event-image img").addClass("blur");
    }, function(){
        $(this).find(".event-image img").removeClass("blur");
    });

    $(".big-event-container").hover(function(){
        $(this).find(".text").css("background-color","rgba(255,255,255,0)");
        $(this).find("a.event-title").css("color","white");
    }, function(){
        $(this).find(".text").css("background-color","rgba(255,255,255,.8)");
        $(this).find("a.event-title").css("color","#0D0500");
    });

    $(".small-event-container").hover(function(){
        $(this).find(".text").css("top","0px");
    }, function(){
        $(this).find(".text").css("top","inherit");
    });


    $(".filter").click(function(){
        if ($(this).find('a').hasClass('active')) {
            $(this).find('a').removeClass('active');
        } else {
            $(this).find('a').addClass('active');
        }
    });

    $(".rotate").textrotator({
      animation: "flip", // You can pick the way it animates when rotating through words. Options are dissolve (default), fade, flip, flipUp, flipCube, flipCubeUp and spin.
      separator: ",", // If you don't want commas to be the separator, you can define a new separator (|, &, * etc.) by yourself using this field.
      speed: 2000 // How many milliseconds until the next word show.
    });


});

// very simple tabs
function ShowTab(num){
  $('#tab-anchors li').removeClass('current');
  $('#tab-anchor-' + num).addClass('current');

  $('.tab').hide();
  $('#tab-' + num).fadeIn("slow");
}


// make logo glow

var $FlickImg = $('.logo img'), c = 0;

(function loop(){
  var time = ~~(Math.random()*600) + 1; // increase the value affecting random to change max duration of flickering
  $FlickImg.delay( time ).fadeTo(30, ++c%2, loop);
})();
