
!function ($) {
  $(function(){
    /*$('#f-carousel').carouFredSel({
     width: '100%',
     items: 3,
     scroll: {
     items: 1,
     duration: 1000,
     pauseDuration: 3000
     },
     prev: '#prev',
     next: '#next',
     pagination: {
     container: '#pager'

     }
     });*/
    $('#f-carousel').carouFredSel({
      responsive: true,
      prev: '#prev',
      next: '#next',
      scroll: {
        items: 1,
        duration : 1000
      },
      pagination: {
        container: '#pager'
      }
    });

    $("#slider1").carouFredSel({
      responsive: true,
      infinite: true,
      auto:false,
      prev	: {
        button	: "#slider1_prev",
        key		: "left"
      },
      next	: {
        button	: "#slider1_next",
        key		: "right"
      },
      swipe: {
        onMouse: true,
        onTouch: true
      },
      scroll: 1,
      items: {
        width: 299,
        height: 375,	//	optionally resize item-height
        visible: {
          min: 1,
          max: 3
        }
      }
    });
    $("#slider2").carouFredSel({
      responsive: true,
      infinite: true,
      auto:false,
      prev	: {
        button	: "#slider2_prev",
        key		: "left"
      },
      next	: {
        button	: "#slider2_next",
        key		: "right"
      },
      swipe: {
        onMouse: true,
        onTouch: true
      },
      scroll: 1,
      items: {
        width: 299,
        height: 375,	//	optionally resize item-height
        visible: {
          min: 1,
          max: 3
        }
      }
    });
    $("#slider3").carouFredSel({
      responsive: true,
      infinite: true,
      auto:false,
      prev	: {
        button	: "#slider3_prev",
        key		: "left"
      },
      next	: {
        button	: "#slider3_next",
        key		: "right"
      },
      swipe: {
        onMouse: true,
        onTouch: true
      },
      scroll: 1,
      items: {
        width: 299,
        height: 375,	//	optionally resize item-height
        visible: {
          min: 1,
          max: 3
        }
      }
    });
    $("#slider4").carouFredSel({
      responsive: true,
      infinite: true,
      auto:false,
      prev	: {
        button	: "#slider4_prev",
        key		: "left"
      },
      next	: {
        button	: "#slider4_next",
        key		: "right"
      },
      swipe: {
        onMouse: true,
        onTouch: true
      },
      scroll: 1,
      items: {
        width: 299,
        height: 375,	//	optionally resize item-height
        visible: {
          min: 1,
          max: 3
        }
      }
    });
    $("#slider5").carouFredSel({
      responsive: true,
      infinite: true,
      auto:false,
      prev	: {
        button	: "#slider5_prev",
        key		: "left"
      },
      next	: {
        button	: "#slider5_next",
        key		: "right"
      },
      swipe: {
        onMouse: true,
        onTouch: true
      },
      scroll: 1,
      items: {
        width: 299,
        height: 375,	//	optionally resize item-height
        visible: {
          min: 1,
          max: 3
        }
      }
    });

    $("#recommended-list").carouFredSel({
      responsive: true,
      swipe: {
        onMouse: true,
        onTouch: true
      },
      infinite: true,
      prev	: {
        button	: "#recommended-list_prev",
        key		: "left"
      },
      next	: {
        button	: "#recommended-list_next",
        key		: "right"
      },
      scroll: 1,
      items: {
        width: 225,
        height: 198,		// optionally resize item-height
        visible: {
          min: 1,
          max: 4
        }
      }
    });

    $(".footer-tap").click(function(){
      $(this).find(".popover").toggle();
    });

    $('footer .popover a').bind('click',function(event){
      var $anchor = $(this);
      $('html, body').stop().animate({
        scrollTop: ($($anchor.attr('href')).offset().top - 72 )

      }, 1500);
      event.preventDefault();
    });

    $(".navbar-search #appendedInput").on({
      focus: function(){
        $(this).next(".popover").show().addClass("open");
      },
      blur: function(){
        $(this).next(".popover").hide().removeClass("open");
      }
    });

    $(".search .product-list .product-item:nth-child(3n)").css("margin-right", 0);

    /*$( "#slider-vertical" ).slider({
     orientation: "vertical",
     range: "min",
     min: 5,
     max: 50,
     step: 8,
     value: 5,
     slide: function( event, ui ) {
     //$( "#amount" ).val( ui.value );
     }
     });*/
    $( "#slider-step" ).bind( "change", function(event, ui) {
      console.log($(this).val());
      $( "label.cvalue" ).text( 'Less Than $' + $(this).val() );
    });

    var mouseOverActiveElement = false;
    $(".sort-item a").on("click", function(e){
      e.stopPropagation();
      $(this).next(".popover").addClass("open").toggle();
    });
    $('.open').live('mouseenter', function(){
      mouseOverActiveElement = true;
    }).live('mouseleave', function(){
        mouseOverActiveElement = false;
      });

    $("html").click(function() {
      if($(".sort-item .popover").hasClass("open") && !mouseOverActiveElement){
        console.log('clicked outside active element');
        $(".sort-item .popover").hide().removeClass("open");
      }
    });


    $( "#from" ).datepicker({
      defaultDate: "+1w",
      changeMonth: true,
      numberOfMonths: 1,
      onClose: function( selectedDate ) {
        $( "#to" ).datepicker( "option", "minDate", selectedDate );
      }
    });
    $( "#to" ).datepicker({
      defaultDate: "+1w",
      changeMonth: true,
      numberOfMonths:1,
      onClose: function( selectedDate ) {
        $( "#from" ).datepicker( "option", "maxDate", selectedDate );
      }
    });

    $('#timepicker').timepicker();

    $(".link").on("click", function(){
      var target = $(this).attr("data-target");
//console.log(target);
      if(target){
        $('html, body').animate({scrollTop:$("#"+target).offset().top}, 800, 'easeInSine');
      }


    });
    $( "#slider-step" ).bind( "change", function(event, ui) {
      console.log($(this).val())
      cost_filter_events($(this).val())
    });

  })
}(window.jQuery)
