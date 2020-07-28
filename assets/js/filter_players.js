const sportSelect = document.querySelector(".sports-select-filter")

if (sportSelect) {
  sportSelect.onchange = filterPlayers
}

function filterPlayers(event) {
  const sportAbbrev = event.target.value

  const players = Array.from(
    document.querySelectorAll(".players-to-filter option")
  )

  players.forEach((player) => {
    player.removeAttribute("hidden")

    if (player.className !== sportAbbrev) {
      player.setAttribute("hidden", "true")
    }
  })

  players[0].selected = true
  players[0].removeAttribute("hidden")
}
