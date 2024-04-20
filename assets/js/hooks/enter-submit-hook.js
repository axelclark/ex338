const EnterSubmitHook = {
  mounted() {
    this.el.addEventListener("keydown", (e) => {
      if (e.key == "Enter" && e.shiftKey == false) {
        this.el.form.dispatchEvent(
          new Event("submit", { bubbles: true, cancelable: true })
        )
        this.el.value = ""
      }
    })
  },
}

export default EnterSubmitHook
