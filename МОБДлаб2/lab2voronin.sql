truncate table
    deliveries, adresses, reviews, payments,
    order_items, orders, cart_items, carts,
    stock, products, categories, sellers, users
restart identity cascade;

insert into users (Name, email)
select
	'user_' || g,
    'user_' || g || '@mail.com'
from generate_series(1, 100) AS g;

insert into sellers (user_id, store_name, description)
select
    g,
    'store_' || g,
    'Магазин №' || g || ' на маркетплейсе'
from generate_series(1, 20) as g;

insert into categories (name) values
    ('электроника'), ('книги'), ('одежда'), ('дом'), ('спорт');

insert into categories (parent_id, name) values
    (1, 'телефоны'), (1, 'пк'), (1, 'наушники'),
    (2, 'манга'), (2, 'манхва'),
    (3, 'плавательная'), (3, 'спортивная'),
    (4, 'мебель'), (4, 'посуда'),
    (5, 'велосипеды'), (5, 'бутылки для воды');

insert into products (seller_id, category_id, title, price, is_active)

select
    (random() * 19 + 1)::int,
    (random() * 9 + 6)::int,
    'товар №' || g,
    (random() * 9000 + 1000)::numeric(12,2),
    (random() < 0.9)
from generate_series(1, 1200) as g;

insert into stock (id, quantity)
select id, (random() * 500)::int
from products;

insert into carts (user_id)
select g from generate_series(1, 50) as g;

insert into cart_items (cart_id, product_id, quantity)
select
    (random() * 49 + 1)::int,
    (random() * 1199 + 1)::int,
    (random() * 4 + 1)::int
from generate_series(1, 300) as g;

insert into orders (user_id, status, total_amount, created_at)
select
    (random() * 99 + 1)::int,
    (array['created','paid','shipped','delivered','cancelled']::order_status[])
        [(random() * 4 + 1)::int],
    0,
    now() - ((random() * 365)::int || ' days')::interval
from generate_series(1, 1500) as g;

insert into order_items (order_id, product_id, quantity, unit_price)
select
    o.id,
    p.id,
    q.qty,
    p.price
from orders o
cross join lateral (
    select id, price
    from products
    order by random()
    limit 3
) as p
cross join lateral (
    select (random() * 3 + 1)::int as qty
) as q;

update orders o
set total_amount = coalesce((
    select sum(oi.quantity * oi.unit_price)
    from order_items oi
    where oi.order_id = o.id
), 0);

insert into payments (order_id, amount, status, paid_at)
select
    o.id,
    o.total_amount,
    'completed'::payment_status,
    o.created_at + interval '1 hour'
from orders o
where o.status in ('paid', 'shipped', 'delivered');

insert into adresses (user_id, city, street, house, apartment)
select
    (random() * 79 + 1)::int,
    (array['москва','санкт-петербург','казань','мухосранкс','варшава','холлов нест','фарлун'])
        [(random() * 4 + 1)::int],
    'ул. чернильный остров',
    (random() * 200 + 1)::int::text,
    (random() * 300 + 1)::int::text
from generate_series(1, 120) as g;

insert into reviews (user_id, product_id, score, comment)
select
    (random() * 99 + 1)::int,
    (random() * 1199 + 1)::int,
    (random() * 4 + 1)::int,
    case when random() < 0.3 then null
         else 'отзыв №' || g end
from generate_series(1, 500) as g
on conflict (user_id, product_id) do nothing;

insert into deliveries (order_id, address_id, status, delivery_date)
select
    o.id,
    (random() * 119 + 1)::int,
    case o.status
        when 'delivered' then 'delivered'::delivery_status
        else 'in_transit'::delivery_status
    end,
    o.created_at + interval '3 days'
from orders o
where o.status in ('shipped', 'delivered');

select distinct category_id from products; --2 задание техническое

select title, price from products --третье задание техническое
where (price > 8000 or price < 1000) and is_active = true;

select title, price from products --4 задание техническое(BETWEEN)
where price between 2000 and 3000;
select title, category_id from products --4 задание техническое(IN)
where category_id in (6, 7, 8);
select title from products --4 задание техническое(ILIKE)
where title ilike '%товар%';
select * from reviews --4 задание техническое(ISNULL)
where comment is null;

select title, price from products --5 задание техническое
order by price desc, title asc;

select title, price from products --6 задание техническое(1 часть)
order by id limit 10 offset 0;
select title, price from products --6 задание техническое(2 часть)
order by id limit 10 offset 10;
