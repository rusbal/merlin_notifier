CREATE TRIGGER products_notifier
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW
    EXECUTE PROCEDURE products_notifier();
