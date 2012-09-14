// Array.prototype.diff = function(a) {
//     return this.filter(function(i) {return !(a.indexOf(i) > -1);});
// };

var actSuccessCallback;

var actsInfo = {};

var validators = {};

var eventActs = {};

  function generateValidator(selector, options) {
    options = options || {};

    if(options["ajax"] == true) {
      validators[selector] = $(selector).validate(
            { submitHandler: function(form) {
              // do nothing
              }
          }); 

      $(selector).submit(function() { 
        console.log("submitting");
            var obj = $(this);
            if(validators[selector].numberOfInvalids() == 0) {
              obj.find('.form-success').remove();
              obj.find('.form-failure').remove();
              obj.find("[type='submit']").after("<div class='form-load'>&#8634;</div>");
              obj.find("select[name*=4i], select[name*=5i]").each(function() {
                if($(this).val() === "")
                  $(this).parent().find("select,input").attr("disabled","disabled");
              });
              obj.find(".datetime-hidden").each(function() {
                if($(this).val() === "")
                  $(this).attr("disabled","disabled");
              });
            }
            obj.ajaxSubmit({
                dataType:'json',
                beforeSubmit: function() {
                                return (validators[selector].numberOfInvalids() == 0);
                              },
                beforeSerialize:  function() {
                                    var actIDs = obj.find(".act-names").val().split(",");
                                    var htmlStr = ""
                                    for (var i in actIDs) {
                                      htmlStr += "<input checked='checked' type='checkbox' id='event_act_ids_" + actIDs[i] + "' name='event[act_ids][]' value='" + actIDs[i] + "'/>"
                                    }
                                    obj.find(".act-inputs").html(htmlStr);
                                  },
                success:  function(data) {
                            console.log(data);
                            //if raw event submission
                            if(data.event_id) {
                              obj.find('.form-load').remove();
                              obj.parents(".event-element").slideUp();
                              obj.parents(".event-element").after("<a style='margin:20px 0;display:block;' href='/?event_id=" + data.event_id + "'>" + data.event_title + " created</a>");
                            } else if (data.result === true) {
                              obj.find('.form-load').after("<div class='form-success'>&#10003;</div>").remove();
                              
                            } else if (data.result === false) {
                              obj.find('.form-load').after("<div class='form-failure'>&#10799;</div>").remove();
                            }
                          }
            }); 
            return false; 
      });
    } else {
      validators[selector] = $(selector).validate(); 

      // $(selector).submit(function() { 
      //   if(validators[selector].numberOfInvalids() == 0) {
      //     $(this).find("select[name*=4i], select[name*=5i]").each(function() {
      //       if($(this).val() === "")
      //         $(this).parent().find("select,input").attr("disabled","disabled");
      //     });
      //     $(this).find(".datetime-hidden").each(function() {
      //       if($(this).val() === "")
      //         $(this).attr("disabled","disabled");
      //     });
      //   }
      // });
    }
  }


  $.fn.incomingForm = function() {  
    
    var obj = this; 

    this.find(".toggle-recurring input").attr('checked', false);
    this.find(".new-recurrence select, .new-recurrence input").attr('disabled','disabled');
    this.find(".toggle-recurring input").change(function() {
      console.log("toggled");
      if($(this).attr('checked')) {
        $(this).parent().siblings(".new-occurrence").find("select, input").attr('disabled','disabled');
        $(this).parent().siblings(".new-recurrence").find("select, input").removeAttr('disabled');
      } else {
        $(this).parent().siblings(".new-recurrence").find("select, input").attr('disabled','disabled');
        $(this).parent().siblings(".new-occurrence").find("select, input").removeAttr('disabled');
      }
      $(this).parent().siblings(".new-occurrence").toggle();
      $(this).parent().siblings(".new-recurrence").toggle();
    });

    // $("#form_events .new-occurrence .field select[name*=4i], #form_events .new-occurrence .field select[name*=5i]").val("");

    this.find(".new-recurrence select[name*=interval]").change(function() {
      $(this).siblings(".recur-parameter").hide();
      switch($(this).val())
      {
        case "0":
          $(this).siblings(".recur-parameter.day").show(); break;
        case "1":
          $(this).siblings(".recur-parameter.day-of-week").show(); break;
        case "2":
          $(this).siblings(".recur-parameter.day-of-month").show(); break;
        case "3":
          $(this).siblings(".recur-parameter.day-of-week").show();
          $(this).siblings(".recur-parameter.week-of-month").show(); break;
      }
    });

    this.find(".new-recurrence select[name*=interval]").change();

    // $("#form_events .main.event.new input.title").change(function() {
    //   if($(this).val() == "") {
    //     $(this).removeClass("required");
    //     $(this).parent().find(".start-time").removeClass("required");
    //     // $("#form_events .main.event.new .start-time").removeClass("required");
    //   } else {
    //     $(this).addClass("required");
    //     $(this).parent().find(".start-time").addClass("required");
    //     // $("#form_events .main.event.new .start-time").addClass("required");
    //   }
    // });

    // $("#form_events .main.event.new input.title").change();

    this.find(".datetime-input").datetimepicker({
      ampm: true,
      dateFormat: 'D M d, yy',
      timeFormat: 'h:mm tt',
      separator: ' at '
    });

    this.find(".time-input").timepicker({
      ampm: true,
      timeFormat: 'h:mm tt'
    });

    this.find(".datetime-input").change(dateTimeChange);
    this.find(".datetime-input").blur(dateTimeChange);

    this.find(".time-input").change(timeChange);
    this.find(".time-input").blur(timeChange);

    this.find("textarea.cleditor").cleditor({
      controls:     "bold italic underline size " +
                    " | bullets numbering | undo redo | " +
                    "rule image link unlink | source",   
      sizes:        "1,2,3,4,5,6,7",
      bodyStyle:    // style to assign to document body contained within the editor
                    "margin:4px; font:10pt Arial,Verdana; cursor:text"
    });

    var actNames = this.find(".act-names");
    actNames.select2({
      minimumInputLength:2,
      multiple:true,
      //placeholder:"search performers",
      ajax: {
                url: "/venues/actFind",
                dataType: 'json',
                data: function (term) {
                    return {
                        contains: term
                    };
                },
                results: function(data) {
                    for(var i in data) {
                      if(typeof actsInfo[data[i].id] === 'undefined') {
                        actsInfo[data[i].id] = { tags: data[i].tags };
                      }
                    }
                    return { results: data };
                }
            },
      initSelection : function (element) {
        var data = [];
        var sibling = element.siblings(".act-inits");
        $(element.val().split(",")).each(function (index) {
            data.push({id: this, text: sibling.find(":nth-child(" + (index + 1) + ")").html() });
        });
        return data;
      },
      formatInputTooShort : function (input, min) { 
        var eventID = actNames.attr("event-id");
        return "Please enter " + (min - input.length) + " more characters. <button onclick='showActsMode(" + eventID + ");'>Create New Performer</button>"; 
      },
      formatNoMatches : function () {
        var eventID = actNames.attr("event-id");
        return "No matches found. <button onclick='showActsMode(" + eventID + ");'>Create New Performer</button>";
      }
    });
    
    actNames.bind("change", function() {
      actsChange(this);
    });

    eventActs[actNames.attr("event-id")] = actNames.val();

    return this;

  };

  function actsChange(obj) {
    // console.log("actsChange");
    var newActs = $(obj).val().split(",");
    if(newActs[0] == "")
      newActs = [];

    var oldActs = eventActs[$(obj).attr("event-id")].split("");

    var addedActs = [];
    for(var i in newActs) {
      if($.inArray(newActs[i], oldActs) === -1)
        addedActs.push(newActs[i]);
    }

    // console.log("oldActs");
    // console.log(oldActs);
    // console.log("newActs");
    // console.log(newActs);
    // console.log("addedActs");
    // console.log(addedActs);

    for(var i in addedActs) {
      var actTags = actsInfo[parseInt(addedActs[i])].tags.split(",");
      // console.log("actTags");
      // console.log(actTags);
      for(var j in actTags) {
        $(obj).parents(".event-element").find("#event_" + $(obj).attr("event-id") + "_tag_ids_" + actTags[j]).prop("checked", true);
      }
    }
    eventActs[$(obj).attr("event-id")] = $(obj).val();
  }

  function showActsMode(eventID,actID,successFunction) {
    var actSuffix = (typeof actID !== 'undefined' ? "/" + actID : "");
    $.get('/venues/actsMode' + actSuffix, function(data) {
      $('.acts.mode .window').html(data);
      if(typeof eventID !== 'undefined' || eventID === null)
        $('#act-form').attr('event-id',eventID);

      actSuccessCallback = successFunction;

      $('.acts.mode').show();
    });
  }

  function hideActsMode() {
    $('.acts.mode').hide();
  }

  function dateTimeChange() {
    var date = $(this).datetimepicker("getDate");
    $(this).siblings(".datetime-hidden").val(date ? date.toString("yyyy-MM-ddTHH:mm:ss") : "");
  }

  function timeChange() {
    var date = $(this).datetimepicker("getDate");
    $(this).siblings(".time-hidden").val(date ? date.toString("yyyy-MM-ddTHH:mm:ss") : "");
  }

  $(function() {
    $("body").incomingForm();

    $('.slide-out-div').tabSlideOut({
        tabHandle: '.handle',                     //class of the element that will become your tab
        pathToTabImage: '/assets/feedback_tab_v.jpg', //path to the image for the tab //Optionally can be set using css
        imageHeight: '122px',                     //height of tab image           //Optionally can be set using css
        imageWidth: '40px',                       //width of tab image            //Optionally can be set using css
    });

    $('body').on("click", ".select2-search-choice", function(event) {
      console.log("act click");
      var eventID = $(this).parents(".acts.field").find(".act-names").attr("event-id");
      //ugggggggg
      var actID = $(this).parents(".acts.field").find(".act-names").val().split(",")[$(this).index()];
      console.log(actID);
      showActsMode(eventID,actID);
    });

    $('body').on("click", ".delete-raw-event", function() {
        var obj = $(this);
        $.getJSON("/venues/deleteRawEvent/" + obj.attr('rawEventId'), function() {
          console.log("deleted");
          obj.parents(".event-element").slideUp();
          return false;
        });
        return false;
      });

    $('body').on("click", ".delete-event", function() {
        if(confirm("Are you sure you want to delete this event?")) {
          var obj = $(this);
          $.getJSON("/venues/deleteEvent/" + obj.attr('eventId'), function() {
            console.log("deleted");
            obj.parents(".event-element").slideUp();
            return false;
          });
          return false;
        } else {
          return false;
        }
      });
  });