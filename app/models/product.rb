class Product < ActiveRecord::Base

  has_paper_trail

  before_destroy :not_referenced
  before_save :up_product

  #validates
  has_many :line_items
  has_many :orders, through: :line_items
  belongs_to :category

  validates :barcode, :name, :count, :price, :presence => true
  validates :barcode, :uniqueness => true
  validates :count, :stock, :iva, :earn, :price, :pricedist, :numericality => true

  attr_accessor :newstock

  def initialize (attributes = nil, options = {})
    super(attributes, options)
    self.barcode ||= (Product.order('barcode DESC').first.try(:barcode) || 0).to_i + 1
  end

  def not_referenced
    if line_items.empty?
      return true
    else
      error.add(:base, 'Producto presente en carrito')
      return false
    end
  end

  def up_product
    self.name = self.name.split.map(&:camelize).join(' ')
    self.mark = self.mark.split.map(&:camelize).join(' ') if self.mark
    self.fragance = self.fragance.split.map(&:camelize).join(' ') if self.fragance
  end

  def self.search(search)
    if search.present?
      includes(:category).where(
        [
          "LOWER(#{table_name}.name) LIKE :q",
          "LOWER(#{table_name}.mark) LIKE :q",
          "#{table_name}.barcode LIKE :q",
          "LOWER(#{table_name}.fragance) LIKE :q",
          "LOWER(#{Category.table_name}.categoria) LIKE :q"
        ].join(' OR '),
        q: "#{search}%".downcase
      )
    else
      scoped
    end
  end
  def self.to_csv
    CSV.generate do |csv|
      csv << [
        'Codigo de barra', 'Nombre', 'Marca', 'Caracteristica',
        'Categoria', 'Precio C-S iva', 'Cantidad', 'Stock'
      ]
      scoped.each do |prod|
        csv << [
          prod.barcode,
          prod.name,
          prod.mark,
          prod.fragance,
          prod.category,
          [prod.pricedist, prod.price].join(' - '),
          [prod.count, prod.uni].join(' '),
          prod.stock
        ]
      end
    end
  end
end
