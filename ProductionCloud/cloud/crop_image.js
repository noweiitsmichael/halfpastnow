var Image = require("parse-image");
 
Parse.Cloud.define("cropVenueImage", function(request, response) {
    var query = new Parse.Query("Venue");
    query.equalTo("objectId", request.params.id);
    query.find({
        success: function(results) {
            var venue =  results[0];
            /////////////////// //////////////// //////////////// ////////////////
            if (!venue.get("image")) {
                response.error("venue must have a image.");
                return;
            }
 
            console.log("1 in image response");
 
            Parse.Cloud.httpRequest({
                url: venue.get("image").url()
 
            }).then(function(response) {
                        var image = new Image();
                        return image.setData(response.buffer);
 
                    }).then(function(image) {
                        // Crop the image to the smaller of width or height.
                        var size = Math.min(image.width(), image.height());
                        console.log("in funcation Crop");
                        return image.crop({
                            left: (image.width() - size) / 2,
                            top: (image.height() - size) / 2,
                            width: size,
                            height: size
                        });
 
                    }).then(function(result) {
                        response.success();
                    }, function(error) {
                        response.error(error);
                    });
 
 
            ////////////////  //////////////// //////////////// ////////////////
            response.success(venue.get("image").url());
        },
        error: function() {
            response.error("movie lookup failed");
        }
    });
});