$(document).ready(function(){

// Profile Page
  //editables on first profile page
  $.fn.editable.defaults.mode = 'inline';
  $.fn.editableform.loading = "<div class='editableform-loading'><i class='light-blue icon-2x icon-spinner icon-spin'></i></div>";
  $.fn.editableform.buttons = '<button type="submit" class="btn btn-info editable-submit"><i class="icon-ok icon-white"></i></button>'+
    '<button type="button" class="btn editable-cancel"><i class="icon-remove"></i></button>';

  //editables
  $('#firstname, #lastname').editable({
    type: 'text',
    url: '/dashboard/update_profile'
  });
// Profile Page END

// My List Page
  $('.my-list > li:first').addClass('active');
  $('.my-list > li').click(function(){
    $('.my-list > li').removeClass('active');
    $(this).addClass('active');
  });
// My List Page End


// Preferences Page

  if(!$('input.preferences_chk').not(':checked').length > 0){
    $('table#preferences_table th input:checkbox').prop('checked',true);
  }

  $('table#preferences_table th input:checkbox').on('click' , function(){
    var that = this;
    var email = $(this).data('email');
    var id = $(this).data('id');
    var included_tags = [];
    $(this).closest('table').find('tr > td:first-child input:checkbox')
      .each(function(){
        included_tags.push($(this).val());
        this.checked = that.checked;
        $(this).closest('tr').toggleClass('selected');
      });

    if(that.checked){
      $.get('/channels/updateReg',{id: id, included_tags: included_tags});
    }else{
      $.get('/users/unsubscribe',{email: email});
    }
  });

  $('table#preferences_table td input:checkbox').on('click' , function(){
    var id = $(this).data('id');
    var included_tags = $('input.preferences_chk:checked').map(function(){ return $(this).val()}).get()
    if($('input.preferences_chk').not(':checked').length > 0){
      $('table#preferences_table th input:checkbox').prop('checked',false);
    }else{
      $('table#preferences_table th input:checkbox').prop('checked',true);
    }

    $.get('/channels/updateReg',{id: id, included_tags: included_tags});
  });
// Preferences Page END
});