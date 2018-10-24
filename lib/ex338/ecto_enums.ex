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

defenum(FantasyTeamAutodraftSettingEnum, :fantasy_team_autodraft_setting, [
  :on,
  :off,
  :single
])

defenum(HistoricalRecordTypeEnum, :historical_record_type, [
  :season,
  :all_time
])
