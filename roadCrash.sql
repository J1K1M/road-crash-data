--Looking at the crash data from 2012
SELECT *
FROMcrash_analysis_system
WHERE crashYear >= 2012

--Dealing with NULL values

SELECT DISTINCT holiday
FROM Crash_Analysis_System

UPDATE Crash_Analysis_System
SET holiday = ISNULL(holiday, '') FROM Crash_Analysis_System

--Using [crashLocation1] and [crashLocation2] to populate [areaUnitID]

SELECT c1.areaUnitID, c1.crashLocation1, c1.crashLocation2, c2.areaUnitID, c2.crashLocation1, c2.crashLocation2, ISNULL(c2.areaUnitID, c1.areaUnitID)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.crashLocation1 = c2.crashLocation1 and c1.crashLocation2 = c2.crashLocation2 and c1.OBJECTID <> c2.OBJECTID
WHERE c1.areaUnitID IS NOT NULL and c2.areaUnitID IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012

UPDATE c2
SET areaUnitID = ISNULL(c2.areaUnitID, c1.areaUnitID)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.crashLocation1 = c2.crashLocation1 and c1.crashLocation2 = c2.crashLocation2 and c1.OBJECTID <> c2.OBJECTID
WHERE c1.areaUnitID IS NOT NULL and c2.areaUnitID IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012

--Using [areaUnitID] to see the value for [region] and replacing the NULL values to the corresponding [region] with matching [areaUnitID]

SELECT *, ISNULL(c2.region, c1.region)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.areaUnitID = c2.areaUnitID and c1.OBJECTID <> c2.OBJECTID
WHERE c1.region IS NOT NULL and c2.region IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012

UPDATE c2
SET region = ISNULL(c2.region, c1.region)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.areaUnitID = c2.areaUnitID and c1.OBJECTID <> c2.OBJECTID
WHERE c1.region IS NOT NULL and c2.region IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012


--Populating [tlaName]

SELECT c1.areaUnitID, c1.region, c1.tlaName, c2.areaUnitID, c2.region, c2.tlaName, ISNULL(c2.tlaName,c1.tlaName)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.areaUnitID = c2.areaUnitID and c1.OBJECTID <> c2.OBJECTID
WHERE c1.tlaName IS NOT NULL and c2.tlaName IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012

UPDATE c2
SET tlaName = ISNULL(c2.tlaName,c1.tlaName)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.areaUnitID = c2.areaUnitID and c1.OBJECTID <> c2.OBJECTID
WHERE c1.tlaName IS NOT NULL and c2.tlaName IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012



UPDATE Crash_Analysis_System
SET  crashLocation2 = ISNULL(crashLocation2, '') FROM Crash_Analysis_System

UPDATE Crash_Analysis_System
SET  crashSHDescription = ISNULL(crashSHDescription, 'Unknown') FROM Crash_Analysis_System




UPDATE c2
SET speedlimit = ISNULL(c2.speedLimit, c1.speedlimit)
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.crashLocation1 = c2.crashLocation1 and c1.crashLocation2 = c2.crashLocation2 and c1.OBJECTID <> c2.OBJECTID and c1.areaUnitID = c2.areaUnitID
WHERE c1.speedlimit IS NOT NULL and c2.speedlimit IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012

SELECT c1.areaUnitID, c1.crashLocation1, c1.crashLocation2, c1.speedLimit, c2.areaUnitID, c2.crashLocation1, c2.crashLocation2, c2.speedLimit, c1.region, c2.region
FROM Crash_Analysis_System c1
JOIN Crash_Analysis_System c2 ON c1.crashLocation1 = c2.crashLocation1 and c1.OBJECTID <> c2.OBJECTID and c1.areaUnitID = c2.areaUnitID
WHERE c1.speedlimit IS NOT NULL and c2.speedlimit IS NULL and c1.crashYear >= 2012 and c2.crashYear >= 2012 

--
SELECT *
FROM Crash_Analysis_System
WHERE crashYear >= 2012
--
--Number of crash based on crash severity
SELECT crashSeverity, COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
group by crashSeverity
order by  crashSeverity DESC

--Since 2012, the number of crashes based on the severity of the crash and it's %
SELECT crashSeverity, count(*) as 'number_of_Crashes', ROUND( count(*)*100 / (SELECT cast(COUNT(*) as float) as 'Total' FROM Crash_Analysis_System WHERE crashYear >= 2012),2) as 'severity_percent'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
GROUP BY crashSeverity
ORDER BY 'number_of_Crashes' DESC

--Added a [speedCategory] column to group speed limits in the data
ALTER TABLE Crash_Analysis_System
ADD speedCategory varchar(50);

UPDATE Crash_Analysis_System
SET speedCategory = CASE
	WHEN speedLimit BETWEEN 0 AND 30 THEN 'Slow'
	WHEN speedLimit BETWEEN 40 AND 50 THEN 'Normal'
	WHEN speedLimit BETWEEN 60 AND 80 THEN 'Fast'
	WHEN speedLimit >=90 THEN 'Very Fast'
	END 
FROM Crash_Analysis_System
WHERE crashyear >= 2012

SELECT speedCategory, COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
group by speedCategory


--Number of crash based on speed category divided up by the severity, and the percentage of severity over the total number of crashes in respect to the speed category.
SELECT c1.speedCategory, c1.crashSeverity, COUNT(*) as 'number_of_crashes', ROUND( count(*)*100/ CAST( (SELECT count(*) FROM Crash_Analysis_System c2 WHERE c1.speedCategory = c2.speedCategory GROUP BY speedCategory) as FLOAT), 2) as 'percent'
FROM Crash_Analysis_System c1
WHERE crashYear >= 2012
group by speedCategory, crashSeverity
order by  speedCategory, 'percent' DESC

--Per region
SELECT region, COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
GROUP BY region
ORDER BY COUNT(*) DESC





DELETE FROM Crash_Analysis_System
WHERE speedCategory IS NULL

DELETE FROM Crash_Analysis_System
WHERE areaUnitID IS NULL

UPDATE Crash_Analysis_System
SET fatalCount = ISNULL(fatalCount, 0) FROM Crash_Analysis_System WHERE crashYear>=2012

UPDATE Crash_Analysis_System
SET minorInjuryCount = ISNULL(minorInjuryCount, 0) FROM Crash_Analysis_System WHERE crashYear>=2012

UPDATE Crash_Analysis_System
SET seriousInjuryCount = ISNULL(seriousInjuryCount, 0) FROM Crash_Analysis_System WHERE crashYear>=2012

--Top 10 crash location with the most crashes
SELECT top 10 crashLocation1, count(*) as 'num'
FROM Crash_Analysis_System
WHERE crashyear >= 2012
group by crashLocation1
ORDER BY 'num' DESC

--Total number of crashes based on the weather
SELECT weather, count(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
GROUP BY weather

--Number of crashes depending on the weather divided by crash severity, and percentage of crashes over the total crashes per weather condition
SELECT c1.weather, c1.crashSeverity, count(*) as 'crashes_per_severity', (SELECT count(*) FROM Crash_Analysis_System c2 WHERE c1.weather = c2.weather GROUP BY weather) as 'total_crashes_per_weather' , 
ROUND( count(*)*100/ CAST( (SELECT count(*) FROM Crash_Analysis_System c2 WHERE c1.weather = c2.weather GROUP BY weather) as FLOAT), 2) as 'percent_of_severity'
FROM Crash_Analysis_System c1
WHERE crashYear >= 2012 and weather != 'Null'
GROUP BY weather, crashSeverity
ORDER BY weather, 'percent_of_severity' DESC


--Number of crashes during holiday periods
SELECT holiday, count(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012 and holiday <> ''
GROUP BY holiday


--Crashes per year
SELECT crashYear, COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
GROUP BY crashYear
ORDER BY crashYear


--Number of fatal casualties per year
SELECT crashYear, SUM(fatalCount) as 'number_of_casualties'
FROM Crash_Analysis_System
WHERE crashYear >= 2012 
GROUP BY crashYear
ORDER BY crashYear 

SELECT crashSeverity,crashYear, COUNT(*) as 'number_of_casualties'
FROM Crash_Analysis_System
WHERE crashYear >= 2012 and crashSeverity = 'Fatal Crash'
GROUP BY crashSeverity, crashYear
ORDER BY crashYear

SELECT light,  COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012
GROUP BY light
ORDER BY 'number_of_crashes'

SELECT c1.light, c1.crashSeverity, count(*) as 'crashes_per_severity', (SELECT count(*) FROM Crash_Analysis_System c2 WHERE c1.light = c2.light GROUP BY light) as 'total_crashes_per_light' , 
ROUND( count(*)*100/ CAST( (SELECT count(*) FROM Crash_Analysis_System c2 WHERE c1.light = c2.light GROUP BY light) as FLOAT), 2) as 'percent_of_severity'
FROM Crash_Analysis_System c1
WHERE crashYear >= 2012 and light != 'Unknown'
GROUP BY light, crashSeverity
ORDER BY light, 'percent_of_severity' DESC


SELECT crashSeverity, light, COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012 and weather IS NOT NULL
GROUP BY crashSeverity, light
ORDER BY crashSeverity DESC, 'number_of_crashes' DESC

SELECT weather, COUNT(*) as 'number_of_crashes'
FROM Crash_Analysis_System
WHERE crashYear >= 2012 and weather IS NOT NULL
GROUP BY weather
ORDER BY 'number_of_crashes' DESC



