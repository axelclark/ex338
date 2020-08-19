const sportSelect = document.querySelector(".sports-select-filter")

if (sportSelect) {
  sportSelect.onchange = filterPlayers
}
const playerOptions = document.querySelectorAll(".players-to-filter option")

const players = Array.from(playerOptions)

function filterPlayers(event) {
  const sportAbbrev = event.target.value

  const playersSelect = document.querySelector(".players-to-filter")

  removePlayerOptions(playersSelect)

  const filteredPlayers = players.filter((player) => {
    return player.className === sportAbbrev
  })

  filteredPlayers.forEach(function (player) {
    const newPlayer = player.cloneNode(true)
    playersSelect.appendChild(newPlayer)
  })

  playersSelect.options[0].selected = true
}

function removePlayerOptions(selectElement) {
  while (selectElement.firstChild) {
    selectElement.removeChild(selectElement.firstChild)
  }
}
