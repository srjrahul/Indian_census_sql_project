-- Viewing dataset
SELECT * FROM Data1
SELECT * FROM Data2

-- Total rows in dataset
SELECT COUNT(*) FROM Data1
SELECT COUNT(*) FROM Data2



-- POPULATION ANALYSIS


-- Total Population of India
SELECT SUM(Data2.Population) AS Total_population FROM Data2

-- Population by state
SELECT Data2.State,SUM(Data2.Population) AS Population FROM Data2
GROUP BY Data2.State

--  5 most populated state
SELECT TOP 5 Data2.State, SUM(Data2.Population) AS Population FROM Data2
GROUP BY Data2.State
ORDER BY Population DESC

-- 5 least populated state
SELECT TOP 5 Data2.State, SUM(Data2.Population) AS Population FROM Data2
GROUP BY Data2.State
ORDER BY Population ASC


-- POPULATION DENSITY


-- Population density of each district
SELECT Data2.District, Data2.State, ROUND(Data2.Population/Data2.Area_km2,2) AS Population_density FROM Data2

-- Population density of each state
SELECT Data2.State, ROUND(SUM(Data2.Population)/SUM(Data2.Area_km2),2) AS population_density FROM Data2
GROUP BY Data2.State

-- top 5 Population density of each state
SELECT TOP 5 Data2.State, ROUND(SUM(Data2.Population)/SUM(Data2.Area_km2),2) AS population_density FROM Data2
GROUP BY Data2.State
ORDER BY population_density DESC

-- Least 5 population density state
SELECT TOP 5 Data2.State, ROUND(SUM(Data2.Population)/SUM(Data2.Area_km2),2) AS population_density FROM Data2
GROUP BY Data2.State
ORDER BY population_density ASC


-- GROWTH RATE


-- Average growth rate of India
SELECT ROUND(AVG(Data1.Growth),2) AS avg_growth FROM Data1

--Average growth rate by State
SELECT Data1.State, ROUND(AVG(Data1.Growth),2) AS avg_growth FROM Data1
GROUP BY Data1.State
ORDER BY avg_growth DESC


-- SEX RATIO


--Avereage sex ratio of india
SELECT ROUND(AVG(Data1.Sex_Ratio),2) AS avg_sexratio FROM Data1

--Avereage sex ratio of india
SELECT Data1.State, ROUND(AVG(Data1.Sex_Ratio),2) AS avg_sexratio FROM Data1
GROUP BY Data1.State
ORDER BY avg_sexratio DESC


-- LITERACY RATE

-- Average literacy rate of India
SELECT ROUND(AVG(Data1.Literacy),2) AS avg_literacy FROM Data1 

--Average literacy rate by state
SELECT Data1.State, ROUND(AVG(Data1.Literacy),2) AS avg_literacy FROM Data1
GROUP BY Data1.State
ORDER BY avg_literacy DESC

--Average literacy rate by state greater than 80 PERCENT
SELECT Data1.State, ROUND(AVG(Data1.Literacy),2) AS avg_literacy FROM Data1
GROUP BY Data1.State
HAVING ROUND(AVG(Data1.Literacy),2)>80
ORDER BY avg_literacy DESC

-- top and bottom 3 states in literacy state

DROP TABLE IF EXISTS #topstates;
CREATE TABLE #topstates
( state nvarchar(255),
  topstate float

  )

INSERT INTO #topstates
SELECT state,round(avg(literacy),0) avg_literacy_ratio FROM Data1 
GROUP BY state ORDER BY avg_literacy_ratio DESC;

SELECT TOP 3 * FROM #topstates ORDER BY #topstates.topstate DESC;

DROP TABLE IF EXISTS #bottomstates;
CREATE TABLE #bottomstates
( state nvarchar(255),
  bottomstate float

  )

INSERT INTO #bottomstates
SELECT state,round(avg(literacy),0) avg_literacy_ratio FROM Data1 
GROUP BY state ORDER BY avg_literacy_ratio DESC;

SELECT TOP 3 * FROM #bottomstates ORDER BY #bottomstates.bottomstate ASC;

--union opertor

SELECT * FROM (
SELECT TOP 3 * FROM #topstates ORDER BY #topstates.topstate DESC) a

union

SELECT * FROM  (
SELECT TOP 3 * FROM #bottomstates ORDER BY #bottomstates.bottomstate ASC) b;

-- states starting with letter a

SELECT DISTINCT Data1.State FROM Data1 WHERE LOWER(state) LIKE 'a%' OR lower(state) LIKE 'b%'

SELECT DISTINCT Data1.State FROM Data1 WHERE LOWER(state) LIKE 'a%' AND lower(state) LIKE '%m'

-- JOINING THE TABLE
SELECT A.District,A.State,A.Sex_Ratio,B.Population FROM Data1 AS A
INNER JOIN Data2 AS B
ON A.District = B.District

-- No. of males and females
-- female/male = sex ratio.............1
-- male+female = population............2
-- so we have two unknowm two equation
-- males = population/(sexratio + 1)   and  female = (population * sexratio)/(sexratio + 1)


SELECT C.District, C.State, ROUND(C.Population/(C.Sex_Ratio +1),0) AS Males, ROUND((C.Population*C.Sex_Ratio)/(C.Sex_Ratio+1),0) AS Female 
FROM (SELECT A.District,A.State,A.Sex_Ratio/1000 AS Sex_Ratio ,B.Population FROM Data1 AS A
	 INNER JOIN Data2 AS B
	 ON A.District = B.District) AS C

--No. of male and female by state
SELECT D.State, SUM(D.Males) AS Total_males, SUM(D.Female) AS Total_females
FROM (SELECT C.District, C.State, ROUND(C.Population/(C.Sex_Ratio +1),0) AS Males, ROUND((C.Population*C.Sex_Ratio)/(C.Sex_Ratio+1),0) AS Female 
		FROM (SELECT A.District,A.State,A.Sex_Ratio/1000 AS Sex_Ratio ,B.Population FROM Data1 AS A
			INNER JOIN Data2 AS B
			ON A.District = B.District) AS C) AS D
GROUP BY D.State;

-- population in previous census

SELECT SUM(M.previous_census_population) AS previous_census_population,SUM(M.current_census_population) AS current_census_population 
FROM (SELECT E.state,SUM(E.previous_census_population) AS previous_census_population,SUM(E.current_census_population) AS current_census_population
	 FROM (SELECT D.district,D.state,ROUND(D.population/(1+d.growth),0) previous_census_population,D.population current_census_population 
		  FROM(SELECT A.district,A.state,A.growth growth,B.population
			  FROM Data1 A INNER JOIN Data2 B 
			  ON A.district=B.district) D) AS E
group by E.state) AS M