class Product < ApplicationRecord
  validates :name, presence: true
  validates :stock_qty, presence: true
  validates :price, presence: true
end
