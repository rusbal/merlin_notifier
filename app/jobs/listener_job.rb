# require 'sidekiq'
 
class ListenerJob
  include Sidekiq::Worker
 
  def perform(payload)
    result = eval(payload)
    ap result

    if result[:crud_method] == "UPDATE"
      row = Portal::Product.find_by(merlin_product_id: result[:id])
      ap "UPDATE: #{row&.id}"
      row.update(name: result[:name], stock_qty: result[:stock_qty], price: result[:price]) if row

    elsif result[:crud_method] == "INSERT"
      Portal::Product.create(merlin_product_id: result[:id], name: result[:name], stock_qty: result[:stock_qty], price: result[:price])

    else
      row = Portal::Product.find_by(merlin_product_id: result[:id])
      ap "DELETE: #{row&.id}"
      row.destroy if row
    end
  end
end
