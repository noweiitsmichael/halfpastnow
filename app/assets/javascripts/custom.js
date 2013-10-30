!function ($) {
	$(function(){
	  	// carousel demo
	  	$('#myCarousel').carousel()
	  
		$("#slider1").carouFredSel({
			responsive: true,
			infinite: true,
			auto: false,
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
		
		$(".product-list .product-item:nth-child(3n)").css("margin-right", 0);
	})
}(window.jQuery)
