Use airtraffic;
-- Question 1
/* 1.1 How many flights were there in 2018 and 2019 separately? 
		>> Step 1. Get data from table flights 
			2. Using Year function to separate data.
			3. count and group by year.*/
SELECT year(flightdate) year_flight, COUNT(*) no_of_flights
FROM flights
GROUP BY year_flight;

/* 1.2 In total, how many flights were cancelled or departed late over both years? 
		>> Step 1. Get data from table flights 
			2. count number of flights that has Cancelled flag = 1 (True) and DepDelay more than 0*/
SELECT COUNT(*) flights_cancelled_or_departed_late
FROM flights
WHERE Cancelled = 1 or DepDelay > 0;

/* 1.3 Show the number of flights that were cancelled broken down by the reason for cancellation.
	>> Step 1. Get cancellation reason data from table flights 
		2. count number of cancellation flights 
		3. group by cancellation reason*/
SELECT  cancellationreason, COUNT(*) no_cancelled 
FROM flights 
WHERE Cancelled = 1
GROUP BY cancellationreason;

/* 1.4 For each month in 2019, report both the total number of flights and percentage of flights cancelled.  
		>> Step 1. Get data from table flights
			2. use month function to separated month 
			3. calculation cancelled flight percentage.
			4. filter by where year function is 2019, 
			5. group by month*/
SELECT month(flightdate) month_no 
		,  COUNT(*) flights  
        , SUM(cancelled) cancelled
		, SUM(cancelled) /COUNT(*) *100 cancelled_percent -- Able to use AVG instead sum/count
FROM flights 
WHERE year(flightdate) = 2019
GROUP BY month(flightdate) 
ORDER BY month_no;

/* Based on your results, what might you say about the cyclic nature of airline revenue? 
Answer >> In every months, the total flights almost the same. 
	The first half or year, Jan - Jun, the cancelled filght more than second half,
	and the last quarter cancelled flights were reduce. Therefore, the airline revenue should be uptrend from Jan to Dec
    , and when Jan the trend will low. The most revenue will gain in Q4. 
	If breakdown by cancellation reason found that mostly cancelled by Carrier and Weather*/
    
/* Question 2
	2.1 Create two new tables, one for each year (2018 and 2019) showing the total miles traveled 
    and number of flights broken down by airline. 
		>> Step 1. Create new table and aggregate sum distance 
			2. count for total flights
			3. filter by year 2018
			4. group by airline*/
    DROP TABLE IF EXISTS flights_2018;
    CREATE TABLE flights_2018 (
		SELECT airlinename, 
			sum(Distance) total_miles, 
			count(*) no_of_flights 
		FROM flights
		WHERE year(FlightDate) = 2018
		GROUP BY airlinename
		ORDER BY airlinename);
        
	SELECT * FROM flights_2018;
    
	/* >> Step 1. Create new table and aggregate sum distance 
			2. count for total flights
			3. filter by year 2019
			4. group by airline*/
    DROP TABLE IF EXISTS flights_2019;
	CREATE TABLE flights_2019 (
		SELECT airlinename, 
			sum(Distance) total_miles, 
            count(*) no_of_flights 
		FROM flights
		WHERE year(FlightDate) = 2019
		GROUP BY airlinename
		ORDER BY airlinename);
        
	SELECT * FROM flights_2019;
        
/*  2.2 Using your new tables, find the year-over-year percent change in total flights and miles traveled for each airline.
		>> Step 1. Inner join 2 new table of 2018 and 2019 from 2.1 
			2. Calculate YoY change by find different between 2018 and 2019 and divided by 2018 then multiply 100 
				for percentage for number of flight and total miles*/
SELECT flights_2019.airlinename, 
	round((flights_2019.no_of_flights - flights_2018.no_of_flights) / flights_2018.no_of_flights * 100 , 2) AS "YoY_change%_no_of_flights" ,
	round((flights_2019.total_miles - flights_2018.total_miles) / flights_2018.total_miles * 100, 2) AS "YoY_change%_total_miles" 
FROM flights_2019 INNER JOIN flights_2018 
	ON flights_2019.airlinename = flights_2018.airlinename;
    
/* What investment guidance would you give to the fund managers based on your results? 
	Answer : Delta Air Lines Inc. is the best airline to selected. According to the result growing from 2018 to 2019 
    of number of flights 4.5%  and total miles 5.56%. Where as American Airlines Inc. a bit lower percentage 
    and Southwest Airlines Co. was very low percentage.
*/

 /* Question 3

	3.1 What are the names of the 10 most popular destination airports overall? 
		For this question, generate a SQL query that first joins flights and airports then does the necessary aggregation.
		>> Step 1. Count flight by join table flights and airports 
			2. group by then order by descending and limit data 10 records.
        >> Runtime : 10 row(s) returned	70.015 sec / 0.000 sec*/
    SELECT a.AirportName, Count(*) no_flights 
    FROM flights f INNER JOIN airports a ON f.DestAirportID = a.AirportID
    GROUP BY a.AirportName
    ORDER  BY no_flights DESC
    LIMIT 10;

 /* 3.2 Answer the same question but using a subquery to aggregate & limit the flight data before your join 
		with the airport information, hence optimizing your query runtime. 
		>> Step 1. get data from table airports
			2. Join with top 10 number of flight for destination airports
        >> Runtime : 10 row(s) returned	9.125 sec / 0.000 sec*/
	SELECT AirportName, no_flights
    FROM airports INNER JOIN 
		( SELECT DestAirportID, count(*) no_flights
		FROM flights f
		GROUP BY DestAirportID
		ORDER  BY no_flights DESC
		LIMIT 10) top10
        ON airports.AirportID = top10.DestAirportID
	ORDER BY no_flights DESC;
    
    /* which is faster and why?
		Answer : The subqueries is faster because did the aggregation first and then join 10 records with the airports table.
        But the first query which using join 2 tables has to aggregate from total of records in flights table (6,521,361 records) */
        
	/* Question 4
		4.1 Determine the number of unique aircrafts (identify by Tail number) each airline operated in total over 2018-2019   
			>> Step 1. Get data from table flights 
				2. count distinct Tail number and group by airline*/
        
	SELECT  airlinename, count(DISTINCT Tail_Number) no_aircrafts
    FROM flights
    GROUP BY airlinename;
    
    /* 4.2 What is the average distance traveled per aircraft for each of the three airlines? 
			>> Step 1. Get data from table flights 
				2. find total distance by sum then divided by number of aircrafts 
				3. group by airline*/
	SELECT airlinename, sum(Distance) / count(DISTINCT Tail_Number) Avg_Distance_per_airline
    FROM flights
    GROUP BY flights.airlinename;
    
/*  Compare the three airlines with respect to your findings: 
	how do these results impact your estimates of each airline's finances?
    Answer : Southwest Airlines Co.(WN) is the most distance over others but the number of aircraft is the least. 
    So, WN might invested for aircraft less than others but able to operate more than others. 
    Therefore, WN should get highest revenue but the maintenance cost should be highest. In addition, from result of 2.2 
    it can be concluded the YoY_change%_total_flights only a bit increase and YoY_change%_total_miles of WN from 2018 to 2019 was negative.
    For American Airlines Inc.(AA) and Delta Air Lines Inc.(DL) the number of aircrafts and average distance per aircraft are close to each other.
    AA likely have a strong financial position due to number of aircrafts more than others.
*/
/* Question 5:
	5.1 Next, we will look into on-time performance more granularly in relation to the time of departure. 
    Find the average departure delay for each time-of-day across the whole data set. Can you explain the pattern you see? 
		>> Step 1. Get data from table flights 
			2. inner join with subquery which seaparate time of day by CASE with Hour function
			3. use function avg to average departure delay 
			4. group by time of day to separate time of day data. */
    
    SELECT  time_of_day, avg(DepDelay)
    FROM flights INNER JOIN 
    (SELECT id,     CASE
		WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
		WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
		WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
		ELSE "4-night"
		END AS "time_of_day"  
        FROM flights 
        ) AS s_time
	ON flights.id = s_time.id
    GROUP BY time_of_day 
    ORDER BY time_of_day;
    
    /* Answer : Departure at night time is more on time, next is morning, then afternoon more delay, 
		and the most departure delay is evening time */
    
    /* 5.2 Now, find the average departure delay for each airport and time-of-day combination.
			>> Step 1. Use query from 5.1 
				2. Inner join with airports to get Airportname 
				3. group by airport's name and time of day*/
     SELECT AirportName, time_of_day, avg(DepDelay)
    FROM flights INNER JOIN 
    (SELECT id,     CASE
		WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
		WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
		WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
		ELSE "4-night"
		END AS "time_of_day"  
        FROM flights 
        ) AS s_time 	ON flights.id = s_time.id
    INNER JOIN airports ON airports.AirportId = flights.OriginAirportID
    GROUP BY AirportName, time_of_day 
    ORDER BY AirportName, time_of_day;
    
    /* 5.3 Next, limit your average departure delay analysis to morning delays and airports with at least 10,000 flights. 
		>> Step 1. Get data from table flights
			2. use avg departure delays and count for number of delayed flights
			3. then use where to filter morning flights.
			4. Finally, use having for get only airport which has at least 10,000 delayed flights*/
   SELECT AirportName,  Avg(DepDelay) AS avg_of_delay_morning ,  count(*) AS no_of_delay_morning
    FROM flights 
    INNER JOIN airports ON airports.AirportId = flights.OriginAirportID
    WHERE   HOUR(CRSDepTime) BETWEEN 7 AND 11  	-- morning only	
    GROUP BY AirportName 
    HAVING no_of_delay_morning >= 10000; 					-- airports with at least 10,000 flights
    
/* 5.4 By extending the query from the previous question, name the top-10 airports (with >10000 flights) 
with the highest average morning delay. In what cities are these airports located? 
		>> Step 1. Use 5.3 query and add column airports.city, also add this column to group by 
			2. Order by average of delay in the morning descending.
			3. limit 10 for top 10*/
	SELECT AirportName, airports.City, avg(DepDelay) avg_of_delay_morning, count(*) AS no_of_delay_morning
    FROM flights 
    INNER JOIN airports ON airports.AirportId = flights.OriginAirportID
    WHERE   HOUR(CRSDepTime) BETWEEN 7 AND 11 		-- morning only	
    GROUP BY AirportName, airports.City 
    HAVING no_of_delay_morning >= 10000
    ORDER BY avg_of_delay_morning DESC
    LIMIT 10; 
    
/* Cities are San Francisco, CA
Los Angeles, CA
Dallas/Fort Worth, TX
Chicago, IL
Seattle, WA
Denver, CO
Dallas, TX
Houston, TX
San Diego, CA */

