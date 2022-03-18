/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM Portfolio_COVID..['owid-covid-data']
order by 3,4

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
from Portfolio_COVID..['owid-covid-data']
order by 1,2  ASC 

-- Compare total deaths vs total cases to give %, gives the likelihood of u dying incase u get covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_COVID..['owid-covid-data'] 
where location = 'India' AND total_cases is NOT NULL
order by date DESC 

-- What were the no of cases in other countries when India announced its 1st lockdown on 25th march
SELECT location, total_cases, date
from Portfolio_COVID..['owid-covid-data']
WHERE date = '2020-03-25' AND continent is not null
order by 2 DESC 

-- looking at total cases vs population. Shows what % got covid
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,5) as InfectedPopulation_Percentage
from Portfolio_COVID..['owid-covid-data']
where location = 'India'
order by 1,2

-- looking at countries with highest infection rate
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPopulation_Percentage
from Portfolio_COVID..['owid-covid-data'] 
GROUP BY location, population
Order by 4 DESC

-- looking at how many people died
SELECT location, SUM(new_cases) as "total cases", SUM(CAST(new_deaths as int)) as "total deaths", SUM(cast(
new_deaths as int))/sum(new_cases)*100 as totaldeathPercentage 
FROM Portfolio_COVID..['owid-covid-data']
WHERE continent is not null
Group by location
order by 4 DESC

-- India's statistics (death_rate, Infected_rate, vaccinated_population, test_positivity percentage)
select d.location, d.date, d.population, d.total_deaths, d.total_cases, v.total_vaccinations,
ROUND((convert(int,d.total_deaths)/d.total_cases),5) as DeathPercentage,
ROUND((d.total_cases/d.population)*100,5) as InfectedPercentage,
ROUND((v.total_vaccinations/d.population)*100,5) as VaccinatedPercentage
FROM Portfolio_COVID..['covid vaccination'] v
JOIN Portfolio_COVID..['owid-covid-data'] d
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location = 'India'
order by 2


-- Using CTE on previous query
With IndiaStat (location, date, population, total_deaths, total_cases, total_vaccinations, DeathPercentage, InfectedPercentage, VaccinatedPercentage) 
AS
( 
select d.location, d.date, d.population, d.total_deaths, d.total_cases, v.total_vaccinations,
ROUND((convert(int,d.total_deaths)/d.total_cases),5) as DeathPercentage,
ROUND((d.total_cases/d.population)*100,5) as InfectedPercentage,
ROUND((v.total_vaccinations/d.population)*100,5) as VaccinatedPercentage
FROM Portfolio_COVID..['covid vaccination'] v
JOIN Portfolio_COVID..['owid-covid-data'] d
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location = 'India'
--order by 2
)
Select *, (total_deaths/total_cases)*100 as Mortality_rate
From IndiaStat	


-- Using Temp table to perform same calc as previous query
Create table #IndiaStat
(	
	location nvarchar(255),
	date datetime,
	population numeric,
	total_deaths nvarchar(255),
	total_cases numeric,
	total_vaccinations nvarchar(255),
	DeathPercentage numeric,
	InfectedPercentage numeric,
	VaccinatedPercentage numeric
)

Insert into #IndiaStat
select d.location, d.date, d.population, d.total_deaths, d.total_cases, v.total_vaccinations,
ROUND((convert(int,d.total_deaths)/d.total_cases),5) as DeathPercentage,
ROUND((d.total_cases/d.population)*100,5) as InfectedPercentage,
ROUND((v.total_vaccinations/d.population)*100,5) as VaccinatedPercentage
FROM Portfolio_COVID..['covid vaccination'] v
JOIN Portfolio_COVID..['owid-covid-data'] d
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location = 'India'
--order by 2
Select *, (total_deaths/total_cases)*100
From #IndiaStat	

-- Using VIEW on previous query
Create view IndiaStat as
select d.location, d.date, d.population, d.total_deaths, d.total_cases, v.total_vaccinations,
ROUND((convert(int,d.total_deaths)/d.total_cases),5) as DeathPercentage,
ROUND((d.total_cases/d.population)*100,5) as InfectedPercentage,
ROUND((v.total_vaccinations/d.population)*100,5) as VaccinatedPercentage
FROM Portfolio_COVID..['covid vaccination'] v
JOIN Portfolio_COVID..['owid-covid-data'] d
	ON d.location = v.location
	AND d.date = v.date
WHERE d.location = 'India'
--order by 2

Select location, date, total_cases, total_deaths
from IndiaStat
