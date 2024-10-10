json.extract! product, :id, :name, :stock_qty, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
