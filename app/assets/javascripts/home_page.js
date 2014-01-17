/* This is for home page */

//= require jquery
//= require jquery-migrate-1.2.1
//= require jquery-ui
//= require jquery_ujs
//= require jquery.Jcrop.min
//= require underscore
//= require viewport
//= require date
//= require jquery.dropkick-1.0.0
//= require galleria-1.2.8.min
//= require jquery.form
//= require history.min
//= require h5utils
//= require half.main
//= require jquery.colorbox
//= require modernizr-latest
//= require bootstrap
//= require jquery.touchSwipe.min
//= require jquery.ui.timepicker
//= require jquery.carouFredSel-6.2.1-packed
//= require custom
//= require half.dynamics
//= require jquery.unveil
//= require_self

$(document).ready(function () {

  //image lazy loading
  $("img.unveil").unveil();

  //home page
  if (user_signed_in) {
    $('#slider2,#slider3,#slider5').html("<img src='assets/ajax-loader.gif' style='left: 15%;position: relative; width:100px !important;'>");
    happy_place_events(19, "slider2");
    dance_events(1, "slider3");
    free_events("slider5");
  }

  $('.submit').click(function (e) {
    e.preventDefault();
    window.location.href = window.location.origin + "/search?key=" + $('#appendedInput').val();
  });

  $('figure').click(function () {
    var event_id = $(this).parent('article').attr('link-id');
    window.location.href = window.location.origin + "/events/austin/" + event_id;
  });

  $('article .name a').click(function () {
    var event_id = $(this).parents('article').attr('link-id');
    window.location.href = window.location.origin + "/events/austin/" + event_id;
  });

  $('.brand').click(function () {
    window.location.href = window.location.origin;
  });

  $('.dropdown-menu a,.dropdown-menu1 a').click(function () {
    tag_id = $(this).attr('tag_id');
    tag_type = $(this).attr('tag_type');
    if (tag_id == "0") {
      window.location.href = window.location.origin + "/search?key=" + encodeURIComponent($(this).text()) + "&tag_id=" + tag_id + "&tag_type=" + tag_type;
    }
    else {
      window.location.href = window.location.origin + "/search?key=" + encodeURIComponent($(this).text()) + "&tag_id=" + tag_id;
    }
  });

  $('.see_all_links').click(function () {
    tag_id = $(this).attr('tag_id');
    tag_type = $(this).attr('tag_type');
    tag_title = $(this).attr('tag_title');
    if (tag_id == "0") {
      window.location.href = window.location.origin + "/search?key=" + encodeURIComponent(tag_title) + "&tag_id=" + tag_id + "&tag_type=" + tag_type;
    }
    else {
      window.location.href = window.location.origin + "/search?key=" + encodeURIComponent(tag_title) + "&tag_id=" + tag_id;
    }
  });

  $('#slider1,#slider4').append("<article class='slide-item product-item see-more'><a href='/search' class='see-more' ><span class='btn btn-large btn-danger'>See More</span></a></article>");

  $('.before_login').click(function () {
    window.location.href = window.location.origin + "/login";
  });
});


