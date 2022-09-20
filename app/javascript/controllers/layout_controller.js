import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    if (this.sessionStorageValue) {
      this.changeLayout(this.sessionStorageValue)
    }
  }

  switch(event) {
    event.preventDefault()

    const button = (event.target instanceof HTMLButtonElement) ? event.target : event.target.closest('button')
    const value = button.dataset.value

    if (this.sessionStorageValue !== value) {
      this.changeLayout(value)
      this.save(value)
    }
  }

  changeLayout(value) {
    if (value === "horizontal") {
      this.layoutElement.classList.remove("grid-cols-1")
      this.layoutElement.classList.add("grid-cols-2")
      document.querySelector("[data-value=horizontal]").disabled = true
      document.querySelector("[data-value=vertical]").disabled = false
      document.querySelector("#input").rows = 40
    }

    if (value === "vertical") {
      this.layoutElement.classList.add("grid-cols-1")
      this.layoutElement.classList.remove("grid-cols-2")
      document.querySelector("[data-value=horizontal]").disabled = false
      document.querySelector("[data-value=vertical]").disabled = true
      document.querySelector("#input").rows = 10
    }
  }

  save(value) {
    sessionStorage.setItem("layout", value)
  }

  get sessionStorageValue() {
    return sessionStorage.getItem("layout")
  }

  get layoutElement() {
    return document.querySelector("#layout")
  }
}
