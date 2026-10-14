drop table if exists users, sellers, categories, products, stock, carts, cart_items, order_items, payments, reviews, orders, deliveries, addresses;
drop type if exists order_status, payment_status,delivery_status;

create type order_status as enum (
    'created', 'paid', 'shipped', 'delivered', 'cancelled'
);

create type payment_status as enum (
    'pending', 'completed', 'failed', 'refunded'
);

create type delivery_status as enum (
    'pending', 'in_transit', 'delivered', 'returned'
);

create table users (
  id bigint generated always as identity primary key,
  Name text not null unique,
  email text not null unique,
  created_at timestamp not null default now()
);

create table sellers (
    id bigint generated always as identity primary key,
	user_id bigint references users(id),
    store_name text not null unique,
	description text,
    created_at timestamp not null default now()
);

create table categories (
    id bigint generated always as identity primary key,
    parent_id bigint references categories(id) on delete restrict,
    name text not null unique
);

create table products (
    id bigint generated always as identity primary key ,
    seller_id bigint not null references sellers(id) on delete restrict,
    category_id bigint not null references categories(id),
    title text not null ,
    price numeric(12,2) not null check (price > 0),
    is_active boolean not null default true,
    created_at timestamp not null default now()
);

create table stock(
	id bigint primary key references products(id) on delete cascade,
	quantity integer not null default 0 check (quantity >= 0),
	update_at timestamptz not null default now()
);

create table carts (
	id bigint generated always as identity primary key,
	user_id bigint not null references users(id) on delete cascade,
	created_at timestamptz not null default now()
);

create table cart_items (
	cart_id bigint not null references carts(id) on delete cascade,
	product_id bigint not null references products(id) on delete cascade,
	quantity integer not null check (quantity > 0)
);

create table orders (
	id bigint generated always as identity primary key,
	user_id bigint not null references users(id) on delete restrict,
	status order_status not null default 'created',
	total_amount numeric(12,2) not null default 0 check (total_amount >= 0),
	created_at timestamptz not null default now()
);

create table order_items (
	order_id bigint not null references orders(id) on delete cascade,
	product_id bigint not null references products(id) on delete restrict,
	quantity integer not null check (quantity > 0),
	unit_price numeric(12,2) not null check (unit_price > 0)
);

create table payments (
	id bigint generated always as identity primary key,
	order_id bigint not null unique references orders(id) on delete cascade,
	amount numeric(12,2) not null check (amount > 0),
	status payment_status not null default  'pending' ,
	paid_at timestamptz
);

create table reviews (
	id bigint generated always as identity primary key,
	user_id bigint not null references users(id) on delete cascade,
	product_id bigint not null references products(id) on delete cascade,
	score smallint not null check (score between 1 and 5),
	comment text,
	unique (user_id , product_id)
);

create table adresses (
	id bigint generated always as identity primary key,
	user_id bigint not null references users(id) on delete cascade,
	city text not null,
	street text not null,
	house text not null,
	apartment text not null
);

create table deliveries (
	id bigint generated always as identity primary key,
	order_id bigint not null unique references orders(id) on delete cascade,
	address_id bigint not null references adresses(id) on delete restrict,
	status delivery_status not null default 'pending',
	delivery_date timestamptz
);