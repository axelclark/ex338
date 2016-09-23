var $ = require('jquery');

$(document).ready(function() {
  
  $('.players-to-filter').find("option").each(function(){
    var txt = $(this).text();
    var player_array = txt.split(" ");
    var league = player_array[player_array.length -1];
    $(this).addClass(league);
  });
  
  var allOptions = $('.players-to-filter option');

  $('.sports-select-filter').change(function () {
    $('.players-to-filter option').remove()
    var sportsLeague = $('.sports-select-filter option:selected').prop('text');
    var opts = allOptions.filter('.' + sportsLeague);
    $.each(opts, function (i, j) {
      $(j).appendTo('.players-to-filter');
    });

    $('.players-to-filter option:eq(0)').prop('selected', true);
  });
});
