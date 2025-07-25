const draftPickForm = document.getElementById("draft-pick-form")

const confirmDraftPick = function () {
  const playerSelect = draftPickForm.querySelector('select[name="draft_pick[fantasy_player_id]"]')
  const selectedOption = playerSelect?.options[playerSelect.selectedIndex]
  const playerName = selectedOption?.text || "this player"
  
  if (confirm(`Do you really want to draft ${playerName}?`)) return true
  else return false
}

if (draftPickForm) {
  draftPickForm.onsubmit = confirmDraftPick
}