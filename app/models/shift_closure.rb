class ShiftClosure < ActiveRecord::Base
  has_paper_trail

  serialize :first_and_last_info_to_json, JsonField

  scope :unfinished, -> { where(finish_at: nil) }
  scope :between, -> (_start, _end) { where(created_at: _start.._end) }

  before_save :make_after_finish_job, if: -> { self.finish_at.present? }

  validates :start_at, :user_id, presence: true
  validates :initial_amount, numericality: { greater_than: 0 }
  validates :cashbox_amount, :final_amount, :payoffs,
    numericality: { greater_than_or_equal_to: 0 }

  validate :not_create_when_one_is_open

  validates_datetime :start_at, allow_nil: true, allow_blank: true
  validates_datetime :start_at, allow_nil: true, allow_blank: true,
    before: :finish_at,
    before_message: 'Debe ser anterior al final del turno'
  validates_datetime :finish_at, allow_nil: true, allow_blank: true,
    after: :start_at,
    after_message: "Debe ser posterior al inicio",
    before: -> { Time.zone.now },
    before_message: 'Debe ser anterior a "ahora"',
    if: -> { self.finish_at.present? }


  belongs_to :user

  def initialize(attributes={}, *other)
    super(attributes)

    self.start_at ||= self.last_closure_or_first_in_day
    self.initial_amount ||=  0.0
    self.final_amount ||=  0.0
    self.cashbox_amount ||=  0.0
  end

  def last_closure_or_first_in_day
    _time = nil

    if (last_closure = ShiftClosure.last).present?
      _time = last_closure.finish_at if last_closure.finish_at.try(:today?)
    end

    _time || Time.zone.now.change(hour: 8, minute: 0, seconds: 0) # the first shift
  end

  def not_create_when_one_is_open
    if !self.persisted? &&
      (_last = ShiftClosure.unfinished.last).present? &&
      _last.id != self.id

      self.errors.add :base, 'Hay un turno abierto'
    end
  end

  def make_after_finish_job
    orders = Order.between(
      self.start_at, (self.finish_at || Time.zone.now)
    )
    bills = Bill.between(
      self.start_at, (self.finish_at || Time.zone.now)
    )
    payments = Payment.between(
      self.start_at, (self.finish_at || Time.zone.now)
    )
    self.system_amount = orders.paid.to_a.sum(&:total_price) + payments.to_a.sum(&:deposit)

    self.first_and_last_info_to_json = {
      order_ids: orders.pluck(:id).sort,
      bill_ids: bills.pluck(:id).sort,
      payment_ids: payments.pluck(:id).sort
    }
  end

  # def last_cashbox_amount
  #   return self.initial_amount unless self.initial_amount.zero?

  #   if (last_closure = ShiftClosure.last).present? && last_closure.finish_at.try(:today?)
  #     last_closure.final_amount
  #   else
  #     0.0
  #   end
  # end

  def bill_ids
    first_and_last_info_to_json.fetch(:bill_ids, [])
  end

  def bills
    Bill.where(id: bill_ids)
  end

  def order_ids
    first_and_last_info_to_json.fetch(:order_ids, [])
  end

  def orders
    Order.where(id: order_ids)
  end

  def payment_ids
    first_and_last_info_to_json.fetch(:payment_ids, [])
  end

  def payments
    Payment.where(id: payment_ids)
  end

  def finished?
    finish_at.present?
  end

  def expected_amount
    self.initial_amount + self.cashbox_amount + self.system_amount - self.payoffs
  end

  def diff_amount
    self.final_amount - self.expected_amount
  end

  def self.helpers
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end

  def self.to_csv
    CSV.generate do |csv|
      scoped.includes(:user).group_by {|sc| sc.start_at.to_date }.sort.each do |date, records|
        row_1 = []; row_2 = []; row_3 = []; row_4 = []; row_5 = []
        row_6 = []; row_7 = []; row_8 = []; row_9 = []

        records.each_with_index do |sc, i|
          row_1 += (['',                         'Fecha', I18n.l(date), ''])
          row_2 += (['Responsable',              sc.user.to_s, "Turno #{i+1}", ''])
          row_3 += (['Monto Inicial',            helpers.number_to_currency(sc.initial_amount), '', ''])
          row_4 += (['Extra Proveedores',        helpers.number_to_currency(sc.cashbox_amount), '', ''])
          row_5 += (['Pagado Proveedores',       helpers.number_to_currency(sc.payoffs), '', ''])
          row_6 += (['Calculo Automatico(caja)', helpers.number_to_currency(sc.system_amount), '', ''])
          row_7 += (['Efectivo Final',           helpers.number_to_currency(sc.final_amount), '', ''])
          row_8 += (['Monto Esperado',           helpers.number_to_currency(sc.expected_amount), '', ''])
          row_9 += (['Diferencia',               helpers.number_to_currency(sc.diff_amount), '', ''])
        end
        csv << row_1
        csv << row_2
        csv << row_3
        csv << row_4
        csv << row_5
        csv << row_6
        csv << row_7
        csv << row_8
        csv << row_9
        csv << []
        csv << []
      end
    end
  end
end
