class ProductsController < ApplicationController

  check_authorization
  load_and_authorize_resource

  layout ->(c) { c.request.xhr? ? false : 'application'}

  # GET /products
  # GET /products.xml
  def index
    @products = Product.search(params[:search]).order('name ASC').paginate(page: params[:page], per_page: 8)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
      format.csv  { render csv: Product.order(:name), filename: "Productos #{Date.today}" }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to(@product, :notice => 'Producto creado =D') }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to(@product, :notice => 'Producto actualizado.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url, notice: 'Eliminado  ^^ ') }
      format.xml  { head :ok }
    end
  end

  def summary_sales
    @to_date = Time.zone.now
    @from_date = @to_date.beginning_of_month

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def export_summary_sales
    from_date, to_date = *make_datetime_range(params[:interval])
    products = LineItem.with_order.where(created_at: from_date..to_date)

    response.headers['cache-control'] = 'private, no-store'
    filename = "productos_vendidos_#{l(from_date.to_date)}_al_#{l(to_date.to_date)}.csv"

    send_data(
      products.to_csv,
      type: Mime::CSV,
      disposition: "attachment; filename=#{filename}"
    )
  end
end
