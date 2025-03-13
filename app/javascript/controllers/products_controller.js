import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
    static values = {size: String, product: Object} // => this will generate var productValue and sizeValue
    connect() {
        console.log("connected controller!")
    };

    addToCart() {
        console.log(`Product:`, this.productValue)
        const cart = localStorage.getItem("cart")
        const imageUrls = this.productValue.image_urls || [];
        if (cart) {
            const cartArray = JSON.parse(cart)
            const foundIndex = cartArray.findIndex(item => item.id === this.productValue.id && item.size === this.sizeValue)
            if (foundIndex >= 0) {
                cartArray[foundIndex].quantity = parseInt(cartArray[foundIndex].quantity + 1)
            } else {
                cartArray.push({
                    id: this.productValue.id,
                    name: this.productValue.name,
                    price: this.productValue.price,
                    size: this.sizeValue,
                    quantity: 1,
                    imageUrls: imageUrls
                })
            }
            localStorage.setItem("cart", JSON.stringify(cartArray))
        } else {
            const cartArray = []
            cartArray.push({
                id: this.productValue.id,
                name: this.productValue.name,
                price: this.productValue.price,
                size: this.sizeValue,
                quantity: 1,
                imageUrls: imageUrls
            })
            localStorage.setItem("cart", JSON.stringify(cartArray))
        }
        document.dispatchEvent(new CustomEvent("cart:updated"));
    }

    selectSize(e) {
        this.sizeValue = e.target.value
        const selectedSizeEl = document.getElementById("selected-size")
        console.log(selectedSizeEl.innerText)
    }
}
