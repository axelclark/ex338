import Chart from "chart.js"

let StandingsChart = {
  buildChart() {
    let standingsDataset = document.getElementById("standings-chart-data")
      .dataset.standings
    var ctx = document.getElementById("standings-chart").getContext("2d")
    var myChart = new Chart(ctx, {
      type: "line",
      options: {
        elements: {
          line: {
            tension: 0, // disables bezier curves
          },
        },
      },
      data: {
        labels: [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ],
        datasets: JSON.parse(standingsDataset),
      },
    })
  },
}

export default StandingsChart
