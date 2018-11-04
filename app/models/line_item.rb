class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :order

  scope :with_order, -> { joins(:order) }


  def total_price
    product.price * quantity
  end

  def self.to_csv
    CSV.generate(col_sep: ';') do |csv|
      csv << ['Producto', 'Marca', 'Precio del producto',  'Cantidad vendida', 'Unidad del producto']

      scoped.includes(:product).group_by(&:product).map do |product, collection|
        [
          product.name,
          product.mark,
          "$#{product.price.round(2)}",
          collection.sum(&:quantity).to_f.round(2),
          product.uni
        ]
      end.sort_by { |row| row[3] }.reverse.each do |row|
        csv << row
      end
    end
  end
end
