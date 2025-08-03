// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "alpinejs"
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"
import Trix from "trix"

// LiveView polyfills for IE11
import "mdn-polyfills/NodeList.prototype.forEach"
import "mdn-polyfills/Element.prototype.closest"
import "mdn-polyfills/Element.prototype.matches"
import "url-search-params-polyfill"
import "formdata-polyfill"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import "./filter_players"
import "./filter_trade_form"
import "./filter_players_list"
import "./confirm_submit"
import "./draft_pick_confirm"

import Hooks from "./hooks"
import phxFeedbackDom from "./phx_feedback_dom"

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")

// Create the custom dom handler that combines Alpine and phx-feedback-for support
const customDom = phxFeedbackDom({
  onBeforeElUpdated(from, to) {
    if (from.__x) {
      window.Alpine.clone(from.__x, to)
    }
  }
})

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  dom: customDom,
  params: { _csrf_token: csrfToken },
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (_info) => NProgress.start())
window.addEventListener("phx:page-loading-stop", (_info) => NProgress.done())

window.addEventListener(`phx:animate`, (e) => {
  let el = document.getElementById(e.detail.id)
  if (el) {
    liveSocket.execJS(el, el.getAttribute("data-animate"))
  }
})

window.addEventListener(`phx:clear-textarea`, (e) => {
  let el = document.getElementById(e.detail.id)
  el.value = ""
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
