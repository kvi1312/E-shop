import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["count"];

  connect() {
    this.updateCartCount();
    document.addEventListener("cart:updated", this.updateCartCount.bind(this));
  }

  disconnect() {
    document.removeEventListener("cart:updated", this.updateCartCount.bind(this));
  }

  updateCartCount() {
    const cart = JSON.parse(localStorage.getItem("cart")) || [];
    const count = cart.reduce((sum, item) => sum + item.quantity, 0);

    if (this.hasCountTarget) {
      if (count > 0) {
        this.countTarget.textContent = count;
        this.countTarget.classList.remove("hidden");
      } else {
        this.countTarget.classList.add("hidden");
      }
    }
  }
}
