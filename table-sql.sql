create table data_orders (
  [order_id] int primary key
, [order_date] date
, [ship_mode] varchar(30)
, [segment] varchar(30)
, [country] varchar(30)
, [city] varchar(30)
, [state] varchar(30)
, [postal_code] varchar(30)
, [region] varchar(30)
, [category] varchar(30)
, [sub_category] varchar(30)
, [product_id] varchar(50)
, [quantity] int
, [discount] decimal(7,2)
, [sale_price] decimal(7,2)
, [profit] decimal(7,2))

