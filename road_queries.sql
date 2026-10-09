CREATE TABLE road_accident (
    accident_index VARCHAR(20),
    accident_date VARCHAR(20),
    day_of_week VARCHAR(20),
    junction_control VARCHAR(100),
    junction_detail VARCHAR(100),
    accident_severity VARCHAR(30),
    light_conditions VARCHAR(50),
    local_authority VARCHAR(100),
    carriageway_hazards DOUBLE PRECISION,
    number_of_casualties INTEGER,
    number_of_vehicles INTEGER,
    police_force VARCHAR(100),
    road_surface_conditions VARCHAR(50),
    road_type VARCHAR(100),
    speed_limit INTEGER,
    time TIME,
    urban_or_rural_area VARCHAR(30),
    weather_conditions VARCHAR(100),
    vehicle_type VARCHAR(100)
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';


Select Count(*)
From public.road_accident;

ALTER TABLE public.road_accident
ALTER COLUMN carriageway_hazards TYPE VARCHAR(100)
USING carriageway_hazards::VARCHAR;

SELECT * FROM road_accident;

SELECT COUNT(*)
FROM public.road_accident;

-- find the current year casualities

SELECT SUM(number_of_casualties) AS cy_casualties
FROM public.road_accident
WHERE EXTRACT(
    YEAR FROM TO_DATE(accident_date, 'DD-MM-YYYY')
) = 2022;

-- find the current year accidents

SELECT COUNT(DISTINCT accident_index) AS CY_Accidents
FROM public.road_accident
WHERE EXTRACT (
YEAR FROM TO_DATE(accident_date, 'DD-MM_YYYY'))=2022;

-- Current year Fatal Casualities

SELECT SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM public.road_Accident
WHERE EXTRACT(
YEAR FROM TO_DATE(accident_date,'DD-MM-YYYY')) = 2022 AND accident_severity = 'Fatal';

-- Total Fatal Casualities

SELECT SUM(number_of_casualties) AS Total_CY_Fatal_casualties
FROM public.road_accident
WHERE accident_severity = 'Fatal'

-- Current year Serious Casualties

SELECT SUM(number_of_casualties) AS Cy_Serious_Casualties
FROM public.road_accident
WHERE EXTRACT(
YEAR FROM TO_DATE (accident_date,'DD_MM_YYYY' )) =2022 AND accident_severity ='Serious';

-- Total Serious Casulties

SELECT SUM(number_of_Casualties) AS Total_CY_Serious_Casualties
FROM public.road_accident
WHERE accident_severity = 'Serious';

-- Current year Slight casualties

SELECT SUM(number_of_casualties) AS Cy_slight_Casualties
FROM public.road_accident
WHERE EXTRACT(
YEAR FROM TO_DATE (accident_date,'DD-MM-YYYY' )) =2022 AND accident_severity = 'Slight';

-- Total Slight Casualties

SELECT SUM(number_of_casualties) AS Total_Slight_Casualties
FROM public.road_accident
WHERE accident_severity = 'Slight';

--Find Total Slight Casualties in Percentage 

SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) *100/
(SELECT CAST (SUM(number_of_Casualties) AS DECIMAL(10,2)) 
FROM road_accident) as Pct
FROM road_accident
WHERE accident_severity = 'Slight';

-- Find Casualties by vehicals 

SELECT DISTINCT vehicle_type
FROM road_accident;

SELECT 
	CASE 
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('car','Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc','Motorcycle over 500cc') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t','Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
		ELSE 'other'
	END AS vehicle_group,
	SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
WHERE EXTRACT (YEAR FROM TO_DATE (accident_date,'DD-MM-YYYY'))=2022 
GROUP BY 
	CASE 
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('car','Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc','Motorcycle over 500cc') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t','Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
		ELSE 'other'
	END


-- Find the current year and previous year casualties monthly trend 

SELECT TO_CHAR(TO_DATE(accident_date,'DD-MM-YYYY'),'FMMonth') AS Month_name, SUM(number_of_Casualties) 
FROM road_accident
WHERE EXTRACT (
YEAR FROM TO_DATE(accident_date,'DD-MM-YYYY')) =2022
GROUP BY EXTRACT(MONTH FROM TO_DATE(accident_date, 'DD-MM-YYYY')),
    TO_CHAR(TO_DATE(accident_date, 'DD-MM-YYYY'), 'FMMonth')
ORDER BY EXTRACT (MONTH FROM TO_DATE(accident_date,'DD-MM-YYYY'));

-- Find casualties by roadtype

SELECT road_type,SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
WHERE EXTRACT (YEAR FROM TO_DATE(accident_date,'DD-MM-YYYY')) =2022
GROUP BY road_type;


-- Casualties by urban and rural area 

SELECT urban_or_rural_area,SUM(number_of_casualties) AS Total_Casualties
FROM road_accident
WHERE EXTRACT (YEAR FROM TO_DATE(accident_date,'DD-MM-YYYY')) =2022
GROUP BY urban_or_rural_area;

-- FIND in percentage

SELECT urban_or_rural_area, CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) * 100 /
(SELECT CAST(SUM(number_of_Casualties) AS DECIMAL(10,2)) FROM road_accident WHERE EXTRACT 
(YEAR FROM TO_DATE(accident_date,'DD-MM-YYYY')) =2022) AS PTC
FROM road_accident
WHERE EXTRACT (YEAR FROM TO_DATE(accident_date,'DD-MM-YYYY')) =2022
GROUP BY urban_or_rural_area;

-- Find casualties by light condition 
SELECT DISTINCT light_conditions 
FROM road_accident;

SELECT
    CASE
        WHEN light_conditions IN ('Daylight')
            THEN 'Day'
        WHEN light_conditions IN (
            'Darkness - lighting unknown',
            'Darkness - lights lit',
            'Darkness - lights unlit',
            'Darkness - no lighting'
        )
            THEN 'Darkness'
        ELSE 'Other'
    END AS light_condition,

    CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) * 100 /
    (
        SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2))
        FROM road_accident
        WHERE EXTRACT(
            YEAR FROM TO_DATE(accident_date, 'DD-MM-YYYY')
        ) = 2022
    ) AS percentage

FROM road_accident
WHERE EXTRACT(
    YEAR FROM TO_DATE(accident_date, 'DD-MM-YYYY')
) = 2022

GROUP BY
    CASE
        WHEN light_conditions IN ('Daylight')
            THEN 'Day'
        WHEN light_conditions IN (
            'Darkness - lighting unknown',
            'Darkness - lights lit',
            'Darkness - lights unlit',
            'Darkness - no lighting'
        )
            THEN 'Darkness'
        ELSE 'Other'
    END;

