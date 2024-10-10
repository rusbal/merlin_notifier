class CreateFunctionProductsNotifier < ActiveRecord::Migration[7.0]
  def change
    create_function :products_notifier
  end
end
