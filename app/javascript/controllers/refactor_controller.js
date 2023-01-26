import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"

export default class extends Controller {
  static targets = ["input", "output", "form"]

  refactor(event) {
    event.preventDefault()
    this.outputTarget.classList.remove("hidden")

    this.layoutElement.classList.remove("sm:grid-cols-2")
    this.layoutElement.classList.add("sm:grid-cols-3")

    this.submit()
  }

  close(event) {
    event.preventDefault()

    this.outputTarget.classList.add("hidden")
    this.layoutElement.classList.add("sm:grid-cols-2")
    this.layoutElement.classList.remove("sm:grid-cols-3")

    this.outputTarget.querySelector("#refactored-output").innerHTML = ""
  }

  submit() {
    this.outputTarget.querySelector("pre").classList.add("bg-gray-100", "animate-pulse", "duration-75")

    patch(this.formTarget.action, {
      body: { code: this.inputValue },
      responseKind: "turbo-stream"
    })
  }

  async copy(event) {
    event.preventDefault()

    await navigator.clipboard.writeText(document.getElementById("refactored-output-copy").value)

    const button = (event.target instanceof HTMLButtonElement) ? event.target : event.target.closest("button")

    button.querySelector(".fa-copy").classList.add("hidden")
    button.querySelector(".fa-circle-check").classList.remove("hidden")

    setTimeout(() => {
      button.querySelector(".fa-copy").classList.remove("hidden")
      button.querySelector(".fa-circle-check").classList.add("hidden")
    }, 1000)
  }

  get inputValue() {
    return this.inputTarget.value.trim()
  }

  get layoutElement() {
    return document.querySelector("#layout")
  }
}
