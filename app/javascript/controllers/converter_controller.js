import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "form"]

  connect() {
    if (this.inputValue === "") {
      this.inputTarget.value = this.sessionStorageValue
    }

    if (this.inputValue !== "") {
      this.submit()
    }
  }

  convert(event) {
    if (this.inputValue !== this.sessionStorageValue) {
      this.submit()
    }
  }

  submit() {
    this.save()
    this.outputTarget.querySelector("pre").classList.add("bg-gray-100", "animate-pulse", "duration-75")
    this.formTarget.requestSubmit()
  }

  async copy(event) {
    await navigator.clipboard.writeText(document.getElementById("output-copy").value)

    const button = (event.target instanceof HTMLButtonElement) ? event.target : event.target.closest("button")

    button.querySelector(".fa-copy").classList.add("hidden")
    button.querySelector(".fa-circle-check").classList.remove("hidden")

    setTimeout(() => {
      button.querySelector(".fa-copy").classList.remove("hidden")
      button.querySelector(".fa-circle-check").classList.add("hidden")
    }, 1000)
  }

  save() {
    sessionStorage.setItem("input", this.inputValue)
  }

  get inputValue() {
    return this.inputTarget.value.trim()
  }

  get sessionStorageValue() {
    return sessionStorage.getItem("input")
  }
}
