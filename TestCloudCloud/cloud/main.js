
require('cloud/blog_thumbnail.js');
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
	response.success("Hello world!");
});

Parse.Cloud.define("updateImages", function(request, response) {
  var query = new Parse.Query("Blog");
  query.equalTo("photo", null);
  query.limit(1000000);
  query.find({
    success: function(results) {
    	var count = 0;
	    for (var i=0;i<results.length;i++)
		{ 
			



		}
		var Photo = Parse.Object.extend("Photo");
		var photo = new Photo();
		photo.save(null, {
	        success:function (item) {
	            response.success("foo object updated");
	        },
	        error:function (item, error) {
	            response.error("Error updating foo records. Error: " + error.message);
	        }
	    });
    	
    },
    error: function() {
      response.error("movie lookup failed");
    }
  });
});
