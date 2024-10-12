CREATE OR REPLACE FUNCTION products_notifier() RETURNS TRIGGER as $products_notifier$
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      PERFORM pg_notify(
        'products_notification',
        json_build_object(
          'table', TG_TABLE_NAME,
          'type', TG_OP,
          'id', NEW.id,
          'new', row_to_json(NEW),
          'old', ''
        )::text
      );
      RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
      PERFORM pg_notify(
        'products_notification',
        json_build_object(
          'table', TG_TABLE_NAME,
          'type', TG_OP,
          'id', NEW.id,
          'new', row_to_json(NEW),
          'old', row_to_json(OLD)
        )::text
      );
      RETURN NEW;
    END IF;

    IF (TG_OP = 'DELETE') THEN
      PERFORM pg_notify(
        'products_notification',
        json_build_object(
          'table', TG_TABLE_NAME,
          'type', TG_OP,
          'id', OLD.id,
          'new', '',
          'old', row_to_json(OLD)
        )::text
      );
      RETURN OLD;
    END IF;
  END;
$products_notifier$ LANGUAGE plpgsql;

CREATE TRIGGER products_trigger
AFTER INSERT OR UPDATE OR DELETE ON products FOR EACH ROW
EXECUTE PROCEDURE products_notifier()
