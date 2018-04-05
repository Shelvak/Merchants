class BillsController < ApplicationController

  check_authorization
  load_and_authorize_resource

  # GET /bills
  # GET /bills.xml
  def index
    @bills = Bill.order('id DESC')
    if params[:shift_closure_id]
      @bills = ShiftClosure.find(params[:shift_closure_id]).bills
    else
      @bills = @bills.where('created_at > :yesterday', yesterday: 1.day.ago) if current_user.seller?
    end
    @bills = @bills.paginate(page: params[:page], per_page: 15)

    respond_to do |format|
      format.html # index.html.erb
      format.csv  { render csv: bills_scoped, filename: "bills #{Date.today}" }
    end
  end

  # GET /bills/1
  # GET /bills/1.xml
  def show
    @bill = Bill.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  # GET /bills/new
  # GET /bills/new.xml
  def new
    @bill = Bill.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  def edit
    @bill = Bill.find(params[:id])
  end

  # POST /bills
  # POST /bills.xml
  def create
    @bill = Bill.new(params[:bill])

    respond_to do |format|
      if @bill.save
        format.html { redirect_to(@bill, :notice => 'Bill was successfully created.') }
        format.xml  { render :xml => @bill, :status => :created, :location => @bill }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @bill = Bill.find(params[:id])

    respond_to do |format|
      if @bill.update_column(:barcode, params[:bill][:barcode])
        format.html { redirect_to(@bill, notice: 'Factura actualizado.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
      end
    end
  end

  def print
    @bill = Bill.find(params[:id])
    @print = @bill.send_to_print

    redirect_to @bill, notice: 'Re-enviado a imprimir...'
  end

  private

  def bills_scoped
    if params[:month] && params[:year]
      date = Date.new(params[:year].to_i, params[:month].to_i)
      bills = Bill.between(
        date.beginning_of_month, date.end_of_month.end_of_day
       )
    else
      bills = Bill.scoped
    end

    bills.order('barcode DESC')
  end
end
