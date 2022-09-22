import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "form"]

  connect() {
    if (this.inputTarget.value.trim() === "") {
      this.inputTarget.value = this.sessionStorageValue
      this.convert()
    }
  }

  convert() {
    if (this.inputTarget.value.trim() !== "") {
      this.save()

      this.outputTarget.querySelector("textarea").classList.add("bg-gray-100", "animate-pulse", "duration-75", "blur-[1px]")

      this.formTarget.requestSubmit()
    }
  }

  async copy(event) {
    await navigator.clipboard.writeText(document.getElementById("output").value)

    const button = (event.target instanceof HTMLButtonElement) ? event.target : event.target.closest("button")

    button.querySelector(".fa-copy").classList.add("hidden")
    button.querySelector(".fa-circle-check").classList.remove("hidden")

    setTimeout(() => {
      button.querySelector(".fa-copy").classList.remove("hidden")
      button.querySelector(".fa-circle-check").classList.add("hidden")
    }, 1000)
  }

  save() {
    sessionStorage.setItem("input", this.inputTarget.value)
  }

  get sessionStorageValue() {
    return sessionStorage.getItem("input")
  }
}
