class OrdersController < ApplicationController

  check_authorization
  load_and_authorize_resource

  layout ->(c) {c.request.xhr? ? false : 'application'}

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.order('id DESC').paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
      format.csv  { render csv: orders_scoped, filename: "Ordenes #{Date.today}" }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @cart ||= current_cart
    if @cart.line_items.empty?
      redirect_to store_url, notice: t('cart.emplied')
    end

    @order = Order.new
    @order.add_line_items_from_cart(current_cart)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(params[:order])
    p @order.valid?
    p @order.errors

    respond_to do |format|
      if @order.save
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        format.html { redirect_to store_url, notice: t('order.created') }
        format.json { render json: @order, status: :created, location: @order }
      else
        @cart ||= current_cart
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to @order, notice: t('order.updated') }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url, notice: t('order.destroyed') }
      format.json { head :ok }
    end
  end

  def autocomplete_for_client
    @clients = Client.with_client(params[:q])

    respond_to do |format|
      format.json { render json: @clients }
    end
  end

  private

  def orders_scoped
    if params[:month] && params[:year]
      date = Date.new(params[:year].to_i, params[:month].to_i)
      orders = Order.between(
        date.beginning_of_month, date.end_of_month.end_of_day
       )
    else
      orders = Order.scoped
    end

    orders.order('id DESC')
  end
end
