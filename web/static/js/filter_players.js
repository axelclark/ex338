var $ = require('jquery');

$(document).ready(function() {
  
  $('#draft_pick_fantasy_player_id').find("option").each(function(){
    var txt = $(this).text();
    var player_array = txt.split(" ");
    var league = player_array[player_array.length -1];
    $(this).addClass(league);
  });
  
  var allOptions = $('#draft_pick_fantasy_player_id option');

  $('#draft_pick_sports_league').change(function () {
    $('#draft_pick_fantasy_player_id option').remove()
    var sportsLeague = $('#draft_pick_sports_league option:selected').prop('text');
    var opts = allOptions.filter('.' + sportsLeague);
    $.each(opts, function (i, j) {
      $(j).appendTo('#draft_pick_fantasy_player_id');
    });

    $('#draft_pick_fantasy_player_id option:eq(0)').prop('selected', true);
  });
});
