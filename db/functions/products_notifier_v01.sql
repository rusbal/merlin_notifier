CREATE OR REPLACE FUNCTION products_notifier() RETURNS TRIGGER as $products_notifier$
  BEGIN
    IF (TG_OP = 'DELETE') THEN
      PERFORM pg_notify('products_notification', '{klass_name: "' || TG_TABLE_NAME || '", crud_method: "' || TG_EVENT || '", id: "' || OLD.id || '", name: "' || OLD.name || '", stock_qty: "' || OLD.stock_qty || '", price: "' || OLD.price || '"}');
      RETURN OLD;
    ELSE
      PERFORM pg_notify('products_notification', '{klass_name: "' || TG_TABLE_NAME || '", crud_method: "' || TG_EVENT || '", id: "' || COALESCE(NEW.id, 0) || '", name: "' || COALESCE(NEW.name, "") || '", stock_qty: "' || COALESCE(NEW.stock_qty, 0) || '", price: "' || COALESCE(NEW.price, 0) || '"}');
      RETURN NEW;
    END IF;
  END;
$products_notifier$ LANGUAGE plpgsql;

CREATE TRIGGER products_trigger
AFTER INSERT OR UPDATE OR DELETE ON users FOR EACH ROW
EXECUTE PROCEDURE products_notifier()
