jQuery ->
  new ImageCropper()

class ImageCropper
  constructor: ->
    $('#cropbox').Jcrop
      aspectRatio: 1.635
      setSelect: [0, 65, 500, 500]
      onSelect: @update
      onChange: @update
  
  update: (coords) =>
    $('#picture_crop_x').val(coords.x)
    $('#picture_crop_y').val(coords.y)
    $('#picture_crop_w').val(coords.w)
    $('#picture_crop_h').val(coords.h)
    @updatePreview(coords)
    
  updatePreview: (coords) =>
    $('#preview').css
      width: Math.round(206/coords.w * $('#cropbox').width()) + 'px'
      height: Math.round(126/coords.h * $('#cropbox').height()) + 'px'  
      marginLeft: '-' + Math.round(206/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(126/coords.h * coords.y) + 'px'