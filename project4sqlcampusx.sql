use projects;
select * from swiggy;

select 
sum(case when hotel_name = '' then 1 else 0 end ) as hotel_name,
sum(case when rating = '' then 1 else 0 end ) as rating,
sum(case when time_minutes = '' then 1 else 0 end ) as time_minutes,
sum(case when food_type = '' then 1 else 0 end ) as food_type,
sum(case when location = '' then 1 else 0 end ) as location,
sum(case when offer_above = '' then 1 else 0 end ) as offer_above,
sum(case when offer_percentage = '' then 1 else 0 end ) as offer_percentage 
from swiggy; 

select* from information_schema.columns  where table_name= 'swiggy';
select column_name from information_schema.columns  where table_name= 'swiggy';

delimiter //
create procedure  count_blank_rows()
begin
	select group_concat(
			concat('sum(case when`', column_name, '`='''' Then 1 else 0 end) as `', column_name ,'`')
			) into @sql 
			from information_schema.columns  where table_name= 'swiggy';
		set @sql = concat('select ', @sql,' from swiggy');

		prepare smt from  @sql;
		execute  smt ;
		deallocate  prepare smt;
	end
//
call count_blank_rows() ;

select * from swiggy;

DELIMITER $$
CREATE FUNCTION f_name(input_str VARCHAR(255))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN CAST(SUBSTRING_INDEX(input_str, '-', 1) AS UNSIGNED);
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION l_name(input_str VARCHAR(255))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN CAST(SUBSTRING_INDEX(input_str, '-', -1) AS UNSIGNED);
END $$
DELIMITER ;

create table clean as
select * from swiggy where rating like '%mins%';

select * from clean;

create table cleaned as 
select * , f_name(rating) as f1 from clean ;

update swiggy as s
inner join cleaned as c
on s.hotel_name = c.hotel_name
set s.time_minutes= c.f1;

select * from swiggy where rating like '%mins%';
drop table clean , cleaned;

create table clean as
select * from swiggy where time_minutes like '%-%';

create table cleaned as 
select * ,f_name(time_minutes) as f1,l_name(time_minutes) as f2 from clean where time_minutes like '%-%';

update swiggy as s
inner join cleaned as c
on s.hotel_name = c.hotel_name
set s.time_minutes= ((c.f1 +c.f2)/2);

select * from swiggy where hotel_name = 'MOJO Pizza - 2X Toppings';

 -- time_minutes column is cleaned

 -- Cleaning rating column.

select * from swiggy where rating like '%mins%';

update swiggy as s 
inner join (
select location, round(avg(rating),2) as average
from swiggy
where rating not like '%mins%'
group by location ) as t
on s.location = t.location
set s.rating = t.average
where s.rating like '%mins%';

select  * from swiggy where rating like '%mins%';
set @tot_Avg = (select round(avg(rating),2) as average
from swiggy
where rating not like '%mins%'
);

update  swiggy 
set rating = @tot_avg 
where rating like '%mins%';
-- our rating column is also cleaned.

select distinct(location) from swiggy where  location like '%Kandivali%' ;
select distinct location from swiggy where  location like '%Kandivali%' and location like '%W%';

update swiggy
set location  ='Kandivali East'
where location like '%East%' and location like '%Kandivali%';

update swiggy
set location  ='Kandivali West'
where location like '%West%' and location like '%Kandivali%';

update swiggy
set location  ='Kandivali East'
where location like '%E%' and location like '%Kandivali%';

update swiggy
set location  ='Kandivali West'
where location like '%W%' and location like '%Kandivali%';

   -- location column is also cleaned.
   
select * from swiggy;

-- cleaning offer_precentage column.

update swiggy
set offer_percentage = 0
where  offer_above = 'not_available' ;

-- percentage column is also cleaned.

-- cleaning food_type column

select food_type from swiggy;
select substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',5);
select substring_index( substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',4),',', -1);



select char_length('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks');
select char_length(replace('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',''));


select distinct food from 
(
select *, substring_index( substring_index(food_type ,',',numbers.n),',', -1) as 'food'
from  swiggy 
	join
	(
		select 1+a.N + b.N*10 as n from 
		(
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9) a
			cross join 
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9)b
		)
	)  as numbers 
    on  char_length(food_type)  - char_length(replace(food_type ,',','')) >= numbers.n-1 
    ) as a ;

create table swiggy_cleaned as (
select hotel_name ,rating,time_minutes,location,offer_above,offer_percentage, substring_index( substring_index(food_type ,',',numbers.n),',', -1) as 'food'
from  swiggy 
	join
	(
		select 1+a.N + b.N*10 as n from 
		(
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9) a
			cross join 
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9)b
		)
	)  as numbers 
    on  char_length(food_type)  - char_length(replace(food_type ,',','')) >= numbers.n-1 
    ) ;
    
select * from swiggy_cleaned;