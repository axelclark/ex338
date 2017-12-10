const losingTeamSelects = document.querySelectorAll(
  '.losing-team'
);

losingTeamSelects.forEach(function(item, index) {
  item.onchange = filterPlayers;
});

const playersForTrade = [].slice.call(document.querySelectorAll(
  '#trade_trade_line_items_0_fantasy_player_id option'
));

function filterPlayers(event) {
  const lineItemNum = extractLineItem(event.target.id);
  const playerId = '#trade_trade_line_items_' + lineItemNum + '_fantasy_player_id';
  const selectPlayersToChange = document.querySelector(playerId);
  const playersToChange = document.querySelectorAll(playerId + ' option');

  removePlayerOptions(selectPlayersToChange);

  const selectedTeamArray = [].slice.call(event.target.selectedOptions);
  const selectedTeam = selectedTeamArray.pop();
  const filteredPlayers = playersForTrade.filter(filterThePlayers(selectedTeam));

  filteredPlayers.forEach(function(player, index) {
    const newPlayer = player.cloneNode(true);
    selectPlayersToChange.appendChild(newPlayer);
  });

  selectPlayersToChange.options[0].selected = true;
}

function extractLineItem(targetId) {
  return parseInt(targetId.replace(/[^0-9\.]/g, ''), 10);
}

function removePlayerOptions(selectPlayersToChange) {
  while (selectPlayersToChange.firstChild) {
    selectPlayersToChange.removeChild(selectPlayersToChange.firstChild);
  }
}

function filterThePlayers(selectedTeam) {
  return function(element) {
    if (element.className) {
      return element.className === selectedTeam.className;
    } else {
      return false;
    }
  };
}
