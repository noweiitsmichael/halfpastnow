jQuery ->
  new PictureCropper()

class PictureCropper
  constructor: ->
    $('#cropbox').Jcrop
      aspectRatio: 1
      setSelect: [0, 0, 500, 500]
      onSelect: @update
      onChange: @update
  
  update: (coords) =>
    $('#bookmark_list_crop_x').val(coords.x)
    $('#bookmark_list_crop_y').val(coords.y)
    $('#bookmark_list_crop_w').val(coords.w)
    $('#bookmark_list_crop_h').val(coords.h)
    @updatePreview(coords)
    
  updatePreview: (coords) =>
    $('#preview').css
      width: Math.round(100/coords.w * $('#cropbox').width()) + 'px'
      height: Math.round(100/coords.h * $('#cropbox').height()) + 'px'  
      marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
