class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :authorize_csv_exports
  protect_from_forgery
  helper_method :current_cart
  helper_method :raise_unless_admin!

  private

  def current_cart
    puts session[:cart_id]
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end

  def authorize_csv_exports
    # sellers are not allowed to do that
    authorize!(:export, :report) if request.format.try(:symbol) == :csv
  end

  def raise_unless_admin!
    raise CanCan::AccessDenied.new("Access denied") unless current_user.admin?
  end
end
