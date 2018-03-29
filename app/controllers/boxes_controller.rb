class BoxesController < ApplicationController

  check_authorization
  load_and_authorize_resource

  # GET /boxes
  # GET /boxes.json
  def index
    @boxes = Box.order('id DESC').paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @boxes }
      format.csv  { render csv: boxes_scoped, filename: "Cajas #{Date.today}" }
    end
  end

  # GET /boxes/1
  # GET /boxes/1.json
  def show
    @box = Box.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @box }
    end
  end

  # GET /boxes/new
  # GET /boxes/new.json
  def new
    @box = Box.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @box }
    end
  end

  # GET /boxes/1/edit
  def edit
    @box = Box.find(params[:id])
  end

  # POST /boxes
  # POST /boxes.json
  def create
    @box = Box.new(params[:box])

    respond_to do |format|
      if @box.save
        format.html { redirect_to @box, notice: 'Box was successfully created.' }
        format.json { render json: @box, status: :created, location: @box }
      else
        format.html { render action: "new" }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /boxes/1
  # PUT /boxes/1.json
  def update
    @box = Box.find(params[:id])

    respond_to do |format|
      if @box.update_attributes(params[:box])
        format.html { redirect_to @box, notice: 'Box was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boxes/1
  # DELETE /boxes/1.json
  def destroy
    @box = Box.find(params[:id])
    @box.destroy

    respond_to do |format|
      format.html { redirect_to boxes_url }
      format.json { head :ok }
    end
  end

  def print_close
    close = params[:close]
    bill = Bill.new
    @close = bill.send_package(0x39, [close, 'P'])

    redirect_to boxes_url, notice: "Enviado a imprimir cierre #{close}"
  end


  private
  def boxes_scoped
    if params[:month] && params[:year]
      date = Date.new(params[:year].to_i, params[:month].to_i)
      boxes = Box.between(
        date.beginning_of_month, date.end_of_month.end_of_day
       )
    else
      boxes = Box.scoped
    end

    boxes.order('id DESC')
  end
end
