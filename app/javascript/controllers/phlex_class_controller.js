import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  toggle(event) {
    if (event.target.checked) {
      this.toggleTarget.classList.remove("hidden")
    } else {
      this.toggleTarget.classList.add("hidden")
    }
  }
}
