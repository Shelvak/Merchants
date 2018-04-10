class ShiftClosure < ActiveRecord::Base
  has_paper_trail

  serialize :first_and_last_info_to_json, JsonField

  scope :unfinished, -> { where(finish_at: nil) }
  scope :between, -> (_start, _end) { where(created_at: _start.._end) }

  before_save :make_after_finish_job, if: -> { self.finish_at.present? }

  validates :start_at, :cashbox_amount, :user_id, presence: true
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

  def initialize(attributes={})
    super(attributes)

    self.start_at ||= self.last_closure_or_first_in_day
    self.initial_amount = self.last_cashbox_amount
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

  def last_cashbox_amount
    if self.initial_amount.zero?
      ShiftClosure.last.try(:cashbox_amount) || 0.0
    else
      self.initial_amount
    end
  end

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

end
