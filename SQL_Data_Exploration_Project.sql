SELECT * FROM Project.dbo.CovidDeaths$
SELECT * FROM Project.dbo.CovidVaccinations

--Selecting Required data:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project.dbo.CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood if you contract in your country

SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS Death_Percentage
FROM Project.dbo.CovidDeaths$
WHERE location like 'Pakistan'
AND continent is not null
ORDER BY location, date

--Looking at the Total Cases vs Population
--Shows percentage of Population that got COVID case

SELECT location, date, total_cases, Population, (CAST(total_cases AS float)/CAST( population AS float))*100 AS PercentagePopulationInfected
FROM Project.dbo.CovidDeaths$
--WHERE location like 'Pakistan'
ORDER BY location, date

--Looking at countries with Highest Infection rate compared to population

SELECT location, MAX(total_cases) AS Highest_Infected, Population, 
MAX(CAST(total_cases AS float))/MAX(CAST( population AS float))*100 AS PercentagePopulationInfected
FROM Project.dbo.CovidDeaths$
--WHERE location like 'Pakistan'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


--Showing Country with Highest Death Counts 
SELECT location, MAX(CAST(total_deaths AS bigint)) as TotalDeaths
FROM Project.dbo.CovidDeaths$
--WHERE location like 'Pakistan'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths desc

--BREATKDOWN BY CONTINENT

--Showing cotninent with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS bigint)) as TotalDeaths
FROM Project.dbo.CovidDeaths$
--WHERE location like 'Pakistan'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc

--Globar Numbers

SELECT  date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
CASE WHEN SUM(new_cases) = 0 THEN NULL
         ELSE SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(new_cases), 0)
    END AS Death_Percentage
FROM Project.dbo.CovidDeaths$
--WHERE location like 'Pakistan'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Looking at Total Population VS Vaccination

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.location)
FROM
  Project.dbo.CovidDeaths$ AS dea
JOIN
  Project.dbo.CovidVaccinations AS vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  dea.location,
  dea.date;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3