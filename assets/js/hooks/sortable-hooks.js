import Sortable from "../../vendor/sortable"

Hooks.SortableInputsFor = {
  mounted() {
    let group = this.el.dataset.group
    new Sortable(this.el, {
      group: group ? { name: group, pull: true, put: true } : undefined,
      animation: 150,
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      handle: "[data-handle]",
      forceFallback: true,
      onEnd: (_e) => {
        this.el
          .closest("form")
          .querySelector("input")
          .dispatchEvent(new Event("input", { bubbles: true }))
      },
    })
  },
}

export default SortableInputsFor
