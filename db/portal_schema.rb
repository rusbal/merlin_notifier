# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_10_12_130613) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "stock_qty"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_function :products_notifier, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.products_notifier()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          IF (TG_OP = 'INSERT') THEN
            PERFORM pg_notify(
              'table_changes_notification',
              json_build_object(
                'table', TG_TABLE_NAME,
                'type', TG_OP,
                'id', NEW.id,
                'new', row_to_json(NEW),
                'old', ''
              )::text
            );
          END IF;

          IF (TG_OP = 'UPDATE') THEN
            PERFORM pg_notify(
              'table_changes_notification',
              json_build_object(
                'table', TG_TABLE_NAME,
                'type', TG_OP,
                'id', NEW.id,
                'new', row_to_json(NEW),
                'old', row_to_json(OLD)
              )::text
            );
          END IF;

          IF (TG_OP = 'DELETE') THEN
            PERFORM pg_notify(
              'table_changes_notification',
              json_build_object(
                'table', TG_TABLE_NAME,
                'type', TG_OP,
                'id', OLD.id,
                'new', '',
                'old', row_to_json(OLD)
              )::text
            );
          END IF;

          IF (TG_OP = 'DELETE') THEN
            PERFORM pg_notify('products_notification', '{klass_name: "' || TG_TABLE_NAME || '", crud_method: "' || TG_OP || '", id: "' || OLD.id || '", name: "' || OLD.name || '", stock_qty: "' || OLD.stock_qty || '", price: "' || OLD.price || '"}');
            RETURN OLD;
          ELSE
            PERFORM pg_notify('products_notification', '{klass_name: "' || TG_TABLE_NAME || '", crud_method: "' || TG_OP || '", id: "' || COALESCE(NEW.id, 0) || '", name: "' || COALESCE(NEW.name, '') || '", stock_qty: "' || COALESCE(NEW.stock_qty, 0) || '", price: "' || COALESCE(NEW.price, 0) || '"}');
            RETURN NEW;
          END IF;
        END;
      $function$
  SQL


  create_trigger :products_trigger, sql_definition: <<-SQL
      CREATE TRIGGER products_trigger AFTER INSERT OR DELETE OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION products_notifier()
  SQL
end
