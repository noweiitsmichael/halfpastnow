// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery-migrate-1.2.1
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
//= require jquery.ui.timepicker
//= require modernizr-latest
//= require bootstrap
//= require jquery.carouFredSel-6.2.1-packed
//= require jquery.touchSwipe.min
//= require custom
//= require jquery.unveil
//= require_self

$(document).ready(function () {

  //image lazy loading
  $("img.unveil").unveil();
  $(document).ajaxComplete(function(event,request, settings) {
    $("img.unveil").unveil();
  });
});


