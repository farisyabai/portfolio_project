-- Sorting data base on location

SELECT *
FROM `portfolio1-399509.covid_data.covid_deaths`
ORDER BY 3,4;

SELECT *
FROM `portfolio1-399509.covid_data.covid_vaccinations`
ORDER BY 3,4;


-- select data that we are going to be using

SELECT 
  location,
  date,
  new_cases,
  total_cases,
  total_deaths,
  population
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE continent is not NULL
ORDER BY 1,2;

-- Looking at total cases vs total deaths

SELECT 
  location,
  date,
  new_cases,
  total_cases,
  total_deaths,
  population,
  (total_deaths/total_cases)*100 as death_percentage
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE location = 'Indonesia'
ORDER BY 1,2;

-- Looking at total cases vs population

SELECT 
  location,
  date,
  new_cases,
  total_cases,
  total_deaths,
  population,
  (total_cases/population)*100 as percent_population_infected
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE location = 'Indonesia'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT 
  location,
  population,
  MAX(total_cases) as highest_infection,
  MAX((total_cases/population))*100 as percent_population_infected
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing countries with highest death count

SELECT 
  location,
  MAX(total_deaths) as total_deaths_per_country
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE continent is not NULL
GROUP BY location
ORDER BY total_deaths_per_country DESC;

-- Showing highest death count by each continent

SELECT 
  location,
  MAX(total_deaths) as total_deaths_per_continent
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE continent is NULL 
  AND location != 'World'
GROUP BY location
ORDER BY total_deaths_per_continent DESC;

--Showing global number of total corona case, total death and death percentage per 2021-04-30

SELECT
  SUM(new_cases) as total_case_per_day,
  SUM(new_deaths) as total_death_per_day,
  (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE continent is not NULL
ORDER BY 1;

--Showing global number of corona case, total death and death percentage per day

SELECT
  date,
  SUM(new_cases) as total_case_per_day,
  SUM(new_deaths) as total_death_per_day,
  (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM 
  `portfolio1-399509.covid_data.covid_deaths`
WHERE continent is not NULL
GROUP BY 1
ORDER BY 1;

-- Looking at total population vs vaccinations

SELECT
  d.continent,
  d.location,
  d.date,
  d.population,
  v.new_vaccinations,
  SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as total_vaccinated
FROM `portfolio1-399509.covid_data.covid_deaths` as d
JOIN portfolio1-399509.covid_data.covid_vaccinations as v
  ON d.location = v.location 
    AND d.date = v.date
WHERE d.continent is not NULL
ORDER BY 2,3;

-- create a temporary table using CTE

WITH CTE_total_vaccinated as 
(SELECT
  d.continent,
  d.location,
  d.date,
  d.population,
  v.new_vaccinations,
  SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as total_vaccinated
FROM `portfolio1-399509.covid_data.covid_deaths` as d
JOIN portfolio1-399509.covid_data.covid_vaccinations as v
  ON d.location = v.location 
    AND d.date = v.date
WHERE d.continent is not NULL
ORDER BY 2,3)

SELECT 
  *,
  (total_vaccinated/population)*100 as people_vaccinated_persentage
FROM CTE_total_vaccinated
