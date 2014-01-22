$(function () {
  var myDate = Date.today()
  var defaultDate = Date.today().add(14).days();
  var tomorrowDate = Date.today().add(1).days();
  var today_date = (myDate.getMonth() + 1) + '/' + (myDate.getDate()) + '/' + myDate.getFullYear();
  var tomorrow_date = (tomorrowDate.getMonth() + 1) + '/' + (tomorrowDate.getDate()) + '/' + tomorrowDate.getFullYear();
  var default_to_date = (defaultDate.getMonth() + 1) + '/' + (defaultDate.getDate()) + '/' + defaultDate.getFullYear();
  $('.flickr_pagination a').click(function () {
    $("#related_events .main .inline .events,#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  });
  $('.flickr_pagination a').attr('data-remote', 'true');
  $('.desc_btn').hide();

  $(".asc_btn").click(function () {
    var sort_on = $(this).data('sort_on');
    var sort_by = $(this).data('sort_by');
    console.log(sort_on);
    console.log(sort_by);


    $('.' + $(this).data('type') + '.desc_btn').show();
    $('.' + $(this).data('type') + '.asc_btn').hide();
  });


  $(".desc_btn").click(function () {
    var sort_on = $(this).data('sort_on');
    var sort_by = $(this).data('sort_by');
    var sort_on = $(this).data('sort_on');
    var sort_by = $(this).data('sort_by');


    $('.' + $(this).data('type') + '.asc_btn').show();
    $('.' + $(this).data('type') + '.desc_btn').hide();
  });

  // advertisements
  $('.ad-details').on('click', function () {
    var id = $(this).data('id');
    var name = $(this).data('prop');
    var value = $(this).data('value');
    $.post('/admin/advertisements/update_ads_details', {pk: id, name: name, value: value })
  });

  $('.custom-start').val(today_date);
  $('.custom-end').val(default_to_date);
  $(".date_search").html($('.custom-start').val() + " to " + $('.custom-end').val());

  // sort by time and cost

  $('.cost_sort').click(function () {
    console.log(filter)
    filter.cost_sort = "cost"
    filter.time_sort = ""

    filter.order_cost = 1
    filter.order_cost = filter.order_cost * -1
    console.log(JSON.stringify(filter))
    $('.active a').click()
  });

  console.log(filter)
  console.log("search js 59");
  $('.time_sort').click(function () {
    console.log(filter)
    console.log("search js 62")
    filter.time_sort = "time"
    filter.cost_sort = ""
    filter.order_time = 1
    filter.order_time = parseInt(filter.order_time) * -1
    console.log(JSON.stringify(filter))
    $('.active a').click()
  })
  $('.custom-start').val(today_date)
  $('.custom-end').val(default_to_date)
  $(".date_search").html($('.custom-start').val() + " to " + $('.custom-end').val());

  if (params["key"] && params["tag_id"] && params["tag_type"]) {
    $(".active").attr('class', '');
    $('#search-tab').append("<li class='active related_events'><a data-toggle='tab' href='#related_events' key=" + params["key"] + " tag_type=" + params["tag_type"] + " tag_id= " + params["tag_id"] + ">" + params["key"].replace(/\_/g, " ") + " <i class='icon-cross'></i><i class='icon-white-pin'></i></a></li>")
    $('.icon-cross').on("click", function () {
      $(this).parents('li').remove()
    })


    $('.icon-white-pin').on("click", function () {
      key = $(this).parent().attr('key')
      check = $(this).parent()
      if (user_signed_in) {
        $(this).hide()
        $.get('/saved_search', {key: key}, function (data) {
          console.log(check)
          check.attr('key_id', data["key_id"]);

        })
        $('#share').click(function () {
          window.open(
            'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(location.href),
            'facebook-share-dialog',
            'width=626,height=436');
        })
        $(this).colorbox({href: "#save_share_content", inline: true, width: "50%", height: "200px"});

      }
      else{
        window.location.href = window.location.origin+"/login"
      }
    })
    $('#search_name,#search_name1').text(params["key"].replace(/\_/g, " "))
    $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:15px;height:15px;'>")
    filter.tag_id = params["tag_id"]
    filter.tag_type = params["tag_type"]
    filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd") + " " + $('.timepicker').val();
    filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
    console.log("search2")
    console.log(JSON.stringify(filter))
    $.get("/search_results", filter)
    $('#search_name,#search_name1').html(params["key"].replace(/\_/g, " "))
  } else if (params["key"] && params["tag_id"]) {
    console.log("serach page 114")
    $(".active").attr('class', '');
    $('#search-tab').append("<li class='active related_events'><a data-toggle='tab' href='#related_events' key=" + params["key"] + " tag_id=" + params["tag_id"] + ">" + params["key"].replace(/\_/g, " ") + " <i class='icon-cross'></i><i class='icon-white-pin'></i></a></li>")
    $('.icon-cross').on("click", function () {
      $(this).parents('li').remove()
    })


    $('.icon-white-pin').on("click", function () {
      key = $(this).parent().attr('key')
      check = $(this).parent()
      if (user_signed_in) {
        $(this).hide()
        $.get('/saved_search', {key: key}, function (data) {
          console.log(check)
          check.attr('key_id', data["key_id"]);

        })
        $('#share').click(function () {
          window.open(
            'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(location.href),
            'facebook-share-dialog',
            'width=626,height=436');
        })
        $(this).colorbox({href: "#save_share_content", inline: true, width: "50%", height: "200px"});

      }
      else{
        window.location.href = window.location.origin+"/login"
      }
    })
    $('#search_name,#search_name1').text(params["key"].replace(/\_/g, " "))
    $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:15px;height:15px;'>")

    dropdown_search_events(params["tag_id"])
    $('#search_name,#search_name1').html(params["key"].replace(/\_/g, " "))
  } else if (params["key"]) {

    $(".active").attr('class', '');
    $('#search-tab').append("<li class='active related_events'><a data-toggle='tab' href='#related_events' key= " + params["key"] + ">" + params["key"].replace(/\_/g, " ") + " <i class='icon-cross'></i><i class='icon-white-pin'></i></a></li>")
    $('.icon-cross').on("click", function () {
      $(this).parents('li').remove()
    })

    $('.icon-white-pin').on("click", function () {
      key = $(this).parent().attr('key')
      check = $(this).parent()
      if (user_signed_in) {
        $(this).hide()
        $.get('/saved_search', {key: key}, function (data) {
          console.log(check)
          check.attr('key_id', data["key_id"]);
        })
        $('#share').click(function () {
          window.open(
            'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(location.href),
            'facebook-share-dialog',
            'width=626,height=436');
        })
        $(this).colorbox({href: "#save_share_content", inline: true, width: "50%", height: "200px"});
      }
      else{
        window.location.href = window.location.origin+"/login"
      }
    })
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:15px;height:15px;'>")
    doneTyping1(params["key"]);
    $('#search_name,#search_name1').html(params["key"].replace(/\_/g, " "))
  }

  //neighborhood
  $("table.neighborhood_names_list td").on('click', function () {
    $("table.neighborhood_names_list td").removeClass('selected');
    $(this).addClass('selected');
    var id = $(this).data('id');
    $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    filter.neighborhood_id = id
    filter.filter_type = 'neighborhood'
    filter.tag_type = $('.active a').attr('tag_type')
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:15px;height:15px;'>")

    $.get('/search_results', filter);
  });

  $('.icon-cross').on("click", function () {
    $(this).parents('li').click()
    $(this).parents('li').remove()
    key_id = $(this).parent().attr('key_id')
    if (key_id != null) {
      if (user_signed_in) {
        $.get('/delete_saved_search', {key_id: key_id})
      }
    }
  });

  $('.popover_dates').click(function () {
    if ($(this).attr('tag_type') == 'today') {

      $('.custom-start').val(today_date)
      $('.custom-end').val(today_date)
      console.log('today')
      console.log($('.custom-start').val())
      console.log($('.custom-end').val())
    }
    if ($(this).attr('tag_type') == 'tomorrow') {
      $('.custom-start').val(tomorrow_date)
      $('.custom-end').val(tomorrow_date)
      console.log('tomorrow')
      console.log($('.custom-start').val())
      console.log($('.custom-end').val())
    }
    if ($(this).attr('tag_type') == 'weekend') {
      $('.custom-start').val(start_of_weekend)
      $('.custom-end').val(end_of_weekend)
      console.log('weekend')
      console.log($('.custom-start').val())
      console.log($('.custom-end').val())
    }
    $(".date_search").html($('.custom-start').val() + " to " + $('.custom-end').val())
    $('.active a').click()
  });
  $('.popover_dates:visible,.popover_dates:hidden').click(function () {
    $(".date_search").html($('.custom-start').val() + " to " + $('.custom-end').val())
  });
  $('.dropdown-menu1 a').click(function () {
    console.log("dropdown click")
    $(".active").attr('class', '');
    $('#search-tab').append("<li class='active related_events dropdown_links'><a data-toggle='tab' href='#related_events' key=" + $(this).text().replace(/\ /g, "_") + " tag_id=" + $(this).attr('tag_id') + " tag_type=" + $(this).attr('tag_type') + ">" + $(this).text() + " <i class='icon-cross'></i><i class='icon-white-pin'></i></a></li>")
    $('.icon-cross').on("click", function () {
      $(this).parents('li').remove()
    })
    $('#search_name,#search_name1').html($(this).text())
    console.log("this is tag reference:" + $(this).attr('tag_id'))
    $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:15px;height:15px;'>")
    if ($(this).attr('tag_id') == "0") {
      console.log('tag_type based search')
      filter.tag_id = "0"
      filter.included_tags = []
      filter.tag_type = $(this).attr('tag_type')
      filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd") + " " + $('.timepicker').val();
      filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
      filter.query = null
      console.log("search3")
      console.log(JSON.stringify(filter))
      url = "/search?key="+$(this).text().replace(/\ /g, "_")+"&tag_id=0&tag_type="+filter.tag_type
      history.pushState(null, null, url);
      $.get("/search_results", filter)

    }
    else {
      console.log("tag_id based search")
      url = "/search?key="+$(this).text().replace(/\ /g, "_")+"&tag_id="+$(this).attr('tag_id')
      history.pushState(null, null, url);
      dropdown_search_events($(this).attr('tag_id'))
    }
    //      doneTyping1($(this).text());

    $('.icon-white-pin').on("click", function () {
      key = $(this).parent().attr('key')
      tag_id = $(this).parent().attr('tag_id')
      tag_type = $(this).parent().attr('tag_type')
      check = $(this).parent()
      if (user_signed_in) {
        $(this).hide()
        $.get('/saved_search', {key: key, tag_id: tag_id, tag_type: tag_type}, function (data) {
          console.log(check)
          check.attr('key_id', data["key_id"]);

        })
        $(this).colorbox({href: "#save_share_content", inline: true, width: "50%", height: "200px"});
        $('.active a').click();
      }
      else{
        window.location.href = window.location.origin+"/login"
      }
    })
    $(".navbar-search #appendedInput").next(".popover").hide().removeClass("open");
  });
  $(".submit").on("click", function () {
    if ($("#appendedInput").val().length >= 3) {
      var search_key = $("#appendedInput").val().replace(/\ /g, "_")
      $(".active").attr('class', '');
      $('#search-tab').append("<li class='active related_events'><a data-toggle='tab' href='#related_events' key=" + search_key + ">" + $("#appendedInput").val() + " <i class='icon-cross'></i><i class='icon-white-pin'></i></a></li>")
      if (user_signed_in) {
        $('.icon-cross').on("click", function () {
          $(this).parents('li').remove()
          key_id = $(this).parent().attr('key_id')
          if (key_id != null) {
            if (user_signed_in) {
              $.get('/delete_saved_search', {key_id: key_id})
            }
          }
        })
      } else {
        $('.icon-cross').on("click", function () {
          $(this).parents('li').remove()
        })
      }
      $('.icon-white-pin').on("click", function () {
        key = $(this).parent().attr('key')
        tag_id = $(this).parent().attr('tag_id')
        check = $(this).parent()
        if (user_signed_in) {
          $(this).hide()
          $.get('/saved_search', {key: key, tag_id: tag_id}, function (data) {
            console.log(check)
            check.attr('key_id', data["key_id"]);
          })
          $(this).colorbox({href: "#save_share_content", inline: true, width: "50%", height: "200px"});

        }
        else{
          window.location.href = window.location.origin+"/login"
        }
      })
    }
    $('#share').click(function () {
      window.open(
        'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(location.href),
        'facebook-share-dialog',
        'width=626,height=436');
    })

    $('.active a').click()
    $('#events').show()
    $('#related_events').hide()
    $('.popover').hide()
  });
  $('.navbar-search').submit(function (e) {
    e.preventDefault();
    $('.popover').hide()
    if ($("#appendedInput").val().length >= 3) {
      var search_key = $("#appendedInput").val().replace(/\ /g, "_")
      $(".active").attr('class', '');
      $('#search-tab').append("<li class='active related_events'><a data-toggle='tab' href='#related_events' key=" + search_key + ">" + $("#appendedInput").val() + " <i class='icon-cross'></i><i class='icon-white-pin'></i></a></li>")
      if (user_signed_in) {
        $('.icon-cross').on("click", function () {
          $(this).parents('li').remove()
          key_id = $(this).parent().attr('key_id')
          if (key_id != null) {
            if (user_signed_in) {
              $.get('/delete_saved_search', {key_id: key_id})
            }
          }
        })
      } else {
        $('.icon-cross').on("click", function () {
          $(this).parents('li').remove()
        })
      }
      $('.icon-white-pin').on("click", function () {
        key = $(this).parent().attr('key')
        tag_id = $(this).parent().attr('tag_id')
        check = $(this).parent()
        if (user_signed_in) {
          $(this).hide()
          $.get('/saved_search', {key: key, tag_id: tag_id}, function (data) {
            console.log(check)
            check.attr('key_id', data["key_id"]);

          })
          $(this).colorbox({href: "#save_share_content", inline: true, width: "50%", height: "200px"});

        }
        else{
          window.location.href = window.location.origin+"/login"
        }
      })
    }
    $('#share').click(function () {
      window.open(
        'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(location.href),
        'facebook-share-dialog',
        'width=626,height=436');
    })

    $('.active a').click()
    $('#events').show()
    $('#related_events').hide()
  })
  url = window.location.href
  if (url.contains('key:')) {
    $(".active").attr('class', '');
    key_array = $.trim(decodeURI(url)).split("key:");
    key_value = key_array[1];
    $("a:contains(" + key_value + ")").parent('li').addClass('active').click()
    doneTyping1(key_value);
    $('#search_name,#search_name1').html(key_value)
  }
  $('.events_tab').click(function () {
    $('#related_events').hide();
    $('#events').show();
  })
  $('.related_events').click(function () {
    $('#related_events').hide();
    $('#events').show();
  })

  $('.filter-dropdown').hide()
  $('figure').click(function () {
    var event_id = $(this).parent('article').attr('link-id')
    console.log(event_id)
    window.location.href = window.location.origin + "/events/show/" + event_id + "?fullmode=true"
  });

  console.log(filter)
  console.log("search js 406")
});






