class ShiftClosuresController < ApplicationController
  before_filter :set_shift_closure, except: [:index, :new, :create, :export]
  before_filter :check_if_not_finished, only: [:edit, :update]

  helper_method :can_edit_shift_closure?

  # GET /shift_closures
  def index
    @from_date, @to_date = *make_datetime_range
    @shift_closures = ShiftClosure.order('start_at DESC').paginate(page: params[:page])
  end

  # GET /shift_closures/1
  def show
  end

  # GET /shift_closures/new
  def new
    if (_last = ShiftClosure.unfinished.last).present?
      redirect_to edit_shift_closure_path(_last), notice: 'Tenes un turno abierto'
    end
    @shift_closure = ShiftClosure.new
  end

  # GET /shift_closures/1/edit
  def edit
  end

  # POST /shift_closures
  def create
    @shift_closure = ShiftClosure.new(shift_closure_params)

    if @shift_closure.save
      redirect_to @shift_closure, notice: 'Turno creado'
    else
      render :new
    end
  end

  # PATCH/PUT /shift_closures/1
  def update
    if @shift_closure.update_attributes(shift_closure_params)
      redirect_to @shift_closure, notice: @shift_closure.finished? ? 'Turno cerrado' :  'Turno actualizado'
    else
      render :edit
    end
  end

  # DELETE /shift_closures/1
  def destroy
    @shift_closure.destroy
    redirect_to shift_closures_url, notice: 'Turno destruido'
  end

  def export
    from_date, to_date = *make_datetime_range(params[:interval])
    shift_closures = ShiftClosure.where(start_at: from_date..to_date)

    response.headers['Cache-Control'] = 'private, no-store'
    filename = "turnos_#{l(from_date.to_date)}_al_#{l(to_date.to_date)}.csv"

    send_data(
      shift_closures.to_csv,
      type: Mime::CSV,
      disposition: "attachment; filename=#{filename}"
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift_closure
      @shift_closure = ShiftClosure.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shift_closure_params
      permitted_params = params[:shift_closure]
        # :start_at, :finish_at, :cashbox_amount, :initial_amount,
        # :payoffs, :system_amount, :final_amount, :comments
      # )
      permitted_params[:user_id] = current_user.id
      permitted_params
    end

    def check_if_not_finished
      unless can_edit_shift_closure?(@shift_closure)
        redirect_to shift_closure_path(@shift_closure.id),
          alert: 'no puede editar un turno ya terminado'
      end
    end

    def can_edit_shift_closure?(shift_closure)
      (
        shift_closure.finish_at.blank? ||
        shift_closure.finish_at >= 45.minutes.ago
      )
    end
end
