$(document).ready(function() {
  $('.rating_stars').ratings(5).bind('ratingchanged', function(event, data) {
    $('.rating_stars_to_text').text(data.rating);
  });
});