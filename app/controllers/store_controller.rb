class StoreController < ApplicationController

  # no auth check

  proc {|c| c.request.xhr? ? false : 'application'}

  def index
    @products = Product.search(params[:search]).order('name DESC').paginate(page: params[:page], per_page: 5)
    @cart ||= current_cart
    @cart.add_product(@products.first.id).save if @products.size == 1

    respond_to do |format|
      format.js {render js: @products}
      format.html
    end
  end

end
