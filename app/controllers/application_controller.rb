class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  protect_from_forgery
  helper_method :current_cart

  private

  def current_cart
    puts session[:cart_id]
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end
end
