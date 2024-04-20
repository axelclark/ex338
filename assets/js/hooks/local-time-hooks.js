const LocalTimeHook = {
  mounted() {
    this.updated()
  },
  updated() {
    let dt = new Date(this.el.textContent)
    let options = {
      timeStyle: "short",
      dateStyle: "short",
    }
    this.el.textContent = `${dt.toLocaleString("en-US", options)}`
    this.el.classList.remove("invisible")
  },
}

export default LocalTimeHook
