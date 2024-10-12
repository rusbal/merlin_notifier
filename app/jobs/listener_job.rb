# require 'sidekiq'
 
class ListenerJob
  include Sidekiq::Worker
 
  def perform(payload)
    @payload = JSON.parse(payload)

    send(db_operation)
  end

  private

  def portal_model
    table_name = @payload["table"][..-2]
    "Portal::#{table_name.capitalize}".constantize
  end

  def db_operation
    @payload["type"].downcase.to_sym
  end

  def insert
    ap "INSERT -------------------"
    portal_model.create(insert_data)
  end

  def update
    changes = delta
    ap "UPDATE: #{changes}"
    portal_row&.update(changes)
  end

  def delete
    ap "DELETE -------------------"
    portal_row&.destroy
  end

  def portal_row
    @portal_row ||= portal_model.find_by(merlin_product_id: @payload["id"])
  end

  def delta
    {}.tap do |hash|
      old_row.keys.each do |key|
        next if ["id", "created_at", "updated_at"].include?(key)
        next if old_row[key] == new_row[key]
        hash[key.to_sym] = new_row[key]
      end
    end
  end

  def old_row
    @old ||= @payload["old"]
  end

  def new_row
    @new ||= @payload["new"]
  end

  def insert_data
    @payload["new"].merge(merlin_product_id: @payload["id"]).tap do |data|
      data.delete(:id)
      data.delete(:created_at)
      data.delete(:updated_at)
    end
  end
end
