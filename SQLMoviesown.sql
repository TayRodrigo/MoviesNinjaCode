--The data used in this project comes from https://www.codingninjas.com/studio/problems/imdb_1755910?topList=top-100-sql-problems&leftPanelTab=0 
--It contains 3 tables: genre, earnings and movies
--I converted them to excel and then uploaded to SQL with the names of GR for genre, ER for earnings and MV for Movies

SELECT *
FROM Projects..MV


--Let's beggin with a task taken from a web page in which they asked
--for the titles from 2012, that got mora than 60 in metacritic and 
--got more than 100000000 in domestic earnings
SELECT Title, domestic, B.Movie_id, MetaCritic
from Projects..ER A, Projects..MV B
WHERE A.Movie_id=B.Movie_id 
	AND Title like '%2012%' 
	AND Domestic > 100000000
	AND MetaCritic >60

--But what if we wanned only the names but not the years
SELECT substring(Title, -5, LEN(Title))
from Projects..MV
--What we have done here is to use the substring command
--with it we can use either positive or negative positions
--if we wanna start from the beggining or the end

--Let's extrack only the year
SELECT SUBSTRING(Title, charindex('20', Title,1),  4)
from Projects..MV

--Now let's add this new columns so the table has its information easier to manage
ALTER TABLE Projects..MV
DROP COLUMN YEAR

ALTER TABLE Projects..MV
	ADD YEAR NVARCHAR (255);
ALTER TABLE Projects..MV
	ADD MTITLE NVARCHAR(255);
--then fill up the columns
UPDATE Projects..MV
SET YEAR = SUBSTRING(Title, charindex('20', Title,1), 4), MTITLE = substring(Title, -5, LEN(Title))


--Let's check the genre table with the movies tables
SELECT *
FROM Projects..GR A, Projects..MV B
WHERE A.Movie_id=B.Movie_id 

--As we can see, there are many movies that are in more than one category
--but also, nulls that has repeated information, so we are going to delete them
DELETE FROM Projects..GR
WHERE genre='NULL'

--Also we can notice that there is a category called Music and anothe called musical, so
--If we check, those movies are la la land, whiplash and Sing Street, all musicals
SELECT *
FROM Projects..GR A, Projects..MV B
WHERE A.Movie_id=B.Movie_id AND genre= 'Musical'

--So now we're going to change their names
UPDATE Projects..GR
SET genre='Musical' 
Where Movie_id in (31069, 41048, 38262)

--So now that we have cleaned our data, we can do some other stuff
--some basics, like how many movies per genre there are
SELECT genre, count(genre) as "quantity"
FROM Projects..GR
GROUP BY genre
order by 2 DESC

--How much every genre have earned domesticly
SELECT genre, count(genre) as "quantity", SUM(Domestic) as "Domestic earnings"
FROM Projects..GR A, Projects..ER B
WHERE A.Movie_id=B.Movie_id
GROUP BY genre
ORDER BY 3 DESC

--How much every genre have earned WORLDWIDE
SELECT genre, count(genre) as "quantity", SUM(Worldwide) as "Worldwide earnings"
FROM Projects..GR A, Projects..ER B
WHERE A.Movie_id=B.Movie_id
GROUP BY genre
ORDER BY 3 DESC

--How much every genre have earned totaly
SELECT genre, count(genre) as "quantity", SUM(Worldwide) as "Worldwide earnings", SUM(Domestic) as "Domestic earnings", SUM(WORLDWIDE + DOMESTIC) AS "TOTAL"
FROM Projects..GR A, Projects..ER B
WHERE A.Movie_id=B.Movie_id  
GROUP BY genre
ORDER BY 5 DESC

--Now let's put some conditions over the agregated functions with having
SELECT genre, count(genre) as "quantity", SUM(Worldwide) as "Worldwide earnings", SUM(Domestic) as "Domestic earnings", SUM(WORLDWIDE + DOMESTIC) AS "TOTAL"
FROM Projects..GR A, Projects..ER B
WHERE A.Movie_id=B.Movie_id 
GROUP BY genre
HAVING SUM(WORLDWIDE + DOMESTIC) > 10000000000
ORDER BY 5 DESC

--Now let's check the runtime
--As we can see, there are many nulls there, so we have to replace them
--We can go two ways around
--On one hand, this:

 UPDATE Projects..MV
SET runtime='86 min' 
Where Movie_id in (35939)
--And we will have to change every min and movied id

--Or, on the other hand:
UPDATE Projects..MV
	set runtime =
	(
	 case 
	 when Movie_id='10023' then replace(runtime, 'NULL', '108 min')
	 when Movie_id='35939' then replace(runtime, 'NULL', '86 min')
	 when Movie_id='20709' then replace(runtime, 'NULL', '92 min')
	 when Movie_id='20420' then replace(runtime, 'NULL', '89 min')
	 when Movie_id='42419' then replace(runtime, 'NULL', '100 min')
	 when Movie_id='41048' then replace(runtime, 'NULL', '106 min')
	 when Movie_id='30154' then replace(runtime, 'NULL', '96 min')
	 when Movie_id='41592' then replace(runtime, 'NULL', '105 min')
	 when Movie_id='12744' then replace(runtime, 'NULL', '120 min')
	 when Movie_id='13310' then replace(runtime, 'NULL', '107 min')
	 when Movie_id='13316' then replace(runtime, 'NULL', '94 min')
	 when Movie_id='26118' then replace(runtime, 'NULL', '101 min')
	 when Movie_id='29611' then replace(runtime, 'NULL', '100 min')
	 when Movie_id='23963' then replace(runtime, 'NULL', '101 min')
	 when Movie_id='37652' then replace(runtime, 'NULL', '102 min')
	 when Movie_id='48102' then replace(runtime, 'NULL', '98 min')
	 when Movie_id='49518' then replace(runtime, 'NULL', '90 min')
	 when Movie_id='43526' then replace(runtime, 'NULL', '100 min')
	 when Movie_id='38960' then replace(runtime, 'NULL', '95 min')
	 when Movie_id='31370' then replace(runtime, 'NULL', '118 min')
	 when Movie_id='10099' then replace(runtime, 'NULL', '102 min')
	 ELSE runtime
	 END
	 )

--Now let's make a triple join and let's see which genre has the longest runtime and add the total earnings
SELECT genre, SUM(CAST(substring(runtime, 1,3) AS INT)) as "realruntime",  SUM(WORLDWIDE + DOMESTIC) AS "TOTAL"
FROM Projects..GR A, Projects..MV B, Projects..ER C
WHERE A.Movie_id=B.Movie_id AND B.Movie_id=C.Movie_id
GROUP BY GENRE
order by 2 DESC
--As we can see, no matter that drama movies has more runtime, action and adventure, with less time, have earned more money.








