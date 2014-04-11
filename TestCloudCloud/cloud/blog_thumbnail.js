var Image = require("parse-image");
 
Parse.Cloud.beforeSave("Blog", function(request, response) {
  var blog = request.object;
  console.log("Before upload image")
  
  var blog_id = blog.get("blog_id");
  if ( blog_id == 1886 || blog_id == 720 || blog_id == 586 || blog_id == 2136 || blog_id == 693 || blog_id == 557 || blog_id == 84 || blog_id ==46 || blog_id==640 || blog_id==41
    || blog_id == 735 || blog_id == 688) {
    blog.set("cover_url","http://petparent.me/blog/wp-content/uploads/2014/02/vyari2ekzgty.jpg");
  };
  
  console.log(blog.get("cover_url"));
  console.log(blog.get("date_string"));
  
 
  Parse.Cloud.httpRequest({
    url: blog.get("cover_url")
 
  }).then(function(response) {
    console.log("Get here 0");
    var image = new Image();
    return image.setData(response.buffer);
 
  }).then(function(image) {
    // Crop the image to the smaller of width or height.
    console.log("Get here 1");
    var size = Math.min(image.width(), image.height());
    console.log("Get here 2");
    return image.crop({
      left: (image.width() - size) / 2,
      top: (image.height() - size) / 2,
      width: size,
      height: size
    });
 
  }).then(function(image) {
    // Resize the image to 64x64.
    console.log("Get here 3");
    return image.scale({
      width: 200,
      height:200  
    });
 
  }).then(function(image) {
    console.log("Get here 4");
    // Make sure it's a JPEG to save disk space and bandwidth.
      return image.setFormat("JPEG");
 
  }).then(function(image) {
        // Get the image data in a Buffer.
        console.log("Get here 5");
      return image.data();
 
      }).then(function(buffer) {
        console.log("Get here 6");
        // Save the image into a new file.
        var base64 = buffer.toString("base64");
        console.log("Get here 7");
        var cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
        console.log("Get here 8");
        return cropped.save();
 
      }).then(function(cropped) {
        // Attach the image file to the original object.
        console.log("Get here 9");
        blog.set("photo", cropped);
        blog.set("date", new Date(blog.get("date_string")));
        console.log("Get here 10");
        response.success();
 
      });
  });