class ClientsController < ApplicationController

  check_authorization
  load_and_authorize_resource

  layout ->(c) {c.request.xhr? ? false : 'application'}

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.search(params[:search]).order('last_name ASC, name ASC').paginate(page: params[:page], per_page: 15)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
      format.csv  { render csv: Client.order(:last_name), filename: "Clientes #{Date.today}" }
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])
    @client_orders = @client.orders.order('created_at DESC').paginate(
      page: params[:order_page], per_page: 5
    )
    @client_payments = @client.payments.order('created_at DESC').paginate(
      page: params[:pay_page], per_page: 5
    )

    respond_to do |format|
      format.html # show.html.erb
      format.json   { render json: @client }
      format.csv    { render csv: @client, filename: "Cliente #{@client}"}
    end
  end

  # GET /clients/new
  # GET /clients/new.json
  def new
    @client = Client.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render json: @client }
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])

    respond_to do |format|
      if @client.save
        format.html { redirect_to(@client, :notice => t('client.create')) }
        format.json  { render json: @client, :status => :created, :location => @client }
      else
        format.html { render :action => "new" }
        format.json  { render json: @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])

    to_amount = params[:client][:to_amount].to_f
    params[:client][:amount] = @client.amount.to_f + to_amount

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to(@client, :notice => t('client.updated')) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render json: @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to(clients_url, notice: t('client.destroyed')) }
      format.json  { head :ok }
    end
  end

  def autocomplete_for_client
    @clients = Client.with_client(params[:q])

    respond_to do |format|
      format.json { render json: @clients }
    end
  end
end
