class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :authorize_csv_exports
  before_filter :set_paper_trail_whodunnit
  protect_from_forgery
  helper_method :current_cart
  helper_method :raise_unless_admin!

  rescue_from CanCan::AccessDenied do |exception|
    begin
      redirect_to :back, alert: 'Acceso denegado'
    rescue ActionController::RedirectBackError
      redirect_to root_url, alert: 'Acceso denegado'
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    begin
      redirect_to :back, alert: 'No encontrado'
    rescue ActionController::RedirectBackError
      redirect_to root_url, alert: 'No encontrado'
    end
  end

  def info_for_paper_trail
    { correlation_id: request.uuid }
  end

  private

  def user_for_paper_trail
    current_user.try(:id)
  end

  def current_cart
    # puts session[:cart_id]
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
