CREATE DATABASE inventory_management_system_db;
USE inventory_management_system_db;

CREATE TABLE products (
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50),
	price DECIMAL(10, 2),
	stock INT
);

CREATE TABLE sales (
	sale_id INT AUTO_INCREMENT PRIMARY KEY,
	product_id INT,
	sale_date DATE,
	quantity INT,
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE low_stock_notifications (
	notification_id INT AUTO_INCREMENT PRIMARY KEY,
	product_id INT,
	notification_date DATE,
	message VARCHAR(100)
);

INSERT INTO products (product_id, product_name, price, stock) VALUES
(1, 'Wireless Mouse', 19.99, 150),
(2, 'Mechanical Keyboard', 59.99, 85),
(3, 'USB-C Charger', 14.99, 200),
(4, '27-inch Monitor', 189.99, 45),
(5, 'External Hard Drive', 79.99, 120);

INSERT INTO sales (sale_id, product_id, sale_date, quantity) VALUES
(1, 1, '2024-11-01', 3),
(2, 3, '2024-11-02', 2),
(3, 4, '2024-11-03', 1),
(4, 2, '2024-11-04', 5),
(5, 5, '2024-11-05', 4);

INSERT INTO low_stock_notifications (notification_id, product_id, notification_date, message) VALUES
(1, 1, '2024-11-05', 'Stock is low for Wireless Mouse. Please reorder soon.'),
(2, 3, '2024-11-06', 'Stock is low for USB-C Charger. Immediate restock recommended.'),
(3, 4, '2024-11-06', 'Stock is low for 27-inch Monitor. Reorder to avoid shortages.');



DELIMITER //

CREATE PROCEDURE AddSale(
 IN p_product_id INT,
 IN p_quantity INT,
 IN p_sale_date DATE
)
BEGIN
  DECLARE current_stock INT;

  SELECT stock INTO current_stock FROM products WHERE product_id = p_product_id;

  INSERT INTO sales (product_id, sale_date, quantity)
  VALUES (p_product_id, p_sale_date, p_quantity);

  UPDATE products
   SET stock = stock - p_quantity
   WHERE product_id = p_product_id;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER LowStockTrigger
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
 DECLARE threshold INT DEFAULT 5;

IF NEW.stock < threshold THEN
  INSERT INTO low_stock_notifications (product_id, notification_date, message)
  VALUES (NEW.product_id, CURDATE(), CONCAT('LowStock alert: Only ', NEW.stock, ' items left for prd ', NEW.product_id));
  END IF;
END //

DELIMITER;


DELIMITER //

CREATE PROCEDURE GetSalesReport(
  IN p_product_id INT,
  IN start_date DATE,
  IN end_date DATE
)
BEGIN
  SELECT sale_id, product_id, sale_date, quantity
  FROM sales
  WHERE product_id = p_product_id AND sale_date BETWEEN start_date AND end_date;
END //

DELIMITER ;

