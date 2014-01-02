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
      width: $(window).width(),
      height: 400,
      align: false,
      auto: false,
      items: {
        visible: 1,
        width: 'variable',
        height: 'variable'
      },
      pagination: {
        container: '#pager'
      }
    });
    $(window).resize(function() {
      var newCss = {
        width: $(window).width(),
      };
      $('#f-carousel').css( 'width', newCss.width*4 );
      $('#f-carousel').parent().css( newCss );
      $('#f-carousel .item').css( newCss );
    }).resize();

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

    var isInputFocused = false;
    $(".navbar-search #appendedInput").on({
      focus: function(){
        isInputFocused = true;
        $(this).next(".popover").show().addClass("open");
      },
      /*blur: function(){
       $(this).next(".popover").hide().removeClass("open");
       }*/
    });

    $(".search .product-list .product-item:nth-child(3n)").css("margin-right", 0);

    $( "#slider-step" ).bind( "change", function(event, ui) {
      console.log($(this).val());
      $( "label.cvalue" ).text( 'Less Than $' + $(this).val() );
    });

    var mouseOverActiveElement = false;
    $(".sort-item a").on("click", function(e){
      e.stopPropagation();
      $(this).next(".popover").addClass("open").toggle();
    });
    $('.open, #appendedInput').live('mouseenter', function(){
      mouseOverActiveElement = true;
    }).live('mouseleave', function(){
        mouseOverActiveElement = false;
      });

    $("html").click(function() {
      if($(".sort-item .popover").hasClass("open") || $(".input-append .popover").hasClass("open") && !mouseOverActiveElement){
        console.log('clicked outside active element');
        $(".sort-item .popover").hide().removeClass("open");
        $(".input-append .popover").hide().removeClass("open");
      }
    });


    $('.timepicker').timepicker({
      showPeriod: true,
      showLeadingZero: true
    });
    $('.timepicker').change(function(){
      $('.timepicker').val($(this).val())
      $(".time_search").html("&nbsp;after "+$('.timepicker').val())
      filter.low_price = "";
      filter.high_price = ($('#slider-step').val() === MAX_PRICE) ? "" : $('#slider-step').val();
      filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd")+ " "+$(this).val();
      filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
      tag_id = parseInt($('.active a').attr('tag_id'))
      tag_type = $('.active a').attr('tag_type')
      $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
      $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
      $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
      if(tag_id == 0 && (tag_type == "nil" || tag_type == "undefined")){
// alert("search key")
        doneTyping1($('#search-tab .active a').text());
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      }else if(tag_id == 0){
// alert("only tag type")
        filter.tag_id = tag_id
        filter.tag_type = tag_type
//alert(JSON.stringify(filter))
        $.get("/search_results",filter)
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      }else{
// alert("only key")
        dropdown_search_events($(this).attr('tag_id'))
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      }


    })

    $(".link").on("click", function(){
      var target = $(this).attr("data-target");
//console.log(target);
      if(target){
        $('html, body').animate({scrollTop:$("#"+target).offset().top}, 800, 'easeInSine');
      }


    });
  })
}(window.jQuery)
