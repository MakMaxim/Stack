create table Customers( 				  -- Заказчики
   row_id int generated always as identity not null, 
   name text not null,					  -- наименование заказчика
   constraint PK_Customers primary key (row_id)
)

create table Orders(					  -- Заказы
   row_id int generated always as identity not null,
   parent_id int,                         -- row_id родительской группы
   group_name text,              		  -- наименование группы заказов
   customer_id int,                       -- row_id заказчика
   registered_at date,                     -- дата регистрации заказа
   constraint PK_Orders primary key(row_id),
   constraint FK_Orders_Folder foreign key (parent_id) references Orders(row_id)
      on delete no action
      on update no action,
   constraint FK_Customers foreign key (customer_id) references Customers(row_id)
      on delete cascade
      on update cascade
)

create table OrderItems(				  -- Позиции заказов
   row_id int generated always as identity not null,
   order_id int not null,                 -- row_id заказа
   name text not null,           		  -- наименование позиции
   price int not null,                    -- стоимость позиции в рублях
   constraint PK_OrderItems primary key (row_id),
   constraint FK_OrderItems_Orders foreign key (order_id) references Orders(row_id)
      on delete cascade
      on update cascade
)

insert into Customers (name)
values
(N'Иванов'),
(N'Петров'),
(N'Сидоров'),
(N'ИП Федоров')

insert into Orders(parent_id, group_name, customer_id, registered_at)
values 
(null, N'Все заказы', null, null),
(1, N'Частные лица', null, null),
(2, N'Оргтехника', null, null),
(3, null, 1, '2019/10/02'),
(3, null, 1, '2020/05/17'),
(3, null, 1, '2020/04/28'),
(3, null, 2, '2019/08/05'),
(3, null, 2, '2020/05/17'),
(3, null, 2, '2020/02/11'),
(2, N'Канцелярия', null, null),
(10, null, 3, '2020/04/09'),
(1, N'Юридические лица', null, null),
(12, null, 4, '2020/06/25')

insert into OrderItems(order_id, name, price)
values 
(4, N'Принтер', 30),
(4, N'Факс', 20),
(5, N'Принтер', 50),
(5, N'Кассовый аппарат', 40),
(5, N'Факс', 30),
(6, N'Кассовый аппарат', 30),
(6, N'Кассовый аппарат', 40),
(7, N'Копировальный аппарат', 50),
(7, N'Калькулятор', 10),
(7, N'Кассовый аппарат', 60),
(8, N'Принтер', 50),
(8, N'Калькулятор', 10),
(9, N'Телефонный аппарат', 50),
(9, N'Кассовый аппарат', 40),
(11, N'Бумага', 2),
(11, N'Ручки', 1),
(13, N'Кулер', 100),
(13, N'Стулья', 70),
(13, N'Факс', 20)

select * from customers;
select * from orders;
select * from orderitems;

----------------------------- Задание 1 --------------------------------------------------
create or replace function select_orders_by_item_name(order_name text, out order_id int, out customer text, out items_count int)
		returns setof record as $$
	select os.order_id, c.name, count(os.order_id)
	from orderitems os
	join orders o on os.order_id = o.row_id
	join customers c on o.customer_id = c.row_id
	where os.name = order_name
	group by os.order_id, c.name
$$ language sql

select * from select_orders_by_item_name(N'Факс');
select * from select_orders_by_item_name(N'Кассовый аппарат');
select * from select_orders_by_item_name(N'Стулья');
------------------------------------------------------------------------------------------

---------------------------- Задание 2 ---------------------------------------------------
create or replace function calculate_total_price_for_orders_group(id int, out total_price float8)
		returns setof double precision as $$
	with recursive noname as(
		select 
			o.row_id, o.parent_id, o.group_name, os.name, os.price
		from 
			orders o left join orderitems os on o.row_id = os.order_id
		where 
			o.row_id = id
		union 
		select
			o.row_id, o.parent_id, o.group_name, os.name, os.price
		from 
			noname n
			join orders o left join orderitems os on o.row_id = os.order_id
				on n.row_id = o.parent_id
	)
	select sum(price) from noname
$$ language sql

select * from calculate_total_price_for_orders_group(1);
select * from calculate_total_price_for_orders_group(2);
select * from calculate_total_price_for_orders_group(3);
select * from calculate_total_price_for_orders_group(12);
select * from calculate_total_price_for_orders_group(13);
------------------------------------------------------------------------------------------


---------------------------- Задание 3 ---------------------------------------------------
select all_customers.name from(
	select os.order_id, c.name, count(distinct case
												   when os.name = N'Кассовый аппарат' then 1
											   end) as cash_machine
	from orderitems os
	join orders o on os.order_id = o.row_id
	join customers c on o.customer_id = c.row_id
	where date_part ('year', o.registered_at) = 2020
	group by os.order_id, c.name
) as all_customers
group by all_customers.name
having count(*) <= sum(all_customers.cash_machine)
------------------------------------------------------------------------------------------
