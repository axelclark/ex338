const losingTeamSelects = document.querySelectorAll(".losing-team")

losingTeamSelects.forEach(function (item) {
  item.onchange = filterOptions
})

function filterOptions(event) {
  filterPlayers(event)
  filterFuturePicks(event)
}

// Players

const playersForTrade = [].slice.call(
  document.querySelectorAll(
    "#trade_trade_line_items_0_fantasy_player_id option"
  )
)

function filterPlayers(event) {
  const lineItemNum = extractLineItem(event.target.id)
  const playerId =
    "#trade_trade_line_items_" + lineItemNum + "_fantasy_player_id"
  const selectPlayersToChange = document.querySelector(playerId)

  removePlayerOptions(selectPlayersToChange)

  restorePlayersPrompt(selectPlayersToChange)

  const selectedTeamArray = [].slice.call(event.target.selectedOptions)
  const selectedTeam = selectedTeamArray.pop()
  const filteredPlayers = playersForTrade.filter(filterThePlayers(selectedTeam))

  filteredPlayers.forEach(function (player) {
    const newPlayer = player.cloneNode(true)
    selectPlayersToChange.appendChild(newPlayer)
  })

  selectPlayersToChange.options[0].selected = true
}

function removePlayerOptions(selectPlayersToChange) {
  while (selectPlayersToChange.firstChild) {
    selectPlayersToChange.removeChild(selectPlayersToChange.firstChild)
  }
}

function restorePlayersPrompt(selectPlayersToChange) {
  const opt = document.createElement("option")
  opt.value = ""
  opt.innerHTML = "Select the player to trade"
  selectPlayersToChange.appendChild(opt)
}

function filterThePlayers(selectedTeam) {
  return function (element) {
    if (element.className) {
      return element.className === selectedTeam.className
    } else {
      return false
    }
  }
}

// Future Picks

const futurePicksForTrade = [].slice.call(
  document.querySelectorAll("#trade_trade_line_items_0_future_pick_id option")
)

function filterFuturePicks(event) {
  const lineItemNum = extractLineItem(event.target.id)
  const futurePickId =
    "#trade_trade_line_items_" + lineItemNum + "_future_pick_id"

  const selectFuturePicksToChange = document.querySelector(futurePickId)
  const futurePicksToChange = document.querySelectorAll(
    futurePickId + " option"
  )

  removeFuturePicksOptions(selectFuturePicksToChange)
  restoreFuturePicksPrompt(selectFuturePicksToChange)

  const selectedTeamArray = [].slice.call(event.target.selectedOptions)
  const selectedTeam = selectedTeamArray.pop()
  const filteredFuturePicks = futurePicksForTrade.filter(
    filterTheFuturePicks(selectedTeam)
  )

  filteredFuturePicks.forEach(function (pick, index) {
    const newPick = pick.cloneNode(true)
    selectFuturePicksToChange.appendChild(newPick)
  })

  selectFuturePicksToChange.options[0].selected = true
}

function removeFuturePicksOptions(selectFuturePicksToChange) {
  while (selectFuturePicksToChange.firstChild) {
    selectFuturePicksToChange.removeChild(selectFuturePicksToChange.firstChild)
  }
}

function restoreFuturePicksPrompt(selectFuturePicksToChange) {
  const opt = document.createElement("option")
  opt.value = ""
  opt.innerHTML = "Select the future draft pick to trade"
  selectFuturePicksToChange.appendChild(opt)
}

function filterTheFuturePicks(selectedTeam) {
  return function (element) {
    if (element.className) {
      return element.className === selectedTeam.className
    } else {
      return false
    }
  }
}

// Helpers

function extractLineItem(targetId) {
  return parseInt(targetId.replace(/[^0-9\.]/g, ""), 10)
}
