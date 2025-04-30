--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-05-01 01:39:35

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4437 (class 1262 OID 16415)
-- Name: phong; Type: DATABASE; Schema: -; Owner: phong_admin
--

CREATE DATABASE phong WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE phong OWNER TO phong_admin;

\connect phong

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16473)
-- Name: admin; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.admin (
    id integer NOT NULL,
    name character varying(100),
    email character varying(100),
    password character varying(255),
    phone character varying(20)
);


ALTER TABLE public.admin OWNER TO phong_admin;

--
-- TOC entry 217 (class 1259 OID 16472)
-- Name: admin_id_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_id_seq OWNER TO phong_admin;

--
-- TOC entry 4438 (class 0 OID 0)
-- Dependencies: 217
-- Name: admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.admin_id_seq OWNED BY public.admin.id;


--
-- TOC entry 232 (class 1259 OID 16652)
-- Name: cart; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.cart (
    id integer NOT NULL,
    uid integer NOT NULL,
    pid integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT cart_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.cart OWNER TO phong_admin;

--
-- TOC entry 231 (class 1259 OID 16651)
-- Name: cart_id_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.cart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_id_seq OWNER TO phong_admin;

--
-- TOC entry 4439 (class 0 OID 0)
-- Dependencies: 231
-- Name: cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.cart_id_seq OWNED BY public.cart.id;


--
-- TOC entry 222 (class 1259 OID 16494)
-- Name: category; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.category (
    cid integer NOT NULL,
    name character varying(100),
    image character varying(100)
);


ALTER TABLE public.category OWNER TO phong_admin;

--
-- TOC entry 221 (class 1259 OID 16493)
-- Name: category_cid_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.category_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_cid_seq OWNER TO phong_admin;

--
-- TOC entry 4440 (class 0 OID 0)
-- Dependencies: 221
-- Name: category_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.category_cid_seq OWNED BY public.category.cid;


--
-- TOC entry 224 (class 1259 OID 16532)
-- Name: order; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public."order" (
    id integer NOT NULL,
    orderid character varying(100),
    status character varying(100),
    paymenttype character varying(100),
    userid integer,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public."order" OWNER TO phong_admin;

--
-- TOC entry 223 (class 1259 OID 16531)
-- Name: order_id_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_id_seq OWNER TO phong_admin;

--
-- TOC entry 4441 (class 0 OID 0)
-- Dependencies: 223
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.order_id_seq OWNED BY public."order".id;


--
-- TOC entry 234 (class 1259 OID 16673)
-- Name: ordered_product; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.ordered_product (
    oid integer NOT NULL,
    name character varying(250),
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    image character varying(255),
    orderid integer NOT NULL,
    vendor_id integer,
    CONSTRAINT ordered_product_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.ordered_product OWNER TO phong_admin;

--
-- TOC entry 233 (class 1259 OID 16672)
-- Name: ordered_product_oid_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.ordered_product_oid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ordered_product_oid_seq OWNER TO phong_admin;

--
-- TOC entry 4442 (class 0 OID 0)
-- Dependencies: 233
-- Name: ordered_product_oid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.ordered_product_oid_seq OWNED BY public.ordered_product.oid;


--
-- TOC entry 230 (class 1259 OID 16628)
-- Name: product; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.product (
    pid integer NOT NULL,
    name character varying(250) NOT NULL,
    description character varying(500),
    price numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    discount integer,
    image character varying(255),
    cid integer,
    vendor_id integer NOT NULL,
    CONSTRAINT product_discount_check CHECK (((discount >= 0) AND (discount <= 100))),
    CONSTRAINT product_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT product_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.product OWNER TO phong_admin;

--
-- TOC entry 229 (class 1259 OID 16627)
-- Name: product_pid_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.product_pid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_pid_seq OWNER TO phong_admin;

--
-- TOC entry 4443 (class 0 OID 0)
-- Dependencies: 229
-- Name: product_pid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.product_pid_seq OWNED BY public.product.pid;


--
-- TOC entry 226 (class 1259 OID 16575)
-- Name: review; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.review (
    review_id integer NOT NULL,
    rating integer NOT NULL,
    comment text,
    review_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.review OWNER TO phong_admin;

--
-- TOC entry 225 (class 1259 OID 16574)
-- Name: review_review_id_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.review_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.review_review_id_seq OWNER TO phong_admin;

--
-- TOC entry 4444 (class 0 OID 0)
-- Dependencies: 225
-- Name: review_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.review_review_id_seq OWNED BY public.review.review_id;


--
-- TOC entry 220 (class 1259 OID 16480)
-- Name: user; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public."user" (
    userid integer NOT NULL,
    name character varying(100),
    email character varying(45),
    password character varying(255),
    phone character varying(20),
    gender character varying(20),
    registerdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    address character varying(250),
    city character varying(100),
    postcode character varying(10),
    county character varying(100)
);


ALTER TABLE public."user" OWNER TO phong_admin;

--
-- TOC entry 219 (class 1259 OID 16479)
-- Name: user_userid_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.user_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_userid_seq OWNER TO phong_admin;

--
-- TOC entry 4445 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.user_userid_seq OWNED BY public."user".userid;


--
-- TOC entry 228 (class 1259 OID 16607)
-- Name: vendor; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.vendor (
    vendor_id integer NOT NULL,
    shop_name character varying(150) NOT NULL,
    owner_user_id integer NOT NULL,
    business_email character varying(100),
    business_phone character varying(20),
    registration_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_approved boolean DEFAULT false NOT NULL
);


ALTER TABLE public.vendor OWNER TO phong_admin;

--
-- TOC entry 227 (class 1259 OID 16606)
-- Name: vendor_vendor_id_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.vendor_vendor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vendor_vendor_id_seq OWNER TO phong_admin;

--
-- TOC entry 4446 (class 0 OID 0)
-- Dependencies: 227
-- Name: vendor_vendor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.vendor_vendor_id_seq OWNED BY public.vendor.vendor_id;


--
-- TOC entry 236 (class 1259 OID 16695)
-- Name: wishlist; Type: TABLE; Schema: public; Owner: phong_admin
--

CREATE TABLE public.wishlist (
    idwishlist integer NOT NULL,
    iduser integer NOT NULL,
    idproduct integer NOT NULL
);


ALTER TABLE public.wishlist OWNER TO phong_admin;

--
-- TOC entry 235 (class 1259 OID 16694)
-- Name: wishlist_idwishlist_seq; Type: SEQUENCE; Schema: public; Owner: phong_admin
--

CREATE SEQUENCE public.wishlist_idwishlist_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wishlist_idwishlist_seq OWNER TO phong_admin;

--
-- TOC entry 4447 (class 0 OID 0)
-- Dependencies: 235
-- Name: wishlist_idwishlist_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phong_admin
--

ALTER SEQUENCE public.wishlist_idwishlist_seq OWNED BY public.wishlist.idwishlist;


--
-- TOC entry 4192 (class 2604 OID 16476)
-- Name: admin id; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.admin ALTER COLUMN id SET DEFAULT nextval('public.admin_id_seq'::regclass);


--
-- TOC entry 4204 (class 2604 OID 16655)
-- Name: cart id; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.cart ALTER COLUMN id SET DEFAULT nextval('public.cart_id_seq'::regclass);


--
-- TOC entry 4195 (class 2604 OID 16497)
-- Name: category cid; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.category ALTER COLUMN cid SET DEFAULT nextval('public.category_cid_seq'::regclass);


--
-- TOC entry 4196 (class 2604 OID 16535)
-- Name: order id; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."order" ALTER COLUMN id SET DEFAULT nextval('public.order_id_seq'::regclass);


--
-- TOC entry 4205 (class 2604 OID 16676)
-- Name: ordered_product oid; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.ordered_product ALTER COLUMN oid SET DEFAULT nextval('public.ordered_product_oid_seq'::regclass);


--
-- TOC entry 4203 (class 2604 OID 16631)
-- Name: product pid; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.product ALTER COLUMN pid SET DEFAULT nextval('public.product_pid_seq'::regclass);


--
-- TOC entry 4198 (class 2604 OID 16578)
-- Name: review review_id; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.review ALTER COLUMN review_id SET DEFAULT nextval('public.review_review_id_seq'::regclass);


--
-- TOC entry 4193 (class 2604 OID 16483)
-- Name: user userid; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."user" ALTER COLUMN userid SET DEFAULT nextval('public.user_userid_seq'::regclass);


--
-- TOC entry 4200 (class 2604 OID 16610)
-- Name: vendor vendor_id; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.vendor ALTER COLUMN vendor_id SET DEFAULT nextval('public.vendor_vendor_id_seq'::regclass);


--
-- TOC entry 4206 (class 2604 OID 16698)
-- Name: wishlist idwishlist; Type: DEFAULT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.wishlist ALTER COLUMN idwishlist SET DEFAULT nextval('public.wishlist_idwishlist_seq'::regclass);


--
-- TOC entry 4413 (class 0 OID 16473)
-- Dependencies: 218
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public.admin VALUES (1, 'Phong Phan', 'test@gmail.com', '$2a$12$lgpiOOuM42NbkoJoVKhfWO3TjJcSMnBnK5V3l/veOG4SNsewlrIBu', '01614960123');
INSERT INTO public.admin VALUES (2, 'Phong Phan', 'test34@gmail.com', '$2a$12$CoEFRs6.c..zF9MWySCSX.MCRdCTPbQmfb.ZGQkl1wZX2Ollv2rie', '01174960987');


--
-- TOC entry 4427 (class 0 OID 16652)
-- Dependencies: 232
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: phong_admin
--



--
-- TOC entry 4417 (class 0 OID 16494)
-- Dependencies: 222
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public.category VALUES (5, 'Books', '956b6f44-9d62-4b6a-a081-3879b2fdd34e.jpg');
INSERT INTO public.category VALUES (6, 'Clothes & Fashion', '29ba6cd5-2715-4391-8e88-a30673a58649.jpg');
INSERT INTO public.category VALUES (7, 'Electronics', '6842ea71-b4c1-45e0-b3bf-df9a0ffea6ce.jpg');
INSERT INTO public.category VALUES (4, 'Home & Furniture', 'b9b0e6c4-1a50-481a-8fd6-1a74c61da599.jpg');
INSERT INTO public.category VALUES (3, 'Laptops', '508f1af8-2a4d-47d5-8419-fb1c4ef5a433.jpg');
INSERT INTO public.category VALUES (1, 'Mobiles', '3fa0986c-b753-4bf3-a918-3937d8b43285.jpg');
INSERT INTO public.category VALUES (10, 'Appliances', 'f7d58a6e-3af1-42bb-a6c6-291248662e91.jpg');


--
-- TOC entry 4419 (class 0 OID 16532)
-- Dependencies: 224
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public."order" VALUES (2, 'ORD-20230924110928', 'Order Placed', 'COD', 1, '2025-04-03 23:29:51.358832');
INSERT INTO public."order" VALUES (3, 'ORD-20230924111023', 'Order Placed', 'COD', 1, '2025-04-03 23:29:51.358832');
INSERT INTO public."order" VALUES (4, 'ORD-20230924111502', 'Order Placed', 'COD', 1, '2025-04-03 23:29:51.358832');
INSERT INTO public."order" VALUES (7, 'ORD-20230924115652', 'Order Placed', 'online', 1, '2025-04-03 23:29:51.358832');
INSERT INTO public."order" VALUES (10, 'ORD-20250415083713', 'Delivered', 'Card Payment', 3, '2025-04-15 20:37:13.08947');
INSERT INTO public."order" VALUES (11, 'ORD-20250422061542', 'Delivered', 'Cash on Delivery', 3, '2025-04-22 18:15:42.680413');
INSERT INTO public."order" VALUES (9, 'ORD-20250415063741', 'Delivered', 'Card Payment', 3, '2025-04-15 18:37:41.448456');
INSERT INTO public."order" VALUES (8, 'ORD-20250414110051', 'Delivered', 'Card Payment', 1, '2025-04-14 23:00:51.47538');
INSERT INTO public."order" VALUES (5, 'ORD-20230924112315', 'Order Confirmed', 'COD', 1, '2025-04-03 23:29:51.358832');
INSERT INTO public."order" VALUES (6, 'ORD-20230924115427', 'Shipped', 'online', 1, '2025-04-03 23:29:51.358832');
INSERT INTO public."order" VALUES (12, 'ORD-20250426035637', 'Order Placed', 'Cash on Delivery', 3, '2025-04-26 15:56:37.610427');
INSERT INTO public."order" VALUES (1, 'ORD-20230924105716', 'Shipped', 'COD', 1, '2025-04-03 23:29:51.358832');


--
-- TOC entry 4429 (class 0 OID 16673)
-- Dependencies: 234
-- Data for Name: ordered_product; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public.ordered_product VALUES (1, 'ASUS ROG Strix G16 (2023) Gaming Laptop', 1, 1190.00, '49290f69-43b9-4680-ba44-4d881329e8ea.png', 11, 2);
INSERT INTO public.ordered_product VALUES (2, 'ASUS ROG Strix G16 (2023) Gaming Laptop', 1, 1190.00, '49290f69-43b9-4680-ba44-4d881329e8ea.png', 12, 2);


--
-- TOC entry 4425 (class 0 OID 16628)
-- Dependencies: 230
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public.product VALUES (1, 'ASUS ROG Strix G16 (2023) Gaming Laptop', 'laptop', 1400.00, 1, 15, '49290f69-43b9-4680-ba44-4d881329e8ea.png', 3, 2);
INSERT INTO public.product VALUES (3, 'Simba Hybrid Essential Double Mattres', 'Matres', 499.00, 2, 5, '38f782b5-ad60-46c0-b1bc-29f55d7c204d.jpg', 4, 2);
INSERT INTO public.product VALUES (2, 'Apple iPhone 15 (128GB) - Black', 'Iphones', 699.00, 3, 0, '0ab30284-cc2c-432d-81cf-9b4662fb59b1.jpg', 1, 2);
INSERT INTO public.product VALUES (4, 'Harry Potter Box Set: The Complete Collection', 'You are a wizard, Harry!', 70.00, 4, 30, '780cd400-b692-4dda-bda0-6a86d9bf5885.jpg', 5, 2);
INSERT INTO public.product VALUES (5, 'Samsung Galaxy S23 (256GB) - Phantom Black', 'Samsung', 499.00, 2, 0, 'a465c359-2327-40ea-a6dd-9c6911838d1b.jpg', 1, 2);
INSERT INTO public.product VALUES (6, 'Samsung Bespoke RB34T632ESA 70/30 Fridge Freezer - Silver', 'Fridge', 419.00, 3, 0, 'a31b45a6-7390-4b78-b632-b76c9d288d31.jpg', 10, 2);
INSERT INTO public.product VALUES (7, 'LG C3 55" OLED evo 4K Smart TV (2023 Model)', 'TV', 899.00, 1, 0, 'c6ff85b5-70e2-4544-9855-8b876ad088db.jpg', 4, 2);
INSERT INTO public.product VALUES (8, 'The Story of London', 'Book', 5.99, 2, 10, 'faa32236-bdb3-4375-b063-7105c90ce184.png', 5, 2);
INSERT INTO public.product VALUES (9, 'Sony WH-1000XM5 Noise Cancelling Headphones - Black', 'Headphone', 279.00, 1, 0, 'ebd39b8d-5200-4200-b5e4-fe7e362d1912.png', 7, 2);
INSERT INTO public.product VALUES (10, 'Superdry Mens Everest Hooded Bomber Jacket - Navy', 'Shirt', 91.00, 1, 0, '7a2db7b1-94b6-4be4-9edc-78f3fb17aecd.jpg', 6, 2);


--
-- TOC entry 4421 (class 0 OID 16575)
-- Dependencies: 226
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public.review VALUES (2, 1, 'Really bad product', '2025-04-14 21:36:15.135108', 2, 8);
INSERT INTO public.review VALUES (1, 5, 'Really sensational product', '2025-04-14 22:21:04.934475', 1, 8);
INSERT INTO public.review VALUES (3, 5, 'I got an iPhone instead a Samsung', '2025-04-14 22:26:49.050432', 1, 4);
INSERT INTO public.review VALUES (4, 5, 'Look at this, I am reviewing stuff???!!!', '2025-04-15 17:10:31.124968', 1, 5);
INSERT INTO public.review VALUES (5, 2, 'My back hurt', '2025-04-16 14:47:39.491151', 3, 8);


--
-- TOC entry 4415 (class 0 OID 16480)
-- Dependencies: 220
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public."user" VALUES (2, 'Bob Jones', 'b.jones@example.co.uk', 'hashed_user_pw2', '02079460987', 'Male', '2025-04-03 23:28:07.670955', 'Flat 5, The Old Mill', 'Bristol', 'BS1 5TT', 'Bristol');
INSERT INTO public."user" VALUES (1, 'Alice Smith', 'alice.s@example.com', '$2a$12$uyWo1/WbQukd9tlDEgcx1uzw3ektIsoL64jRHcPV4TfZeT.sVbkqq', '07700900123', 'Female', '2025-04-03 23:28:07.670955', '10 Church Lane', 'Manchester', 'M1 1AA', 'Greater Manchester');
INSERT INTO public."user" VALUES (3, 'Phong', 'thandongdatviettatca@gmail.com', '$2a$12$dFqKVhQiLaYbOKx2FVT8WutqCpPDpQtXoB1jYoTKas6o9ZMHYtqsu', '07595246660', 'Male', '2025-04-15 18:35:44.182132', 'University of the West of England, Room C', 'Bristol', 'BS16 1FU', 'Somerset');
INSERT INTO public."user" VALUES (5, 'Phong', 'pmphong1999@gmail.com', '$2a$12$32yVjWdMfKovgmQ4ULJxxeNlxknlR99GCWSQOm5owa2bP2q.2xB6u', '0908989555', 'Vendor', '2025-04-22 01:43:00.782071', '', '', '', '');


--
-- TOC entry 4423 (class 0 OID 16607)
-- Dependencies: 228
-- Data for Name: vendor; Type: TABLE DATA; Schema: public; Owner: phong_admin
--

INSERT INTO public.vendor VALUES (2, 'Minh Phan', 5, '', '', '2025-04-22 01:43:00.859803', true);
INSERT INTO public.vendor VALUES (1, 'Phong Shop (Platform)', 3, 'admin@phongphan.me', NULL, '2025-04-21 19:07:20.457497', true);


--
-- TOC entry 4431 (class 0 OID 16695)
-- Dependencies: 236
-- Data for Name: wishlist; Type: TABLE DATA; Schema: public; Owner: phong_admin
--



--
-- TOC entry 4448 (class 0 OID 0)
-- Dependencies: 217
-- Name: admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.admin_id_seq', 2, true);


--
-- TOC entry 4449 (class 0 OID 0)
-- Dependencies: 231
-- Name: cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.cart_id_seq', 1, true);


--
-- TOC entry 4450 (class 0 OID 0)
-- Dependencies: 221
-- Name: category_cid_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.category_cid_seq', 10, true);


--
-- TOC entry 4451 (class 0 OID 0)
-- Dependencies: 223
-- Name: order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.order_id_seq', 12, true);


--
-- TOC entry 4452 (class 0 OID 0)
-- Dependencies: 233
-- Name: ordered_product_oid_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.ordered_product_oid_seq', 2, true);


--
-- TOC entry 4453 (class 0 OID 0)
-- Dependencies: 229
-- Name: product_pid_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.product_pid_seq', 10, true);


--
-- TOC entry 4454 (class 0 OID 0)
-- Dependencies: 225
-- Name: review_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.review_review_id_seq', 5, true);


--
-- TOC entry 4455 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.user_userid_seq', 5, true);


--
-- TOC entry 4456 (class 0 OID 0)
-- Dependencies: 227
-- Name: vendor_vendor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.vendor_vendor_id_seq', 2, true);


--
-- TOC entry 4457 (class 0 OID 0)
-- Dependencies: 235
-- Name: wishlist_idwishlist_seq; Type: SEQUENCE SET; Schema: public; Owner: phong_admin
--

SELECT pg_catalog.setval('public.wishlist_idwishlist_seq', 1, true);


--
-- TOC entry 4214 (class 2606 OID 16478)
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id);


--
-- TOC entry 4245 (class 2606 OID 16658)
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- TOC entry 4247 (class 2606 OID 16660)
-- Name: cart cart_uid_pid_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_uid_pid_key UNIQUE (uid, pid);


--
-- TOC entry 4222 (class 2606 OID 16499)
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (cid);


--
-- TOC entry 4224 (class 2606 OID 16538)
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- TOC entry 4251 (class 2606 OID 16681)
-- Name: ordered_product ordered_product_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.ordered_product
    ADD CONSTRAINT ordered_product_pkey PRIMARY KEY (oid);


--
-- TOC entry 4243 (class 2606 OID 16638)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (pid);


--
-- TOC entry 4228 (class 2606 OID 16584)
-- Name: review review_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (review_id);


--
-- TOC entry 4230 (class 2606 OID 16586)
-- Name: review review_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_user_id_product_id_key UNIQUE (user_id, product_id);


--
-- TOC entry 4216 (class 2606 OID 16490)
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- TOC entry 4218 (class 2606 OID 16492)
-- Name: user user_phone_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_phone_key UNIQUE (phone);


--
-- TOC entry 4220 (class 2606 OID 16488)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (userid);


--
-- TOC entry 4233 (class 2606 OID 16620)
-- Name: vendor vendor_business_email_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_business_email_key UNIQUE (business_email);


--
-- TOC entry 4235 (class 2606 OID 16618)
-- Name: vendor vendor_owner_user_id_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_owner_user_id_key UNIQUE (owner_user_id);


--
-- TOC entry 4237 (class 2606 OID 16614)
-- Name: vendor vendor_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_pkey PRIMARY KEY (vendor_id);


--
-- TOC entry 4239 (class 2606 OID 16616)
-- Name: vendor vendor_shop_name_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_shop_name_key UNIQUE (shop_name);


--
-- TOC entry 4253 (class 2606 OID 16702)
-- Name: wishlist wishlist_iduser_idproduct_key; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_iduser_idproduct_key UNIQUE (iduser, idproduct);


--
-- TOC entry 4255 (class 2606 OID 16700)
-- Name: wishlist wishlist_pkey; Type: CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_pkey PRIMARY KEY (idwishlist);


--
-- TOC entry 4248 (class 1259 OID 16692)
-- Name: idx_ordered_product_orderid; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_ordered_product_orderid ON public.ordered_product USING btree (orderid);


--
-- TOC entry 4249 (class 1259 OID 16693)
-- Name: idx_ordered_product_vendor_id; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_ordered_product_vendor_id ON public.ordered_product USING btree (vendor_id);


--
-- TOC entry 4240 (class 1259 OID 16650)
-- Name: idx_product_category_id; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_product_category_id ON public.product USING btree (cid);


--
-- TOC entry 4241 (class 1259 OID 16649)
-- Name: idx_product_vendor_id; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_product_vendor_id ON public.product USING btree (vendor_id);


--
-- TOC entry 4225 (class 1259 OID 16597)
-- Name: idx_review_product_id; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_review_product_id ON public.review USING btree (product_id);


--
-- TOC entry 4226 (class 1259 OID 16598)
-- Name: idx_review_user_id; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_review_user_id ON public.review USING btree (user_id);


--
-- TOC entry 4231 (class 1259 OID 16626)
-- Name: idx_vendor_owner_user_id; Type: INDEX; Schema: public; Owner: phong_admin
--

CREATE INDEX idx_vendor_owner_user_id ON public.vendor USING btree (owner_user_id);


--
-- TOC entry 4261 (class 2606 OID 16666)
-- Name: cart cart_pid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pid_fkey FOREIGN KEY (pid) REFERENCES public.product(pid) ON DELETE CASCADE;


--
-- TOC entry 4262 (class 2606 OID 16661)
-- Name: cart cart_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_uid_fkey FOREIGN KEY (uid) REFERENCES public."user"(userid) ON DELETE CASCADE;


--
-- TOC entry 4258 (class 2606 OID 16621)
-- Name: vendor fk_vendor_owner; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT fk_vendor_owner FOREIGN KEY (owner_user_id) REFERENCES public."user"(userid) ON DELETE CASCADE;


--
-- TOC entry 4256 (class 2606 OID 16539)
-- Name: order order_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_userid_fkey FOREIGN KEY (userid) REFERENCES public."user"(userid);


--
-- TOC entry 4263 (class 2606 OID 16682)
-- Name: ordered_product ordered_product_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.ordered_product
    ADD CONSTRAINT ordered_product_orderid_fkey FOREIGN KEY (orderid) REFERENCES public."order"(id) ON DELETE CASCADE;


--
-- TOC entry 4264 (class 2606 OID 16687)
-- Name: ordered_product ordered_product_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.ordered_product
    ADD CONSTRAINT ordered_product_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendor(vendor_id) ON DELETE SET NULL;


--
-- TOC entry 4259 (class 2606 OID 16639)
-- Name: product product_cid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_cid_fkey FOREIGN KEY (cid) REFERENCES public.category(cid) ON DELETE SET NULL;


--
-- TOC entry 4260 (class 2606 OID 16644)
-- Name: product product_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendor(vendor_id) ON DELETE CASCADE;


--
-- TOC entry 4257 (class 2606 OID 16587)
-- Name: review review_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(userid) ON DELETE CASCADE;


--
-- TOC entry 4265 (class 2606 OID 16708)
-- Name: wishlist wishlist_idproduct_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_idproduct_fkey FOREIGN KEY (idproduct) REFERENCES public.product(pid) ON DELETE CASCADE;


--
-- TOC entry 4266 (class 2606 OID 16703)
-- Name: wishlist wishlist_iduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: phong_admin
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_iduser_fkey FOREIGN KEY (iduser) REFERENCES public."user"(userid) ON DELETE CASCADE;


-- Completed on 2025-05-01 01:40:14

--
-- PostgreSQL database dump complete
--

