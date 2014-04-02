var ajax_form = true;

$( document ).ready(function() { // Document ready

/*-----------------------------------------------------------------------------------*/
/*	01. PARALLAX SETTING
/*-----------------------------------------------------------------------------------*/
	

  $(document).ready(function(){	
	//.parallax(xPosition, speedFactor, outerHeight) options:
	//xPosition - Horizontal position of the element
	//inertia - speed to move relative to vertical scroll. Example: 0.1 is one tenth the speed of scrolling, 2 is twice the speed of scrolling
	//outerHeight (true/false) - Whether or not jQuery should use it's outerHeight option to determine when a section is in the viewport
	// $('#header').parallax("center", 0.5, false);
	
})



/*-----------------------------------------------------------------------------------*/
/*	02. NAVBAR STICKY + SELECTED
/*-----------------------------------------------------------------------------------*/
	


// var cbpAnimatedHeader = (function() {

// 	var docElem = document.documentElement,
// 		header = document.querySelector( '.cbp-af-header' ),
// 		didScroll = false,
// 		changeHeaderOn = 200;

// 	function init() {
// 		window.addEventListener( 'scroll', function( event ) {
// 			if( !didScroll ) {
// 				didScroll = true;
// 				setTimeout( scrollPage, 0 );
// 			}
// 		}, false );
// 	}

// 	function scrollPage() {
// 		var sy = scrollY();
// 		if ( sy >= changeHeaderOn ) {
// 			classie.add( header, 'cbp-af-header-shrink' );
// 		}
// 		else {
// 			// classie.remove( header, 'cbp-af-header-shrink' );
// 		}
// 		didScroll = false;
// 	}

// 	function scrollY() {
// 		return window.pageYOffset || docElem.scrollTop;
// 	}

// 	init();

// })();


 
/*-----------------------------------------------------------------------------------*/
/*	03. FADE IN EFFECTS
/*-----------------------------------------------------------------------------------*/
		
		
		// $('.fade1').delay(400).fadeIn(2000);
		
		// $('.fade2').delay(700).fadeIn(1500);
		
		// $('.fade3').delay(1000).fadeIn(1500);
		


/*-----------------------------------------------------------------------------------*/
/*	04. Get the CBPSCROLLER
/*-----------------------------------------------------------------------------------*/


			// new cbpScroller( document.getElementById( 'cbp-so-scroller' ) );

			
/*-----------------------------------------------------------------------------------*/
/*	05. SMOOTH SCROLLING ON BUTTON
/*-----------------------------------------------------------------------------------*/
	

// $('.button').click(function(e){
//     $('html,body').scrollTo(this.hash,this.hash);
//     e.preventDefault();
// });


/*-----------------------------------------------------------------------------------*/
/*	06. FORM SENDER
/*-----------------------------------------------------------------------------------*/
	

	/* Form Submission */
	$('form').submit(function() {
		
		var form_data = $(this).serialize();

		if (validateEmail($('input[name=email]').attr('value')))
		{
			
			if (typeof ajax_form !== "undefined" && ajax_form === true)
			{
				
				$.post($(this).attr('action'), form_data, function(data) {
					$('form').show('slow', function() { $(this).after('<div class="clear"></div> <p class="msg-ok">'+ data + '</p>'); });
	  				$('.spam').hide();
	  				$('.msg-ok').delay(300).effect("pulsate", { times:1 }, 1000);
				});
				
				return false;
				
			}
			
		}

		else
		{
			$('p.spam').text('Please enter a valid e-mail').effect("pulsate", { times:3 }, 1000);
			return false;
		}
		
	});


/* Validate E-Mail */

function validateEmail(email) { 
  // http://stackoverflow.com/a/46181/11236
  
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}


/*-----------------------------------------------------------------------------------*/
/*	07. FLEXSLIDER - TESTIMONIAL
/*-----------------------------------------------------------------------------------*/
	

	$('#slider1').flexslider({
		animation: "fade",
		directionNav:false,
		controlNav:false,
		smoothHeight: true,
		animationLoop:true,
		slideshowSpeed: 3000,		
		slideToStart: 0,
	});
	
	$('#slider2').flexslider({
		animation: "slide",
		directionNav:true,
		controlNav:false,		
		smoothHeight: true,
		animationLoop:true,
		sync: "#slider1",
		slideshowSpeed: 3000,			
		slideToStart: 0,
	});
								



/*-----------------------------------------------------------------------------------*/
/*	08. RESPONSIVE MENU
/*-----------------------------------------------------------------------------------*/

		// jQuery("#collapse").hide();
		// jQuery("#collapse-menu").on("click", function () {
		
		//     jQuery("#collapse").slideToggle(300);
		//     return false;
		    
		// }, function () {
		    
		//     jQuery("#collapse").slideToggle(300);
		//     return false;
		// });
	
});
