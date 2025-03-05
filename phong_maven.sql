-- Create the database (if it doesn't exist)
-- Connect to the 'postgres' database first to create a new database.
CREATE DATABASE phong;

-- Connect to the 'phong' database
\c phong;  --  "\c" is a psql command to connect to a database

-- Create the 'admin' table
CREATE TABLE admin (
                       id SERIAL PRIMARY KEY,  -- SERIAL is auto-increment in PostgreSQL
                       name VARCHAR(100),
                       email VARCHAR(100),
                       password VARCHAR(50),
                       phone VARCHAR(20)
);

-- Insert data into 'admin'
INSERT INTO admin (name, email, password, phone) VALUES
                                                     ('Phong Phan', 'test@gmail.com', 'abc123', '7755632012'),
                                                     ('Phong Phan', 'test34@gmail.com', 'abc', '8565452152');

-- Create the 'user' table
CREATE TABLE "user" (  -- Enclose "user" in quotes as it's a reserved word.  Much better to rename the table.
                        userid SERIAL PRIMARY KEY,
                        name VARCHAR(100),
                        email VARCHAR(45) UNIQUE,
                        password VARCHAR(45),
                        phone VARCHAR(20) UNIQUE,
                        gender VARCHAR(20),
                        registerdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        address VARCHAR(250),
                        city VARCHAR(100),
                        pincode VARCHAR(10),
                        state VARCHAR(100)
);

-- Insert data into 'user'
INSERT INTO "user" (name, email, password, phone, gender, address, city, pincode, state) VALUES
                                                                                             ('Minh Phan', 'test786@gmail.com', 'abc123', '7546254260', 'Male', 'KN nagar', 'Patna', '401980', 'Bihar'),
                                                                                             ('Phong', 'amt677@gmail.com', 'abc', '8563201201', 'Male', 'AJ', 'Banglore', '865012', 'Karnataka');

-- Create the 'category' table
CREATE TABLE category (
                          cid SERIAL PRIMARY KEY,
                          name VARCHAR(100),
                          image VARCHAR(100)
);

-- Insert data into 'category'
INSERT INTO category (name, image) VALUES
                                       ('Mobiles', 'mobiles.jpeg'),
                                       ('Appliances', 'appliances.png'),
                                       ('Laptops', 'newlaptop.jpeg'),
                                       ('Home & Furniture', 'home-furniture.png'),
                                       ('Books', 'books-.png'),
                                       ('Clothes & Fashion', 'cloths.png'),
                                       ('Electronics', 'electronics.png');


-- Create the 'product' table
CREATE TABLE product (
                         pid SERIAL PRIMARY KEY,
                         name VARCHAR(250) NOT NULL,
                         description VARCHAR(500),
                         price VARCHAR(20) NOT NULL,
                         quantity INTEGER,
                         discount INTEGER,
                         image VARCHAR(100),
                         cid INTEGER,
                         FOREIGN KEY (cid) REFERENCES category (cid)
);

-- Insert data into 'product'
INSERT INTO product (name, description, price, quantity, discount, image, cid) VALUES
                                                                                   ('SAMSUNG Galaxy F14 5G', 'The Samsung Galaxy F14...', '18490.0', 9, 24, 'phone1.jpeg', 1),
                                                                                   ('LG 242 L Frost Free...', 'You can enjoy chilled drinks...', '37099.0', 50, 29, 'fridge1.jpeg', 2),
                                                                                   ('OnePlus Y1S Pro...', 'Enjoy rich, clear...', '49999.0', 1, 18, 'tv1.jpeg', 2),
                                                                                   ('Samsung Galaxy S23 5G', 'Brand Samsung...', '79999.0', 10, 17, 'Samsung_Galaxy.jpg', 1),
                                                                                   ('ASUS TUF Gaming A15', '15.6 inch Full HD...', '71990.0', 11, 20, 'asus_tuf.jpeg', 3),
                                                                                   ('Men Printed Casual Jacket', 'Color Black...', '1999.0', 1, 57, 'men_jacket.jpeg', 6),
                                                                                   ('boAt Airdopes 161...', 'The Airdopes 161 TWS...', '2400.0', 27, 42, 'boat-airdopes.jpeg', 7),
                                                                                   ('KURLON Natural...', 'Brand KURLON...', '8000.0', 11, 16, 'mattress.jpeg', 4);

-- Create the 'cart' table
CREATE TABLE cart (
                      id SERIAL PRIMARY KEY,
                      uid INTEGER,
                      pid INTEGER,
                      quantity INTEGER,
                      FOREIGN KEY (uid) REFERENCES "user" (userid),
                      FOREIGN KEY (pid) REFERENCES product (pid)
);

-- Insert data into 'cart'
INSERT INTO cart (uid, pid, quantity) VALUES
    (1, 13, 1);

-- Create the 'order' table
CREATE TABLE "order" ( -- Enclose "order" in quotes as it's a reserved word.  Much better to rename the table.
                         id SERIAL PRIMARY KEY,
                         orderid VARCHAR(100),
                         status VARCHAR(100),
                         paymentType VARCHAR(100),
                         userId INTEGER,
                         date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         FOREIGN KEY (userId) REFERENCES "user" (userid)
);

-- Insert data into 'order'
INSERT INTO "order" (orderid, status, paymentType, userId) VALUES
                                                               ('ORD-20230924105716', 'Order Placed', 'COD', 1),
                                                               ('ORD-20230924110928', 'Order Placed', 'COD', 1),
                                                               ('ORD-20230924111023', 'Order Placed', 'COD', 1),
                                                               ('ORD-20230924111502', 'Order Placed', 'COD', 1),
                                                               ('ORD-20230924112315', 'Order Placed', 'COD', 1),
                                                               ('ORD-20230924115427', 'Order Placed', 'online', 1),
                                                               ('ORD-20230924115652', 'Order Placed', 'online', 1);

-- Create the 'ordered_product' table
CREATE TABLE ordered_product (
                                 oid SERIAL PRIMARY KEY,
                                 name VARCHAR(100),
                                 quantity INTEGER,
                                 price VARCHAR(45),
                                 image VARCHAR(100),
                                 orderid INTEGER,
                                 FOREIGN KEY (orderid) REFERENCES "order" (id)
);

-- Insert data into 'ordered_product'
INSERT INTO ordered_product (name, quantity, price, image, orderid) VALUES
                                                                        ('boAt Airdopes 161 with 40 Hours Playback', 1, '1392.0', 'boat-airdopes.jpeg', 3),
                                                                        ('OnePlus Y1S Pro 138 cm  Ultra HD (4K) LED Smart Android TV', 1, '41000.0', 'tv1.jpeg', 4),
                                                                        ('ASUS TUF Gaming A15', 1, '57592.0', 'asus_tuf.jpeg', 5),
                                                                        ('Men Printed Casual Jacket', 1, '860.0', 'men_jacket.jpeg', 6),
                                                                        ('LG 242 L Frost Free Double Door  Refrigerator', 1, '26341.0', 'fridge1.jpeg', 6),
                                                                        ('SAMSUNG Galaxy F14 5G', 1, '14053.0', 'phone1.jpeg', 7);

-- Create the 'wishlist' table
CREATE TABLE wishlist (
                          idwishlist SERIAL PRIMARY KEY,
                          iduser INTEGER,
                          idproduct INTEGER,
                          FOREIGN KEY (iduser) REFERENCES "user" (userid),
                          FOREIGN KEY (idproduct) REFERENCES product (pid)
);

-- Insert data into 'wishlist'
INSERT INTO wishlist (iduser, idproduct) VALUES
    (1, 10);