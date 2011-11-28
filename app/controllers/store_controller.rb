class StoreController < ApplicationController
  
  proc {|c| c.request.xhr? ? false : 'application'}
  
  def index
    @products = Product.order('name DESC').paginate(page: params[:page], per_page: 5)
    @products = Product.search(params[:search]).order('name DESC').paginate(page: params[:page], per_page: 5) if params[:search]
    
    @cart = current_cart
      
  end
  
  
end
