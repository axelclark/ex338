import EctoEnum

defenum(DraftQueueStatusEnum, :draft_queue_status, [
  :pending,
  :drafted,
  :unavailable,
  :archived,
  :cancelled
])

defenum(FantasyLeagueNavbarDisplayEnum, :fantasy_league_navbar_display, [
  :primary,
  :archived,
  :hidden
])
