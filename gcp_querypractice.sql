Data1: bigquery-public-data.austin_bikeshare.bikeshare_stations
Data2: bigquery-public-data.austin_bikeshare.bikeshare_trips

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%% Data-1 Sample Records %%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Select * From bigquery-public-data.austin_bikeshare.bikeshare_stations Limit 500;

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%% Data-1 Key Statistics %%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Select
   Count(*) as records
  ,Count(Distinct station_id) as stations
From
  bigquery-public-data.austin_bikeshare.bikeshare_stations
;
-- records	stations
-- 102	102

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%% Data-2 Sample Records %%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Select * From bigquery-public-data.austin_bikeshare.bikeshare_trips Limit 5000

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%% Data-2 Key Statistics %%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Select
   Count(*) as records
  ,Count(Distinct trip_id) as trips
  ,Count(Distinct start_station_id) as start_stations
  ,Count(Distinct end_station_id) as end_stations
From
  bigquery-public-data.austin_bikeshare.bikeshare_trips
;
-- records	trips	start_stations	end_stations
-- 2112263	2112263	106	107

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- (I)
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%% Unique Number of Trips by Station Start %%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Select
   start_station_id
  ,count(distinct trip_id) as trips
From
  bigquery-public-data.austin_bikeshare.bikeshare_trips
Group BY
  start_station_id
Order By
  trips DESC
;

-- (II)
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%% Identifying Stations based on station_id %%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- ~~~~~~~ Method-A ~~~~~~
Select
   A.*
  ,B.name as Station_Name
  ,B.address as Station_Address
  ,B.status as Station_Status
  ,B.property_type as Station_Property_Type
From
  (
    Select
       start_station_id
      ,count(distinct trip_id) as trips
    From
      bigquery-public-data.austin_bikeshare.bikeshare_trips
    Group BY
      start_station_id
    Order By
      trips DESC
  ) as A
Left Join
  bigquery-public-data.austin_bikeshare.bikeshare_stations as B
ON
  A.start_station_id = B.station_id
;

-- Question1 : Will you get the result in Order as in Subquery?
-- Question2 : Why did we join the data after aggregation(which is in Subquery)?


-- ~~~~~~~ Method-B ~~~~~~
With Trips As
(
  Select
     start_station_id
    ,count(distinct trip_id) as trips
  From
    bigquery-public-data.austin_bikeshare.bikeshare_trips
  Group BY
    start_station_id
  Order By
    trips DESC
),
Stations As
(
  Select
     station_id
    ,name
    ,address
    ,status
    ,property_type
  From
    bigquery-public-data.austin_bikeshare.bikeshare_stations
)
Select
   A.*
  ,B.name as Station_Name
  ,B.address as Station_Address
  ,B.status as Station_Status
  ,B.property_type as Station_Property_Type
From
  Trips as A
Left Join
  Stations as B
ON
  A.start_station_id = B.station_id
;

-- Question1 : What is the difference?


-- (III)
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%% Identifying Stations with highest number of trips -- TOP5 Stations Only %%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

With Trips As
(
  Select
     start_station_id
    ,count(distinct trip_id) as trips
  From
    bigquery-public-data.austin_bikeshare.bikeshare_trips
  Group BY
    start_station_id
),
Stations As
(
  Select
     station_id
    ,name
    ,address
    ,status
    ,property_type
  From
    bigquery-public-data.austin_bikeshare.bikeshare_stations
)
Select
   A.*
  ,B.name as Station_Name
  ,B.address as Station_Address
  ,B.status as Station_Status
  ,B.property_type as Station_Property_Type
From
  Trips as A
Left Join
  Stations as B
ON
  A.start_station_id = B.station_id
Order By trips
Limit 5
;

-- start_station_id	trips	Station_Name	Station_Address	Station_Status	Station_Property_Type
-- 1001	12	OFFICE/Main/Shop/Repair	1000 Brazos	closed
-- 7637	182
-- 1008	303	Nueces @ 3rd	311 Nueces	closed
-- 3456	348
-- 2500	440	Republic Square	425 W 4th Street	closed

-- Question1 : What will happen if you remove Order By?




-- (IV)
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--  Identifying When was the first & last trip made from Stations .
--  For (i) Station_id=2500 which has 440 Trips
--  For (ii) Station_id = 1008 which has 303 trips
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

With Sequence As
(
Select
   *
   ,Row_Number() Over (Partition By start_station_id Order By start_time ASC) as trip_sequence_asc
   ,Row_Number() Over (Partition By start_station_id Order By start_time DESC) as trip_sequence_desc
From
  bigquery-public-data.austin_bikeshare.bikeshare_trips
Where
  start_station_id in (2500,1008)
)
Select
   *
  ,Case
    When trip_sequence_asc = 1 Then "First Trip"
    When trip_sequence_desc = 1 Then "Last Trip"
   End as Trip_Category
From
  Sequence
Where
  trip_sequence_asc = 1
  OR
  trip_sequence_desc = 1
;
