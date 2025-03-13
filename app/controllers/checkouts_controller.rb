class CheckoutsController < ApplicationController
  def create
    puts "hit create"
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :stripe_secret_key)
    Stripe.api_key = stripe_secret_key
    cart = params[:cart]
    line_items = cart.map do |item|
      product = Product.find(item["id"])
      product_stock = product.stocks.find { |ps| ps.size == item["size"].to_i }
      if product_stock.amount < item["quantity"].to_i
        render json: { error: "Not enough stock available for #{product.name} in size #{item["size"]}. Only #{product_stock.amount} left" }, status: 400
        return
      end
      {
        quantity: item["quantity"].to_i,
        price_data: {
          product_data: {
            name: item["name"],
            metadata: {
              product_id: product.id, size: item["size"], product_stock_id: product_stock.id
            }
          },
          currency: "usd",
          unit_amount: item["price"].to_i
        }
      }
    end

    session = Stripe::Checkout::Session.create({
                                                 mode: "payment",
                                                 line_items: line_items,
                                                 success_url: "http://localhost:3000/success?session_id={CHECKOUT_SESSION_ID}",
                                                 cancel_url: "http://localhost:3000/cancel",
                                                 shipping_address_collection: {
                                                   allowed_countries: [ "US", "CA" ]
                                                 }
                                               })
    render json: { url: session.url }
  end

  def success
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :stripe_secret_key)
    Stripe.api_key = stripe_secret_key
    session_id = params[:session_id]
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)

    line_items = Stripe::Checkout::Session.list_line_items(session_id)
    puts checkout_session
    @order = {
      customer: {
        name: checkout_session.customer_details.name,
        email: checkout_session.customer_details.email,
        address: checkout_session.customer_details.address
      },
      items: line_items.data.map do |item|
        price = Stripe::Price.retrieve(item.price.id)

        product_id = price.product
        stripe_product = Stripe::Product.retrieve(product_id)

        local_product = Product.find_by(id: stripe_product.metadata["product_id"])
        {
          name: item.description,
          quantity: item.quantity,
          price: (item.amount_total.to_f / 100).round(2),
          image_url: local_product&.images&.attached? ? Rails.application.routes.url_helpers.rails_blob_url(local_product.images.first, host: "http://localhost:3000") : "https://placehold.co/500"

        }
      end,
      total_amount: (checkout_session.amount_total.to_f / 100).round(2),
      currency: checkout_session.currency.upcase
    }

    render :success
  end

  def cancel
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :stripe_secret_key)
    Stripe.api_key = stripe_secret_key
    session_id = params[:session_id]

    if session_id.present?
      checkout_session = Stripe::Checkout::Session.retrieve(session_id)
      customer_details = checkout_session.customer_details

      @order = {
        customer: {
          name: customer_details.name,
          email: customer_details.email
        },
        session_id: session_id
      }
    else
      @order = { session_id: nil, customer: { name: "Unknown", email: "N/A" } }
    end

    render :cancel
  end

end
