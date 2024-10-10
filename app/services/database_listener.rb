class DatabaseListener
  def listen
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)
      
      begin
        conn.async_exec "LISTEN products_notification"
        loop do
          conn.wait_for_notify do |channel, pid, payload|
            puts "Received NOTIFY on channel #{channel} with payload: #{payload}"

            result = eval(payload)
            ap result

            if result[:crud_method] == "UPDATE"
              # row = Portal::Product.find_by(merlin_product_id: result[:id])
              # row.update(name: result[:name], stock_qty: result[:stock_qty], price: result[:price]) if row

              Portal::Product.where(merlin_product_id: result[:id]).update(name: result[:name], stock_qty: result[:stock_qty], price: result[:price])

            elsif result[:crud_method] == "INSERT"
              Portal::Product.create(name: result[:name], stock_qty: result[:stock_qty], price: result[:price])

            else
              # row = Portal::Product.find_by(merlin_product_id: result[:id])
              # row.destroy if row

              Portal::Product.where(merlin_product_id: result[:id]).delete
            end
          end
        end
      ensure
        conn.async_exec "UNLISTEN *"
      end
    end
  end
end
