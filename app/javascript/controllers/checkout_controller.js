import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkout"
export default class extends Controller {
    static values = {
        isSuccess: Boolean
    }

    initialize() {
        console.log("Checkout controller initialized");
    }

    connect() {
        console.log("Checkout controller connected");

        // Auto clear cart if this is the success page
        if (this.hasIsSuccessValue && this.isSuccessValue) {
            this.clearCart();
        }
    }

    clearCart() {
        localStorage.removeItem("cart");
        window.dispatchEvent(new Event("cart:updated"));
        console.log("Cart cleared from localStorage");
    }
}