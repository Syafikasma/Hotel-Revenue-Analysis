/* Hotel Revenue Analysis
Question:
	1. Does hotel revenue increase every year?
	2. Does the hotel parking area need to be expanded?
	3. What trends can we see in the data? (Exploratory analysis)
*/

/* Question 1: Does hotel revenue increase every year?
 Answer: The revenue in 2019 is increasing by 4 million from 2018 and decreasing by 4 million in 2020, but note that the data in 2018 and
			2020 is incomplete (missing some months' records)*/
WITH 
hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

-- Query for revenue analysis for each hotel type, where only Check-Out reservation counted as revenue
SELECT 
	hotels.arrival_date_year AS Year, 
	hotels.hotel AS Hotel_Types,
	ROUND(SUM((hotels.stays_in_week_nights + hotels.stays_in_weekend_nights) * hotels.adr * (1 - market.Discount)), 2) AS Revenue
FROM 
	hotels
LEFT JOIN 
	dbo.market_segment$ AS market
ON 
	hotels.market_segment = market.market_segment
WHERE 
	hotels.reservation_status = 'Check-Out' OR
	hotels.deposit_type = 'Nonrefund'
GROUP BY 
	hotels.arrival_date_year, hotels.hotel
ORDER BY 
	hotels.arrival_date_year, hotels.hotel;


/* Question 2:Does the hotel parking area need to be expanded?
 Answer: From the Parking_Percentage column, it can be concluded that the Hotel does not need to expand its parking area since the
   total number of parking spaces required for cars is much less than the number of (success) reservations made per day, especially 
   for City Hotel. Although the analysis requires further complementary data such as the total area of the parking lot or the total capacity of cars that 
   can be accommodated to make a better decision.*/

WITH hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$']), 
T1 AS(
SELECT 
	hotels.arrival_date_year AS Year, 
	hotels.arrival_date_month AS Month, 
	hotels.hotel AS Hotel,
	COUNT(hotels.reservation_status) AS Total_Reservation,
	SUM(hotels.required_car_parking_spaces) AS Required_Parking_Spaces,
	ROUND(SUM(hotels.stays_in_week_nights + hotels.stays_in_weekend_nights) / COUNT(reservation_status),0) AS AVG_Stay_Per_Reservation,
	CONCAT(ROUND(SUM(required_car_parking_spaces) / COUNT(reservation_status) * 100, 2), '%') AS Parking_Percentage
FROM 
	hotels
WHERE  
	hotels.reservation_status = 'Check-Out'
GROUP BY 
	hotels.arrival_date_year, hotels.arrival_date_month, hotels.hotel)

SELECT *
FROM 
	T1
ORDER BY 
	Hotel ASC, Year ASC, Parking_Percentage DESC;


/* Question 3: What trends can we see in the data? (Exploratory analysis)
 Answer: The exploratory analysis focuses on customers' behavior which possibly leads to cancellation or customers not show on the 
 reserved day by considering the lead time, deposit type, and customer's market segmentation. The analysis also looks for the most 
 preferred types of rooms that customers choose on the reservation.. 
		
  1. Total Number of Each Reservation Status
     Explanation: It shows that canceled and no-show reservation have been a problem for hotel management in every year, especially in 2019 and 2020 
	 based on the recorded reservations. */
WITH 
	hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year AS Year,
	reservation_status AS Reservation_Status,
	COUNT(*) AS Total_Reservation_Status
FROM 
	hotels
GROUP BY 
	arrival_date_year, reservation_status
ORDER BY 
	arrival_date_year ASC;

	/*
	2. Total Number of Each Reservation Status based on Market Segmentation
     Explanation: The analysis indicates that a significant proportion of canceled, check-out, and no-show reservations originate from bookings
	 made through online TA (travel agencies), offline TA/TO (travel agents/tour operators), and direct reservations. */

WITH 
	hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year AS Year,
	reservation_status AS Reservation_Status, 
	market_segment AS Market_Segmentation,
	COUNT(*) Total_Reservation
FROM 
	hotels
GROUP BY 
	arrival_date_year, 
	reservation_status, 
	market_segment
ORDER BY
	Reservation_Status, 
	Year, 
	Total_Reservation DESC;


/*
	3. Average of Lead Time for Each Reservation Status 
     Explanation: It shows that the longer the leading time or the number days between booking and arrival date leads to canceled reservations. */

WITH 
	hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year AS Year,
	reservation_status AS Reservation_Status, 
	ROUND(AVG(lead_time),0) AS AVG_Lead_Time
FROM 
	hotels
GROUP BY 
	arrival_date_year, 
	reservation_status;

/*
	4. Types of Deposit Type of Each Reservation Status 
     Explanation:This shows that the no-deposit type is one of the most frequently chosen deposit types for each reservation status, 
	 but this can be brought disadvantages to the hotel management if the reservation is canceled or the visitor does not show up, 
	 since the room that has been booked cannot be handed over to another customer. */

WITH 
	hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year AS Year,
	reservation_status AS Status, 
	deposit_type AS Deposit_Type,
	COUNT(*) AS Total_Reservation
FROM 
	hotels
GROUP BY 
	arrival_date_year,
	reservation_status,
	Deposit_Type
ORDER BY 
	reservation_status ASC,
	Year ASC,
	Total_Reservation DESC;

/*
	5. Cancelled Reservation's Customer Type Ratio
     Explanation: This reveals the contract customer type with the highest likelihood of canceling reservations in each reported year. */
WITH 
	hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year AS Year, 
	customer_type AS Customer_Type,
	COUNT(*) Total_Reservation
FROM 
	hotels
WHERE 
	reservation_status = 'Canceled'
GROUP BY 
	arrival_date_year, 
	customer_type
ORDER BY
	Year ASC;

/*
	6. Preferred Room Type
     Explanation: This shows that room type A has the highest demand in each reported year. */
WITH 
	hotels AS (
	SELECT * FROM dbo.['2018$']
	UNION
	SELECT * FROM dbo.['2019$']
	UNION
	SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year AS Year, 
	reserved_room_type AS Room_Type,
	COUNT(*) Total_Reservation
FROM 
	hotels
GROUP BY 
	arrival_date_year,
	reserved_room_type
ORDER BY
	Year ASC,
	Room_Type;
	
	