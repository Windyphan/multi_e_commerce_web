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
                                                     ('Phong Phan', 'test@gmail.com', 'hashed_admin_pw1', '01614960123'),
                                                     ('Phong Phan', 'test34@gmail.com', 'hashed_admin_pw2', '01614960123');

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
                        postcode VARCHAR(10),
                        county VARCHAR(100)
);

-- Insert data into 'user'
INSERT INTO "user" (name, email, password, phone, gender, address, city, postcode, county) VALUES
                                                                                               ('Alice Smith', 'alice.s@example.com', 'hashed_user_pw1', '07700900123', 'Female', '10 Church Lane', 'Manchester', 'M1 1AA', 'Greater Manchester'),
                                                                                               ('Bob Jones', 'b.jones@example.co.uk', 'hashed_user_pw2', '02079460987', 'Male', 'Flat 5, The Old Mill', 'Bristol', 'BS1 5TT', 'Bristol');

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
                                                                                   ('SAMSUNG Galaxy F14 5G', 'The Samsung Galaxy F14...', '184.99', 9, 24, 'phone1.jpeg', 1),
                                                                                   ('LG 242 L Frost Free...', 'You can enjoy chilled drinks...', '370.99', 50, 29, 'fridge1.jpeg', 2),
                                                                                   ('OnePlus Y1S Pro...', 'Enjoy rich, clear...', '499.99', 1, 18, 'tv1.jpeg', 2),
                                                                                   ('Samsung Galaxy S23 5G', 'Brand Samsung...', '799.99', 10, 17, 'Samsung_Galaxy.jpg', 1),
                                                                                   ('ASUS TUF Gaming A15', '15.6 inch Full HD...', '719.90', 11, 20, 'asus_tuf.jpeg', 3),
                                                                                   ('Men Printed Casual Jacket', 'Color Black...', '19.99', 1, 57, 'men_jacket.jpeg', 6),
                                                                                   ('boAt Airdopes 161...', 'The Airdopes 161 TWS...', '24.00', 27, 42, 'boat-airdopes.jpeg', 7),
                                                                                   ('KURLON Natural...', 'Brand KURLON...', '80.00', 11, 16, 'mattress.jpeg', 4);

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

-- Create the 'review' table
CREATE TABLE review (
                        review_id SERIAL PRIMARY KEY,
                        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Rating from 1 to 5 stars
                        comment TEXT,                                    -- User's review text (can be long)
                        review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                        user_id INTEGER NOT NULL,                      -- Foreign key to the user who wrote the review
                        product_id INTEGER NOT NULL,                   -- Foreign key to the product being reviewed
                        FOREIGN KEY (user_id) REFERENCES "user" (userid) ON DELETE CASCADE, -- If user deleted, remove their reviews
                        FOREIGN KEY (product_id) REFERENCES product (pid) ON DELETE CASCADE, -- If product deleted, remove its reviews
                        UNIQUE (user_id, product_id) -- Ensure a user can only review a product once
);

-- Optional: Add indexes for faster querying
CREATE INDEX idx_review_product_id ON review (product_id);
CREATE INDEX idx_review_user_id ON review (user_id);