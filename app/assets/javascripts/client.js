var Common = (function() {
 var p = {};
 
 p.pluralize = function(word, count) {
   if (count > 1)
     return word + "s";
   return word;
 };
 
 return p;
}());

var RecentUploads = (function($, Common) {
 var p = {};
 var itemTemplate = '<li class="uploads-list-item"></li>';
 var $list;
 var items = 0;
 var maxItems = 8;
 
 p.init = function($container) {
   $container.append('<ol class="uploads-list"></ol>');
   $list = $(".uploads-list", $container);
   
   for (var i=0; i<uploads.length; i++) {
     this.add(uploads[i].id, uploads[i].type, uploads[i].name, uploads[i].is_public, uploads[i].pass, uploads[i].created_at);
   }
 };
 
 p.add = function(id, type, name, is_public, pass, time) {
   $("#intro").hide();
   
   var stripped_name = stripExtension(name);
   if (items >= maxItems) {
     $(".uploads-list-item:last").remove();
     items--;
   }
   var link = "/" + id;
   if (type == "Pack") {
     link = "/packs" + link;
   }
   
   var priv = "";
   if (!is_public) {
     link += "?pass=" + pass;
     priv = " private";
   }

   var anonymousWarning = "";
   if (!loggedIn) {
     anonymousWarning = "Please login to not lose your uploads.";
   }

   $list.prepend('<li class="uploads-list-item' + priv + '"><a href="' + link + '" title="' + anonymousWarning + '"><span class="list-block"></span><span class="map-name">' + stripped_name + '</span><span class="time-ago">' + timeAgo(time) + '</span></a></li>').find('a').tipsy({gravity: 'n'});

   $(".uploads-list-item:first", $list).hide().fadeIn(400, function() {
     $(this).css('display', 'inline-block');
   });
   items++;
 };
 
 p.updateUploadsState = function(uploads) {
   // var $status = $("#upload-status-text");
   // 
   // var text = "";
   // if (uploads > 0)
   //   var text = uploads + " " + Common.pluralize('upload', uploads) + " in progress";
   //   
   // if (uploads == 0) {
   //   $status.fadeOut(function() {
   //     $status.text(text);
   //   });
   // }
   // 
   // if (uploads > 0) {
   //   $status.text(text);
   //   $status.fadeIn();
   // }
 };
 
 function timeAgo(seconds) {
   var date = new Date();
   var diff = date.getTime()/1000 - seconds;

   var years = Math.floor(diff / (60*60*24*365));
   if (years > 0)
     return years + " " + Common.pluralize('year', years) + " ago";
   var months = Math.floor(diff / (60*60*24*30));
   if (months > 0)
     return months + " " + Common.pluralize('month', months) + " ago";
   var days = Math.floor(diff / (60*60*24));
   if (days > 0)
     return days + " " + Common.pluralize('day', days) + " ago";
   var hours = Math.floor(diff / (60*60));
   if (hours > 0)
     return hours + " " + Common.pluralize('hour', hours) + " ago";
   var minutes = Math.floor(diff / (60));
   if (minutes > 0)
     return minutes + " " + Common.pluralize('min', minutes) + " ago";
   return "Just now";
 }
 
 function stripExtension(filename) {
   return filename.replace(/\.SC2Replay/i, "");
 }
 
 return p;
}(jQuery, Common));

var UI = (function($) {
 var p = {};
 
 p.prettify = function() {
   buttons();
   tips();
   tabs();
   
   triggers();
 }
 
 function buttons() {
   // $("#upload-button").button();
   // $(".details-button").button();
   // $(".download-button").button();
   // $("#comment_submit").button();
   // $("#search-button").button();
   // $("#account-login-button").button();
   // $(".read-button").button();
   // $("#confirm-email-button").button();
   // $("#confirm-nick-button").button();
   // $("#twitter-settings-button").button();
   // $("#add-twitter-button").button();
   // $("#facebook-settings-button").button();
   // $("#add-facebook-button").button();
   //$("#show-key").button();
   
   $(".uploads-list-item a").live('mouseover mouseout', function(event) {
     if (event.type == 'mouseover') {
       $(".list-block", this).addClass('hover');
     } else {
       $(".list-block", this).removeClass('hover');
     }
   });
 }
 
 function tips() {
   $("#clippy_tooltip_download_url_clippy").tipsy({gravity: 's'});
   $(".make-private label").tipsy({gravity: 'w', offset: 30});
   $(".player-tip").tooltip({track: true, delay: 50, top: -80, left: -50, showURL: false, showBody: " - "});
   $(".player-tip-apm").tooltip({track: true, delay: 50, top: -120, left: -50, showURL: false, showBody: " - "});
   $("#fb-link").tooltip({track: true, showURL: false, showBody: " - "});
   $("#twitter-link").tooltip({track: true, showURL: false, showBody: " - "});
   // $("#upload-button").tipsy({gravity: 'e'});
 }
 
 function tabs() {
   $("#replay-tabs").tabs();
   $("#profile-tabs").tabs();
 }
 
 function triggers() {
   $("#show-winner").click(function() {
     $winner = $("div .winner");
     if ($winner.length == 0) {
       $(this).parent().text('Winner: draw or unknown');
       $(this).remove();
     }
     else
       $winner.css({ border: "2px solid green" });
       
     return false;
   });
     
   $("#search-link").click(function() {
     $(".search").slideToggle();
     return false;
   });
   
   $("#show-pack-edit").click(function() {
     $("#pack-edit").slideToggle();
     return false;
   });
   
   $("#show-splash").click(function() {
     $("#youtube-splash").slideToggle();
     return false;
   });
   
   $("#show-key").click(function() {
     $("#key").slideToggle();
     return false;
   });
 }
 
 return p;
}(jQuery));

// TODO: hack for now
function updateHTML(elmId, value) {
  document.getElementById(elmId).innerHTML = value;
}

function onPlayerError(errorCode) {
  alert("An error occured of type:" + errorCode);
}

// http://code.google.com/apis/youtube/js_api_reference.html
function onYouTubePlayerReady(playerId) {
  if(playerId == "player0") {
    ytplayer0 = document.getElementById("ytPlayer0");
    ytplayer0.addEventListener("onError", "onPlayerError");
    ytplayer0.setPlaybackQuality("small");
    ytplayer0.cueVideoByUrl($("#player0wrapper").attr('data_video_id'));
  }
  else if(playerId == "player1") {
    ytplayer1 = document.getElementById("ytPlayer1");
    ytplayer1.addEventListener("onError", "onPlayerError");
    ytplayer1.setPlaybackQuality("hd720");
    ytplayer1.cueVideoById($("#player1wrapper").attr('data_video_id'));
  }
}

function loadPlayers() {
  var params = { allowScriptAccess: "always", allowFullScreen: "true" };
  var atts = { id: "ytPlayer0" };
  swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&playerapiid=player0", 
          "player0container", "720", "443", "8", null, null, params, atts);

  // Now do it all again with a different player
  var params = { allowScriptAccess: "always", allowFullScreen: "true" };
  var atts = { id: "ytPlayer1" };
  swfobject.embedSWF("http://www.youtube.com/apiplayer?&enablejsapi=1&playerapiid=player1", 
          "player1container", "720", "443", "8", null, null, params, atts);
}


$(document).ready(function() {  
  $(".minibutton").each(function(index) {
    var t = $(this).text();
    $(this).text('').append('<span>' + t + '</span>');
  });
  // $('.replay').hover(function() {
  //   $(this).addClass("hover");
  // }, function() {
  //   $(this).removeClass("hover");
  // });
  
  if (BrowserDetect.browser == 'Explorer' && BrowserDetect.version < 10.0) {

    $("#browser-warning").append('Inferior browser experience detected. <span style="border-bottom: 1px dashed gray;" title="We have detected a browser which doesn\'t support the drag&drop feature. Also, with Internet Explorer, the UI looks bad. We highly recommend installing Google Chrome or Mozilla Firefox.">What is this?</span>');
    
    $("#browser-warning span").tipsy({gravity: 'n'});
    $("#browser-warning").show();
  }
  
  // Player search autocomplete
  $('#player_name, #player').bind('railsAutocomplete.select', function() { 
    var v = $(this).val();
    $(this).val(v.replace(/ .*/, ""));
  });  
  
 $("#url_field").click(function() {
   $(this).focus();
   $(this).select();
 });
 
 if ($("#recent-uploads").length > 0) 
  RecentUploads.init($("#recent-uploads"));
  
 UI.prettify();
 
 if ($("#file-uploader").length > 0) {
   var make_private = false;
   var uploader = new qq.FileUploader({
      // pass the dom node (ex. $(selector)[0] for jQuery users)
      element: document.getElementById('file-uploader'),
     button: $("#upload-button")[0],
     listElement: $("#file-upload-list")[0],
      // path to server-side upload script
      action: '/upload',
     allowedExtensions: ['SC2Replay', 'zip', 'tar', '7z'],
     sizeLimit: 35000000,
     onSubmit: function(id, fileName) {
       RecentUploads.updateUploadsState(uploader._filesInProgress+1);
       uploader.setParams({
         original_filename: fileName,
         is_public: !make_private
       });
       $("#file-upload-list-container").fadeIn();
     },
     onComplete: function(id, fileName, responseJSON) {        
       RecentUploads.updateUploadsState(uploader._filesInProgress);
       if (uploader._filesInProgress == 0)
        $("#file-upload-list-container").fadeOut();
       var item = uploader._getItemByFileId(id);
       $(item).fadeOut(function() {
         qq.remove(item);
         var date = new Date();
         RecentUploads.add(responseJSON.id, responseJSON.type, fileName, responseJSON.is_public, responseJSON.pass, responseJSON.created_at);
       });
     },
     debug: false
   });
 
   var editor = new Editor(uploader);  
 }
 
 $("#file-uploader a").live('click', function() {
   $("#content").fadeOut();
 });
 
 $("#make-private").change(function() {
   if ($("#make-private:checked").val() !== undefined) {
     make_private = true;
   } else {
     make_private = false;
   }
 });
});

function clippyCopiedCallback(a) {
    var d = $("#clippy_tooltip_" + a);
    if (d.length != 0) {
        d.attr("title", "copied!").tipsy("hide").tipsy("show");
       setTimeout(function() {
         d.attr("title","copy to clipboard")
         },
         500);
    }
};