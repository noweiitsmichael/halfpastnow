//////////////////////////////////
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
    $('.stretch').each(function(i){
        var h = $('.stretch').eq(i).height();
        if(h > H) H = h;
    });
    $('.stretch').height(H);

    if ($('#map-onoff').hasClass('off')) {
    	$('#map').hide();
    };

    $('#map-onoff').mouseup(function(){
    	$('#map').slideToggle();
    });

    $('#sticker').sticky({
    	topSpacing:0
    });

    $(window).scroll(function() {
	    var y_scroll_pos = window.pageYOffset;
	    var scroll_pos_test = 280;  

	    if(y_scroll_pos > scroll_pos_test) {
	        if ($('#map-onoff').hasClass('on')) {
	        	$('#map').slideUp();
	        	$('#map-onoff').removeClass('on').addClass('off');
	        };
	    }; 
	});

    $('.big-event-container, .small-event-container').click(function(){
        window.location=$(this).find('a').attr('href');return false;
    });
    	
    $('.big-event-container, .small-event-container').hover(function(){
        $(this).find('.event-image img').addClass('blur');
    }, function(){
        $(this).find('.event-image img').removeClass('blur');
    });

    $('.big-event-container').hover(function(){
        $(this).find('.text').css('background-color','rgba(255,255,255,0)');
    }, function(){
        $(this).find('.text').css('background-color','rgba(255,255,255,.8)');
    });

    $('.small-event-container').hover(function(){
        $(this).find('.text').css('top','0px');
    }, function(){
        $(this).find('.text').css('top','inherit');
    });


    $('.filter').click(function(){
        if ($(this).find('a').hasClass('active')) {
            $(this).find('a').removeClass('active');
        } else {
            $(this).find('a').addClass('active');
        }
    });

    $('.rotate').textrotator({
      animation: 'dissolve', // You can pick the way it animates when rotating through words. Options are dissolve (default), fade, flip, flipUp, flipCube, flipCubeUp and spin.
      separator: ',', // If you don't want commas to be the separator, you can define a new separator (|, &, * etc.) by yourself using this field.
      speed: 2000 // How many milliseconds until the next word show.
    });

    // things for button on pink bar

    $('.pink-banner .comments').hide();
    $('.callout').hover(function(){
        $('.pink-banner .comments').show();
    }, function(){
        $('.pink-banner .comments').hide();
    });

    //responsive menu
    $('#menu-icon').click(function(){
        $('nav ul').slideToggle();
    });

});

// very simple tabs
function ShowTab(num){
  $('#tab-anchors li').removeClass('current');
  $('#tab-anchor-' + num).addClass('current');

  $('.tab').hide();
  $('#tab-' + num).fadeIn('slow');
}

// make logo glow
var $FlickImg = $('.logo img'), c = 0;

(function(){
  var i, time;

  for (i = 0; i < 10; ++i) {
      time = ~~(Math.random()*300) + 1;
      $FlickImg.delay( time ).fadeTo(30, ++c%2);
  }
  $FlickImg.delay( time ).fadeTo(30, 100);
})();