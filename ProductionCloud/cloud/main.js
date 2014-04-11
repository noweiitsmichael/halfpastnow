require('cloud/event_thumbnail.js');
require('cloud/photo_thumbnail.js');
//require('cloud/crop_image.js');
require('cloud/venue_thumbnail.js');
require('cloud/blog_thumbnail.js');
 
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
 
 Parse.Cloud.beforeDelete(Parse.User, function(request, response) {
    // code here
    console.log("id = "+request.object.id);
     
    var fromUserQuery = new Parse.Query("Activity");
    fromUserQuery.equalTo("fromUser", request.object);
    var toUserQuery = new Parse.Query("Activity");
    toUserQuery.equalTo("toUser", request.object);
     
    var compoundQuery = Parse.Query.or(fromUserQuery,toUserQuery);
     
    compoundQuery.find({
    success: function(results) {
        Parse.Object.destroyAll(results);
        response.success();
    }
    });
  });