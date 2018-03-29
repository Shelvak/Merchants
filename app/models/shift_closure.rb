class ShiftClosure < ActiveRecord::Base
  has_paper_trail

  serialize :first_and_last_info_to_json, JsonField

  scope :unfinished, -> { where(finish_at: nil) }
  scope :between, -> (_start, _end) { where(created_at: _start.._end) }

  before_save :make_after_finish_job, if: -> { self.finish_at.present? }

  validates :start_at, :system_amount, :cashbox_amount, :user_id, presence: true
  validate :not_create_when_one_is_open

  validates_datetime :start_at, allow_nil: true, allow_blank: true
  validates_datetime :start_at, allow_nil: true, allow_blank: true,
    before: :finish_at
  validates_datetime :finish_at, allow_nil: true, allow_blank: true,
    after: :start_at, before: -> { Time.zone.now },
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

      self.errors.add :base, I18n.t('view.shift_closures.one_still_open')
    end
  end

  def make_after_finish_job
    # self.system_amount = Print.between(
    #   self.start_at, (self.finish_at || Time.now)
    # ).to_a.sum(&:price) if self.system_amount.zero? || partial
  end

  def last_cashbox_amount
    if self.initial_amount.zero?
      ShiftClosure.last.try(:cashbox_amount) || 0.0
    else
      self.initial_amount
    end
  end

  def self.to_csv
    return if all.empty?

    printer_index_to_cols_init = ('B'..'Z').map {|l| l if l.ord.even?}.compact.sort
    printer_index_to_cols_final = ('B'..'Z').map {|l| l if l.ord.odd?}.compact.sort
    alphabet = ('A'..'Z').to_a

    # just in case
    ('A'..'Z').each { |l| alphabet << "A#{l}" }

    title = [
      human_attribute_name('created_at')
    ]

    current_printers = all.map do |daily|
      daily.printers_stats.keys.to_a
    end.flatten.uniq.sort
    current_printers.delete('Virtual_PDF_Printer')

    current_printers.each do |printer|
      title << I18n.t('view.shift_closures.printer_start', printer: printer)
      title << I18n.t('view.shift_closures.printer_end', printer: printer)
    end

    title += ['cantidad de copias', 'falladas', 'cetem', 'cca',
      'vendidas', 'recaudacion real', 'recaudacion teorica', 'diferencia'
    ]

    csv = [title]

    month = all.first.created_at
    full_month = (
      month.beginning_of_month.to_date..month.end_of_month.to_date
    ).sort.map do |date|
      filter = all.where(created_at: date.beginning_of_day..date.end_of_day)
      if filter.any?
        filter.first
      else
        new_daily = ShiftClosure.new(created_at: date)
        new_daily.initial_amount = 0.0
        new_daily
      end
    end

    full_month.each do |daily|
      daily_date = I18n.l(daily.created_at.to_date).to_s
      row = [daily_date]
      row_number = csv.size + 1

      current_printers.each_with_index do |printer, p_i|
        row << if row_number != 2
                 ['=', printer_index_to_cols_final[p_i], row_number-1].join
               end

        row << if daily.printers_stats.any?
                 daily.printers_stats[printer]
               else
                 ['=', printer_index_to_cols_init[p_i], row_number].join
               end
      end
      letters = ('B'..alphabet[row.size-1]).to_a.reverse

      printers_diff = []
      loop do
        begin
          a, b = letters.pop(2)
          printers_diff << "(#{a}#{row_number}-#{b}#{row_number})"
        rescue
        end
        break if letters.size <= 1
      end

      row << '=' + printers_diff.join('+') # total printed copies
      row << daily.failed_copies
      row << daily.administration_copies
      row << 0 # place copies

      sold_copies = (alphabet[row.size-4]..alphabet[row.size-1]).to_a.map do |c|
        [c, row_number].join
      end.join('-')

      row << "=IF((#{sold_copies})>0, #{sold_copies}, 0)"
      row << daily.total_amount.to_s
      row << daily.system_amount.to_s

      row << '=' + [
        [alphabet[row.size-2], row_number].join,
        [alphabet[row.size-1], row_number].join
      ].join('-')

      csv << row
    end

    totals = Array.new(csv.last.size)

    # Space for total
    csv << []
    csv << []

    totals[0] = I18n.t('view.shift_closures.total')
    (1..8).each do |i|
      totals[-i] = [
        '=SUM(',
        alphabet[totals.size-i] + '2',
        ':',
        alphabet[totals.size-i] + (csv.size-2).to_s,
        ')'
      ].join
    end

    csv << totals
    csv
  end
end
