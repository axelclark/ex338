import { DateTime } from "../../vendor/luxon"
const LocalTimeHook = {
  mounted() {
    this.updated()
  },
  updated() {
    const format = this.el.dataset.format
    const preset = this.el.dataset.preset
    const locale = this.el.dataset.locale
    const dtString = this.el.textContent.trim()
    const dt = DateTime.fromISO(dtString).setLocale(locale)

    let formatted
    if (format) {
      if (format === "relative") {
        formatted = dt.toRelative()
      } else {
        formatted = dt.toFormat(format)
      }
    } else {
      formatted = dt.toLocaleString(DateTime[preset])
    }

    this.el.textContent = formatted
    this.el.classList.remove("opacity-0")
  },
}

export default LocalTimeHook
