class AdminController < ApplicationController
  # every controller inherited from AdminController will be authenticated before action and using admin layout
  layout "admin"
  before_action :authenticate_admin!

  def index
    @orders = Order.where(fulfilled: false).order(created_at: :desc).take(5)

    today_orders = Order.where(created_at: Time.now.midnight..Time.now)
    total_revenue = today_orders.sum(:total)
    order_count = today_orders.count

    @quick_stats = {
      sales: order_count,
      revenue: total_revenue.round(),
      avg_sale: order_count > 0 ? (total_revenue / order_count).round() : 0,
      per_sale: OrderProduct.joins(:order)
                            .where(orders: { created_at: Time.now.midnight..Time.now })
                            .average(:quantity) || 0
    }

    @orders_by_day = Order.where("created_at > ?", Time.now - 7.days).order(:created_at)
    @orders_by_day = @orders_by_day.group_by { |order| order.created_at.to_date }
    @revenue_by_day = @orders_by_day.map { |day, orders| [ day.strftime("%A"), orders.sum(&:total) ] }

    if @revenue_by_day.count < 7
      days_of_week = [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]
      data_hash = @revenue_by_day.to_h
      current_day = Date.today.strftime("%A")
      current_index_day = days_of_week.index(current_day)
      next_day_index = (current_index_day + 1) % days_of_week.length

      ordered_days_with_current_last = days_of_week[next_day_index..-1] + days_of_week[0...next_day_index]
      completed_ordered_arr_with_current_last = ordered_days_with_current_last.map { |day| [ day, data_hash.fetch(day, 0) ] }
      @revenue_by_day = completed_ordered_arr_with_current_last
    end
  end
end
