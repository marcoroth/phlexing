import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = ["input", "output", "form"]

  connect() {
    this.outputTarget.classList.add("hidden")

    if (this.inputTarget.value.trim() === "") {
      this.inputTarget.value = this.sessionStorageValue
      this.convert()
    }
  }

  convert() {
    this.save()
    this.formTarget.requestSubmit()
  }

  save() {
    sessionStorage.setItem("input", this.inputTarget.value)
  }

  get sessionStorageValue() {
    return sessionStorage.getItem("input")
  }
}
