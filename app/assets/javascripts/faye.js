$(function() {
  var faye = new Faye.Client('http://localhost:9292/faye');
  faye.subscribe("/downloads/new", function(data) {
    $("#total_downloads span").text(data['count']).fadeOut('fast').fadeIn('fast');
  });
});