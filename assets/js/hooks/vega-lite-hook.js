import vegaEmbed from "vega-embed"
const VegaLiteHook = {
  mounted() {
    // This element is important so we can uniquely identify which element will be loaded
    this.props = { id: this.el.getAttribute("data-id") }
    // Handles the event of creating a graph and loads vegaEmbed targetting our main hook element
    this.handleEvent(`vega_lite:${this.props.id}:init`, ({ spec }) => {
      vegaEmbed(this.el, spec, { renderer: "svg", actions: false })
        .then((result) => result.view)
        .catch((error) => console.error(error))
    })
  },
}

export default VegaLiteHook
