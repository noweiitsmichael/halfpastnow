$(document).ready(function () {

  // common
  $('.has_date_picker').datepicker({
    changeMonth: true,
    changeYear: true,
    minDate: 0
  });


// Profile Page
  //editables on first profile page
  $.fn.editable.defaults.mode = 'inline';
  $.fn.editableform.loading = "<div class='editableform-loading'><i class='light-blue icon-2x icon-spinner icon-spin'></i></div>";
  $.fn.editableform.buttons = '<button type="submit" class="btn btn-info editable-submit"><i class="icon-ok icon-white"></i></button>' +
    '<button type="button" class="btn editable-cancel"><i class="icon-remove"></i></button>';

  //editables
  $('#firstname, #lastname').editable({
    type: 'text',
    url: '/dashboard/update_profile'
  });

// *** editable avatar *** //
  try {//ie8 throws some harmless exception, so let's catch it

    //it seems that editable plugin calls appendChild, and as Image doesn't have it, it causes errors on IE at unpredicted points
    //so let's have a fake appendChild for it!
    if (/msie\s*(8|7|6)/.test(navigator.userAgent.toLowerCase())) Image.prototype.appendChild = function (el) {
    }

    var last_gritter
    $('#avatar').editable({
      type: 'image',
      name: 'avatar',
      value: null,
      image: {
        //specify ace file input plugin's options here
        btn_choose: 'Change Avatar',
        droppable: true,
        /**
         //this will override the default before_change that only accepts image files
         before_change: function(files, dropped) {
								return true;
							},
         */

        //and a few extra ones here
        name: 'profilepic',//put the field name here as well, will be used inside the custom plugin
        //max_size: 330000,//~300Kb
        on_error: function (code) {//on_error function will be called when the selected file has a problem
          if (last_gritter) $.gritter.remove(last_gritter);
          if (code == 1) {//file format error
            last_gritter = $.gritter.add({
              title: 'File is not an image!',
              text: 'Please choose a jpg|gif|png image!',
              class_name: 'gritter-error gritter-center'
            });
          } else if (code == 2) {//file size rror
            last_gritter = $.gritter.add({
              title: 'File too big!',
              text: 'Image size should not exceed 300Kb!',
              class_name: 'gritter-error gritter-center'
            });
          }
          else {//other error
          }
        },
        on_success: function () {
          $.gritter.removeAll();
        }
      },
      url: function (params) {
        // ***UPDATE AVATAR HERE*** //
        //You can replace the contents of this function with examples/profile-avatar-update.js for actual upload

        var submit_url = 'update_profile_pic';
        var deferred;


        //if value is empty, means no valid files were selected
        //but it may still be submitted by the plugin, because "" (empty string) is different from previous non-empty value whatever it was
        //so we return just here to prevent problems
        var value = $('#avatar').next().find('input[type=hidden]:eq(0)').val();
        if (!value || value.length == 0) {
          deferred = new $.Deferred
          deferred.resolve();
          return deferred.promise();
        }

        var $form = $('#avatar').next().find('.editableform:eq(0)')
        var file_input = $form.find('input[type=file]:eq(0)');

        //user iframe for older browsers that don't support file upload via FormData & Ajax
        if (!("FormData" in window)) {
          deferred = new $.Deferred

          var iframe_id = 'temporary-iframe-' + (new Date()).getTime() + '-' + (parseInt(Math.random() * 1000));
          $form.after('<iframe id="' + iframe_id + '" name="' + iframe_id + '" frameborder="0" width="0" height="0" src="about:blank" style="position:absolute;z-index:-1;"></iframe>');
          $form.append('<input type="hidden" name="temporary-iframe-id" value="' + iframe_id + '" />');
          $form.next().data('deferrer', deferred);//save the deferred object to the iframe
          $form.attr({'method': 'POST', 'enctype': 'multipart/form-data',
            'target': iframe_id, 'action': submit_url});

          $form.get(0).submit();

          //if we don't receive the response after 60 seconds, declare it as failed!
          setTimeout(function () {
            var iframe = document.getElementById(iframe_id);
            if (iframe != null) {
              iframe.src = "about:blank";
              $(iframe).remove();

              deferred.reject({'status': 'fail', 'message': 'Timeout!'});
            }
          }, 60000);
        }
        else {
          var fd = null;
          try {
            fd = new FormData($form.get(0));
          } catch (e) {
            //IE10 throws "SCRIPT5: Access is denied" exception,
            //so we need to add the key/value pairs one by one
            fd = new FormData();
            $.each($form.serializeArray(), function (index, item) {
              fd.append(item.name, item.value);
            });
            //and then add files because files are not included in serializeArray()'s result
            $form.find('input[type=file]').each(function () {
              if (this.files.length > 0) fd.append(this.getAttribute('name'), this.files[0]);
            });
          }

          //if file has been drag&dropped , append it to FormData
          if (file_input.data('ace_input_method') == 'drop') {
            var files = file_input.data('ace_input_files');
            if (files && files.length > 0) {
              fd.append(file_input.attr('name'), files[0]);
            }
          }

          deferred = $.ajax({
            url: submit_url,
            type: 'POST',
            processData: false,
            contentType: false,
            dataType: 'json',
            data: fd,
            xhr: function () {
              var req = $.ajaxSettings.xhr();
              /*if (req && req.upload) {
               req.upload.addEventListener('progress', function(e) {
               if(e.lengthComputable) {
               var done = e.loaded || e.position, total = e.total || e.totalSize;
               var percent = parseInt((done/total)*100) + '%';
               //bar.css('width', percent).parent().attr('data-percent', percent);
               }
               }, false);
               }*/
              console.log(req);
              return req;
            },
            beforeSend: function () {
              //bar.css('width', '0%').parent().attr('data-percent', '0%');
            },
            success: function () {
              //bar.css('width', '100%').parent().attr('data-percent', '100%');
            }
          })
        }


        deferred.done(function (res) {
          console.log('done')
          if (res.status == 'OK') $('#avatar').get(0).src = res.url;
            else window.location.reload();//alert(res.message);
        }).fail(function (res) {
            window.location.reload();
            //alert("Failure");
          });


        return deferred.promise();
      },

      success: function (response, newValue) {
      }
    })
  } catch (e) {
  }
// Profile Page END

// My List Page
  //$('.my-list > li:first').addClass('active');
  $('.my-list > li.Bookmarks').addClass('active');
  $('.my-list > li').click(function () {
    $('.my-list > li').removeClass('active');
    $(this).addClass('active');
  });
  $('#name, #description').editable({
    type: 'text',
    url: '/dashboard/update_bookmark_list'
  });

  var last_gritter
  $('#bookmark_list_picture').editable({
    type: 'image',
    name: 'bookmark_list_picture',
    value: null,
    image: {
      //specify ace file input plugin's options here
      btn_choose: 'Change Avatar',
      droppable: true,
      /**
       //this will override the default before_change that only accepts image files
       before_change: function(files, dropped) {
								return true;
							},
       */

      //and a few extra ones here
      name: 'picture',//put the field name here as well, will be used inside the custom plugin
      //max_size: 330000,//~300Kb
      on_error: function (code) {//on_error function will be called when the selected file has a problem
        if (last_gritter) $.gritter.remove(last_gritter);
        if (code == 1) {//file format error
          last_gritter = $.gritter.add({
            title: 'File is not an image!',
            text: 'Please choose a jpg|gif|png image!',
            class_name: 'gritter-error gritter-center'
          });
        } else if (code == 2) {//file size rror
          last_gritter = $.gritter.add({
            title: 'File too big!',
            text: 'Image size should not exceed 300Kb!',
            class_name: 'gritter-error gritter-center'
          });
        }
        else {//other error
        }
      },
      on_success: function () {
        $.gritter.removeAll();
      }
    },
    url: function (params) {
      // ***UPDATE AVATAR HERE*** //
      //You can replace the contents of this function with examples/profile-avatar-update.js for actual upload

      var id = $('#bookmark_list_picture').data('id');
      var submit_url = 'update_bookmark_list_picture?id=' + id;
      var deferred;


      //if value is empty, means no valid files were selected
      //but it may still be submitted by the plugin, because "" (empty string) is different from previous non-empty value whatever it was
      //so we return just here to prevent problems
      var value = $('#bookmark_list_picture').next().find('input[type=hidden]:eq(0)').val();
      if (!value || value.length == 0) {
        deferred = new $.Deferred
        deferred.resolve();
        return deferred.promise();
      }

      var $form = $('#bookmark_list_picture').next().find('.editableform:eq(0)')
      var file_input = $form.find('input[type=file]:eq(0)');

      //user iframe for older browsers that don't support file upload via FormData & Ajax
      if (!("FormData" in window)) {
        deferred = new $.Deferred

        var iframe_id = 'temporary-iframe-' + (new Date()).getTime() + '-' + (parseInt(Math.random() * 1000));
        $form.after('<iframe id="' + iframe_id + '" name="' + iframe_id + '" frameborder="0" width="0" height="0" src="about:blank" style="position:absolute;z-index:-1;"></iframe>');
        $form.append('<input type="hidden" name="temporary-iframe-id" value="' + iframe_id + '" />');
        $form.next().data('deferrer', deferred);//save the deferred object to the iframe
        $form.attr({'method': 'POST', 'enctype': 'multipart/form-data',
          'target': iframe_id, 'action': submit_url});

        $form.get(0).submit();

        //if we don't receive the response after 60 seconds, declare it as failed!
        setTimeout(function () {
          var iframe = document.getElementById(iframe_id);
          if (iframe != null) {
            iframe.src = "about:blank";
            $(iframe).remove();

            deferred.reject({'status': 'fail', 'message': 'Timeout!'});
          }
        }, 60000);
      }
      else {
        var fd = null;
        try {
          fd = new FormData($form.get(0));
        } catch (e) {
          //IE10 throws "SCRIPT5: Access is denied" exception,
          //so we need to add the key/value pairs one by one
          fd = new FormData();
          $.each($form.serializeArray(), function (index, item) {
            fd.append(item.name, item.value);
          });
          //and then add files because files are not included in serializeArray()'s result
          $form.find('input[type=file]').each(function () {
            if (this.files.length > 0) fd.append(this.getAttribute('name'), this.files[0]);
          });
        }

        //if file has been drag&dropped , append it to FormData
        if (file_input.data('ace_input_method') == 'drop') {
          var files = file_input.data('ace_input_files');
          if (files && files.length > 0) {
            fd.append(file_input.attr('name'), files[0]);
          }
        }

        //fd = fd.deep_merge(extra_params);
        deferred = $.ajax({
          url: submit_url,
          type: 'POST',
          processData: false,
          contentType: false,
          dataType: 'json',
          data: fd,
          xhr: function () {
            var req = $.ajaxSettings.xhr();
            /*if (req && req.upload) {
             req.upload.addEventListener('progress', function(e) {
             if(e.lengthComputable) {
             var done = e.loaded || e.position, total = e.total || e.totalSize;
             var percent = parseInt((done/total)*100) + '%';
             //bar.css('width', percent).parent().attr('data-percent', percent);
             }
             }, false);
             }*/
            console.log(req);
            return req;
          },
          beforeSend: function () {
            //bar.css('width', '0%').parent().attr('data-percent', '0%');
          },
          success: function () {
            //bar.css('width', '100%').parent().attr('data-percent', '100%');
          }
        })
      }


      deferred.done(function (res) {
        console.log('done')
        if (res.status == 'OK') $('#bookmark_list_picture').get(0).src = res.url;
        else window.location.reload();//alert(res.message);
      }).fail(function (res) {
          window.location.reload();
          //alert("Failure");
        });


      return deferred.promise();
    },

    success: function (response, newValue) {
    }
  })
// My List Page End


// Preferences Page

  if (!$('input.preferences_chk').not(':checked').length > 0) {
    $('table#preferences_table th input:checkbox').prop('checked', true);
  }

  $('table#preferences_table th input:checkbox').on('click', function () {
    var that = this;
    var email = $(this).data('email');
    var id = $(this).data('id');
    var included_tags = [];
    $(this).closest('table').find('tr > td:first-child input:checkbox')
      .each(function () {
        included_tags.push($(this).val());
        this.checked = that.checked;
        $(this).closest('tr').toggleClass('selected');
      });

    if (that.checked) {
      $.get('/channels/updateReg', {id: id, included_tags: included_tags});
    } else {
      $.get('/users/unsubscribe', {email: email});
    }
  });

  $('table#preferences_table td input:checkbox').on('click', function () {
    var id = $(this).data('id');
    var included_tags = $('input.preferences_chk:checked').map(function () {
      return $(this).val()
    }).get()
    if ($('input.preferences_chk').not(':checked').length > 0) {
      $('table#preferences_table th input:checkbox').prop('checked', false);
    } else {
      $('table#preferences_table th input:checkbox').prop('checked', true);
    }

    $.get('/channels/updateReg', {id: id, included_tags: included_tags});
  });
// Preferences Page END
});