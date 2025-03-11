class CheckoutsController < ApplicationController
  def create
    puts "hit create"
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :stripe_secret_key)
    puts stripe_secret_key
    # stripe_publish_key = Rails.application.credentials.dig(:stripe_publish_key)
    Stripe.api_key = stripe_secret_key
    cart = params[:cart]
    line_items = cart.map do |item|
      product = Product.find(item["id"])
      product_stock = product.stocks.find { |ps| ps.size == item["size"].to_i }
      puts product_stock.amount
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
                                                 success_url: "http://localhost:3000/success",
                                                 cancel_url: "http://localhost:3000/cancel",
                                                 shipping_address_collection: {
                                                   allowed_countries: [ "US", "CA" ]
                                                 }
                                               })
    render json: { url: session.url }
  end

  def success
    render :success
  end

  def cancel
    render :cancel
  end
end
