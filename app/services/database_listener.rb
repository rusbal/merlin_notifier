class DatabaseListener
  def listen
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)
      
      begin
        conn.async_exec "LISTEN products_notification"
        loop do
          conn.wait_for_notify do |channel, pid, payload|
            puts "Received NOTIFY on channel #{channel} with payload: #{payload}"

            ListenerJob.perform_async(payload)
          end
        end
      ensure
        conn.async_exec "UNLISTEN *"
      end
    end
  end
end
