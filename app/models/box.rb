class Box < ActiveRecord::Base
  has_paper_trail

  scope :between, ->(_start, _end) { where(
    "created_at BETWEEN :start AND :end",
    start: _start, end: _end
  ) }

  def to_s
    [self.day, self.month, self.year].join('-')
  end

  def self.by_months
    months = []

    (0..11).map do |i|
      month = i.months.ago
      _start = month.beginning_of_month.beginning_of_day
      _end = _start.end_of_month.end_of_day
      months << OpenStruct.new(
        month: _end.month, year: _end.year,
        sold: between(_start, _end).sum(&:total)
      )
    end

    months
  end


  def self.to_csv
    CSV.generate do |csv|
      csv << [
        'Fecha', 'Ventas', 'Montos'
      ]
      scoped.each do |day|
        csv << [
          day,
          day.count,
          "#{day.total.round(2).to_s.gsub('.',',')}"
        ]
      end
    end
  end
end
