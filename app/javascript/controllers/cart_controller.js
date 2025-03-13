import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
    initialize() {
        const cart = JSON.parse(localStorage.getItem("cart")) || [];
        if (cart.length === 0) {
            this.displayEmptyCart();
            return;
        }

        const cartItemsContainer = document.getElementById("cart-items");
        let total = 0;

        for (let i = 0; i < cart.length; i++) {
            const item = cart[i];
            total += item.price * item.quantity;

            // Create cart item element
            const itemDiv = document.createElement("div");
            itemDiv.classList.add("flex", "items-center", "p-6", "hover:bg-gray-50");

            // Image container - Made taller and wider for better display
            const imageContainer = document.createElement("div");
            imageContainer.classList.add("w-24", "h-24", "flex-shrink-0", "bg-gray-100", "rounded-md", "overflow-hidden");

            // Check if there's an image available
            if (item.imageUrls && item.imageUrls.length > 0) {
                const img = document.createElement("img");
                // Use medium size if available, otherwise the original
                const imgSrc = item.imageUrls[0].medium || item.imageUrls[0].original;
                img.src = imgSrc;
                img.alt = item.name;
                // Changed to object-contain to prevent cropping
                img.classList.add("w-full", "h-full", "object-contain", "p-1");
                imageContainer.appendChild(img);
            } else {
                // Placeholder for when no image is available
                imageContainer.innerHTML = `<div class="w-full h-full flex items-center justify-center bg-gray-200">
                    <span class="text-gray-500 text-xs">No image</span>
                </div>`;
            }

            // Product details
            const details = document.createElement("div");
            details.classList.add("ml-4", "flex-1");
            details.innerHTML = `
                                <h3 class="text-lg font-medium text-gray-900">${item.name}</h3>
                                <div class="mt-2 flex text-sm text-gray-500">
                                    <p><span class="font-medium">Size:</span> ${item.size}</p>
                                </div>
                                <div class="mt-2 text-sm text-gray-500">
                                    <p><span class="font-medium">Price:</span> $${(item.price / 100).toFixed(2)}</p>
                                    <p class="mt-1"><span class="font-medium">Quantity:</span> ${item.quantity}</p>
                                </div>
                            `;

            // Action buttons with trash icon
            const actions = document.createElement("div");
            actions.classList.add("ml-4", "flex-shrink-0");

            const removeButton = document.createElement("button");
            // Using Font Awesome trash icon
            removeButton.innerHTML = `<i class="fas fa-trash-alt text-red-600 text-lg"></i>`;
            removeButton.title = "Remove item";
            removeButton.value = JSON.stringify({id: item.id, size: item.size});
            removeButton.classList.add("p-2", "hover:bg-red-50", "rounded-full", "transition");
            removeButton.addEventListener("click", this.removeFromCart);

            actions.appendChild(removeButton);

            // Assemble the item element
            itemDiv.appendChild(imageContainer);
            itemDiv.appendChild(details);
            itemDiv.appendChild(actions);

            cartItemsContainer.appendChild(itemDiv);
        }

        // Display total
        const totalEl = document.getElementById("total");
        totalEl.innerHTML = `
                                <div class="py-2 text-lg font-semibold text-gray-500">
                                    Total: <span>$${(total / 100).toFixed(2)}</span>
                                </div>
                            `;

    }

    displayEmptyCart() {
        const cartItemsContainer = document.getElementById("cart-items");
        cartItemsContainer.innerHTML = `
            <div class="p-12 text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                </svg>
                <h3 class="mt-2 text-lg font-medium text-gray-900">Your cart is empty</h3>
                <p class="mt-1 text-sm text-gray-500">Start adding some items to your cart</p>
                <div class="mt-6">
                    <a href="/" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        Continue Shopping
                    </a>
                </div>
            </div>
        `;

        // Hide checkout and clear buttons when cart is empty
        const totalEl = document.getElementById("total");
        totalEl.innerText = "";

        const checkoutBtn = this.element.querySelector("[data-action='click->cart#checkout']");
        const clearBtn = this.element.querySelector("[data-action='click->cart#clear']");

        if (checkoutBtn) checkoutBtn.classList.add("hidden");
        if (clearBtn) clearBtn.classList.add("hidden");
    }

    clear() {
        if (confirm("Are you sure you want to clear your cart?")) {
            localStorage.removeItem("cart");
            document.dispatchEvent(new CustomEvent("cart:updated"));
            window.location.reload();
        }
    }

    removeFromCart(e) {
        const cart = JSON.parse(localStorage.getItem("cart"));
        const values = JSON.parse(e.target.closest('button').value);
        const {id, size} = values;
        const index = cart.findIndex(item => item.id === id && item.size === size);

        if (index !== -1) {
            cart.splice(index, 1);
            localStorage.setItem("cart", JSON.stringify(cart));
            document.dispatchEvent(new CustomEvent("cart:updated"));
            window.location.reload();
        }
    }

    checkout() {
        const cart = JSON.parse(localStorage.getItem("cart"));

        if (!cart || cart.length === 0) {
            const errorEl = document.getElementById("errorContainer");
            errorEl.innerHTML = `<div class="p-4 bg-red-50 text-red-700 rounded-md">Your cart is empty. Please add items before checkout.</div>`;
            return;
        }

        const payload = {
            authenticity_token: "",
            cart: cart
        };

        const csrfToken = document.querySelector("[name='csrf-token']").content;

        // Show loading state
        const checkoutBtn = this.element.querySelector("[data-action='click->cart#checkout']");
        const originalText = checkoutBtn.innerText;
        checkoutBtn.innerText = "Processing...";
        checkoutBtn.disabled = true;

        fetch("/checkout", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify(payload)
        }).then(response => {
            if (response.ok) {
                response.json().then(body => {
                    window.location.href = body.url;
                });
            } else {
                response.json().then(body => {
                    const errorEl = document.getElementById("errorContainer");
                    errorEl.innerHTML = `<div class="p-4 bg-red-50 text-red-700 rounded-md">There was an error processing your order. ${body.error}</div>`;

                    // Restore button state
                    checkoutBtn.innerText = originalText;
                    checkoutBtn.disabled = false;
                });
            }
        }).catch(error => {
            const errorEl = document.getElementById("errorContainer");
            errorEl.innerHTML = `<div class="p-4 bg-red-50 text-red-700 rounded-md">Network error. Please try again.</div>`;

            // Restore button state
            checkoutBtn.innerText = originalText;
            checkoutBtn.disabled = false;
        });
    }
}