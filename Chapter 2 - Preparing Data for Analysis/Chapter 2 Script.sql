-- Prepare for data import
DROP TABLE IF EXISTS flights;

CREATE TABLE flights
(
year int
,month int
,day int
,dep_time int
,sched_dep_time int
,dep_delay int
,arr_time int
,sched_arr_time int
,arr_delay int
,carrier varchar
,origin varchar
,dest varchar
);

--Import Data 
COPY flights (year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, origin, dest)
-- change below to the location you saved the csv file
FROM 'C:/Users/kaitl/OneDrive/DOCUME~1/SQLFOR~1/CHAPTE~1/Data/flights.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8' NULL 'NA' ESCAPE ''''
;

-- View Data
SELECT * FROM flights;

-- What are the 3 origin airports involved in the NYC flights 2013 dataset, and how many flights departed from each?
SELECT origin, COUNT(*) AS quantity
FROM flights
GROUP BY 1
;

-- View top ten destinations in the dataset
SELECT dest, COUNT(*) AS destquant
FROM flights
GROUP BY 1
ORDER BY destquant DESC
LIMIT 10
;

-- View bottom ten destinations in the dataset
SELECT dest, COUNT (*) AS destquant
FROM flights
GROUP BY 1
ORDER BY destquant ASC
LIMIT 10
;

-- View number of departure delay trends using inequalities and CASE statements
SELECT
	CASE WHEN dep_delay < 1 THEN 'left early or on-time'
	WHEN dep_delay BETWEEN 0 AND 59 THEN 'under an hour late'
	WHEN dep_delay BETWEEN 60 AND 119 THEN '1-2 hours late'
	WHEN dep_delay > 119 THEN '2+ hours late' END AS amount_delay
,COUNT (origin) AS flight_count
FROM flights
GROUP BY 1
;

-- Check for duplicate records by grouping on all variables and counting records that match
SELECT year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, origin, dest, count(*) as records
FROM flights
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
HAVING COUNT(*) > 1
;
-- No duplicates noted

--Type conversions - change year and from integer to string as example of how to use CAST function
SELECT flights.year, CAST (year AS varchar)
FROM flights
;

--Similar conversion with different syntax
SELECT flights.year, year::varchar
FROM flights
;

--Cast year, month, day as DATE
SELECT year, month, day, (year || ',' || month || ',' || day)::date AS departure_date
FROM flights
;

--Left join airport name from additional dataset
DROP TABLE IF EXISTS airports;

CREATE TABLE airports
(
faa varchar
,airport_name varchar
);

COPY airports (faa, airport_name)
-- change below to the location you saved the csv file
FROM 'C:\Users\kaitl\OneDrive\Documents\SQL for Data Analysis\Chapter 2 - Preparing Data for Analysis\Data\airports.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8' NULL 'NA'
;

--Left join shows that there are four destinations in the flights dataset that don't exist in the airports dataset
SELECT DISTINCT a.dest
FROM flights a
LEFT JOIN airports b ON a.dest = b.faa
WHERE b.airport_name IS null
;

--Replace null with "Elsewhere" for instances where airport name does not exist
SELECT DISTINCT dest
,CASE WHEN airport_name IS null THEN 'Elsewhere' ELSE airport_name END AS airport_name_new
FROM flights a
LEFT JOIN airports b ON a.dest = b.faa
;

--Create a pivot table of departures by origin airport
SELECT origin
,count(dep_time) as departure_count
FROM flights
GROUP BY 1
;


--Create a pivot table of departures with delays over one hour, by origin airport
SELECT origin
,COUNT(dep_delay) AS departure_count
FROM flights
WHERE dep_delay > 59
GROUP BY 1
ORDER BY departure_count DESC
;

--Create a pivot table of departures with delays over one hour, by origin airport; add additional dimension of month to the pivot table
SELECT origin, month
,COUNT(dep_delay) AS departure_count
FROM flights
WHERE dep_delay > 59
GROUP BY origin, month
ORDER BY origin, month
;

--Create a pivot table of arrivals with delays over one hour, by destination airport
SELECT dest
,COUNT(arr_delay) as arrival_count
FROM flights
WHERE arr_delay > 59
GROUP BY 1
ORDER BY arrival_count DESC
;

--Investigate departure delays by month to see if there are seasonal fluctuations in delays
SELECT month
,COUNT(dep_delay) as departure_count
FROM flights
WHERE arr_delay > 59
GROUP BY 1
ORDER BY month ASC
;

--Investigate flight cancellations by month to see if there are seasonal fluctuations in cancellations
SELECT month
,COUNT(sched_dep_time) as cancellation_count
FROM flights
WHERE dep_time is null
GROUP BY 1
ORDER BY month ASC
;

--Create pivot table showing count of early flights, on-time flights, late flights, and canceled flights by origin airport
SELECT origin
	,CASE WHEN dep_delay < 0 THEN 'left early'
	WHEN dep_delay = 0 THEN 'left on time'
	WHEN dep_delay > 0 THEN 'left late' 
	WHEN dep_delay is null THEN 'flight canceled' END AS amount_delay
,COUNT (origin) AS flight_count
FROM flights
GROUP BY origin, amount_delay
ORDER BY origin
;