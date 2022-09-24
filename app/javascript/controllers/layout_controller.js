import { Controller } from "@hotwired/stimulus"
import { useMatchMedia } from "stimulus-use"

export default class extends Controller {

  connect() {
    useMatchMedia(this, {
      mediaQueries: {
        small: '(max-width: 769px)',
      }
    })

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
      this.layoutElement.classList.remove("sm:grid-cols-1")
      this.layoutElement.classList.add("sm:grid-cols-2")
      document.querySelector("[data-value=horizontal]").disabled = true
      document.querySelector("[data-value=vertical]").disabled = false
      document.querySelector("#input").style.height = "70vh"
    }

    if (value === "vertical") {
      this.layoutElement.classList.add("sm:grid-cols-1")
      this.layoutElement.classList.remove("sm:grid-cols-2")
      document.querySelector("[data-value=horizontal]").disabled = false
      document.querySelector("[data-value=vertical]").disabled = true
      document.querySelector("#input").style.height = "20vh"
    }
  }

  isSmall() {
    this.changeLayout("vertical")
  }

  notSmall() {
    this.changeLayout("horizontal")
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
