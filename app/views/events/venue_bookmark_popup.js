var popup_html = "<%= escape_javascript render :partial => 'bookmark_popup' %>";
$('#bookmark_modal').html(popup_html);
$('#bookmark_list_collection').prop('selectedIndex', -1);
$('#bookmark_modal').modal('show');

// adding new bookmark group in popup
$('#add_new_bookmark_group_btn').click(function () {
  var name = $('#new_bookmark_group_field').val();
  $.get('/bookmarks/create_bookmark_group', { "name": name });
});

$('.bookmark_popup').click(function () {
  console.log("bookmark popup");
  var id = "<%= @venue.id %>"
  var bookmarked_type = "Venue";
  var bookmark_list_id = $('#bookmark_list_collection').val();
  var bookmarked_comments = $('#bookmark_group_comment').val();

  $.getJSON('/bookmarks/custom_create', { bookmark: { "type": bookmarked_type, "id": id, "bookmark_list_id": bookmark_list_id, "comment": bookmarked_comments } }, function (data) {
    $('#bookmark_modal').modal('hide');
    $("select#bookmark_list_collection option[value= "+ data +"]").hide();
    $(".additional-info .bookmark_" + "<%= @venue.id %>").html("<img src='/assets/images/icon-bookmark-add-more-large.png'/>");
  });
});