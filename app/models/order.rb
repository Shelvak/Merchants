class Order < ActiveRecord::Base
  has_paper_trail

  belongs_to :client
  has_many :line_items, dependent: :destroy
  has_one :bill, dependent: :destroy
  accepts_nested_attributes_for :line_items, :allow_destroy => true

  scope :between, ->(start, finish) { where(
    "#{table_name}.created_at BETWEEN :s AND :f",
    s: start, f: finish
  )}

  before_save :total_price, :assign_own_price
  after_save :plus_price_to_client, :discount_stock, :daily_box, :create_bill

  attr_accessor :auto_client, :send_print, :discount, :uic, :uic_type,
    :client_kind

  def assign_own_price
    self.line_items.each do |li|
      li.price = li.product.price.to_d
    end
  end

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      line_items.build(item.attributes.merge(id: nil))
    end
  end


  def total_price
    self.price = self.line_items.to_a.sum { |item| item.total_price}
  end

  def plus_price_to_client
    @order = Order.order('id DESC').first
    if @order.client
      @client = Client.find(@order.client)
      @client.spend ||= 0
      @client.spend += @order.price
      @client.update_attributes(spend: @client.spend)
      if @order.to_amount
        @client.amount ||= 0
        @client.amount -= @order.price
        @client.update_attributes(amount: @client.amount)
      end
    end
  end

  def discount_stock
    @order = Order.order('id DESC').first
    @order.line_items.each do |li|
      @product = Product.find_by_id(li.product.id)
      @product.stock -= li.quantity
      @product.update_attributes(stock: @product.stock)
    end
  end

  def daily_box
    unless self.to_amount
      @order = Order.order('id DESC').first
      @daybox = Box.find_or_create_by_day_and_month_and_year(Date.today.day, Date.today.month, Date.today.year)
      @daybox.count = ((@daybox.count += 1) || 0)
      @daybox.total += @order.price
      @daybox.update_attributes(total: @daybox.total, count: @daybox.count)
    end
  end

  def create_bill
    if self.send_print == '1' || self.send_print == true
      items = []
      self.line_items.map {|r| items << "#{r.product.name} x#{r.quantity}
        $#{r.product.price.to_s}  => $#{(r.quantity * r.product.price).to_s}"}

      items = items.join("\n")

      Bill.create!(
        client_id: self.client_id, amount: self.price, items: items,
        bill_kind: self.bill_kind, prod_count: self.line_items.count,
        discount: self.discount.to_d, order_id: self.id,
        uic: self.uic, uic_type: self.uic_type, client_kind: self.client_kind
      )
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ['Nro', 'Fecha', 'Cliente', 'Monto']
      select('id, created_at, client_id, price').each do |order|
        csv <<  [
          order.id,
          I18n.l(order.created_at, format: :smart),
          (order.client_id ? order.client : '-'),
          "#{order.price.round(2).to_s.gsub('.',',')}"
        ]
      end
    end
  end
end
