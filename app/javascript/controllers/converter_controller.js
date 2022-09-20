import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = ["input", "output", "form"]

  connect() {
    this.outputTarget.classList.add("hidden")
  }

  convert() {
    this.formTarget.requestSubmit()
  }
}
