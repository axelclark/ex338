const handleSportChange = e => {
  const allTables = document.querySelectorAll(".fantasy-player-collection");
  allTables.forEach(table => (table.style.display = "none"));

  const sportAbbrev = e.target.value;
  if (sportAbbrev) {
    const sportTable = document.getElementById(sportAbbrev);
    sportTable.style.display = "";
  } else {
    allTables.forEach(table => (table.style.display = ""));
  }
};

const sportSelect = document.getElementById("sport-filter");

if (sportSelect) {
  sportSelect.onchange = event => handleSportChange(event);
}
