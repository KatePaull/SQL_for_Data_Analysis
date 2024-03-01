-- Chapter 3: Time Series Analysis

DROP TABLE IF EXISTS rundata;

--Create table
CREATE TABLE rundata (
Date varchar,
Activity varchar,
Steps varchar,
Distance varchar,
Duration interval,
Calories varchar,
Destination varchar
);

--Import data
COPY rundata (date, activity, steps, distance, duration, calories, destination)
--Change ref below to your local path
FROM 'C:/Users/kaitl/OneDrive/DOCUME~1/SQLFOR~1/CHAPTE~2/Data/rundata.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8' QUOTE '"' NULL 'N/A' ESCAPE ''''
;

--View data before getting started
SELECT *
FROM rundata
;

--Cast date, currently a character, to a datetime (timezones involved are PST/PDT with -8 and -7 UTC offsets, respectively)
SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as datetime
FROM rundata
;

--Retrieve individual date/time information from previously-generated datetime variable
SELECT datetime,
extract('month' from Datetime) as Month,
extract('day' from Datetime) as Day,
extract('hour' from Datetime) as Hour,
extract('minute' from Datetime) as Minute
FROM
(
	SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
	FROM rundata
)
;

--Truncate month from Datetime
SELECT datetime,
date_trunc('month', datetime) as truncated_month
FROM
(
	SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
	FROM rundata
)
;

--Retrieve month as a float variable type from Datetime
SELECT datetime,
date_part ('month', datetime) as month_float
FROM
(
	SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
	FROM rundata
)
;

--See how many days/hours the data spans in 2023 as an example of date math
SELECT latest_run - earliest_run as data_day_hr_range
FROM
(
	SELECT min(datetime) as earliest_run,
	max(datetime) as latest_run
	FROM
	(
		SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
		FROM rundata
	)
)
;
--Per above, date range spans 343 days and 6 hours, from January 1 at 7AM to December 12 at 1PM

--An alternative to obtaining difference between dates is using the age function
SELECT age(latest_run, earliest_run) as data_month_range
FROM
(
	SELECT min(datetime) as earliest_run,
	max(datetime) as latest_run
	FROM
	(
		SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
		FROM rundata
	)
)
;

--Age can also be used with date_part to obtain a specific piece of the age; below shows how many months the data spans
SELECT date_part('month', age(latest_run, earliest_run)) as data_month_range
FROM
(
	SELECT min(datetime) as earliest_run,
	max(datetime) as latest_run
	FROM
	(
		SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
		FROM rundata
	)
)
;

--See how many quarters the data spans
SELECT date_part('quarter', age(latest_run, earliest_run)) as data_month_range
FROM
(
	SELECT min(datetime) as earliest_run,
	max(datetime) as latest_run
	FROM
	(
		SELECT date, TO_TIMESTAMP(Date, 'Mon/DD/YYYY, HH12:MI PM') as Datetime
		FROM rundata
	)
)
;