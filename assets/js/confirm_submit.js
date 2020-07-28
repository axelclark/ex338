const formToConfirm = document.getElementById("js-confirm-submit")

const confirmSubmit = function () {
  if (confirm("Do you really want to submit the pick?")) return true
  else return false
}

if (formToConfirm) {
  formToConfirm.onsubmit = confirmSubmit
}
