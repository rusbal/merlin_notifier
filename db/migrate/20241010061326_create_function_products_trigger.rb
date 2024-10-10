class CreateFunctionProductsTrigger < ActiveRecord::Migration[7.0]
  def change
    create_function :products_trigger
  end
end
