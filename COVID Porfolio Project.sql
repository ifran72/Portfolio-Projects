SELECT * 
	FROM [Portfolio Project]..CovidDeaths
	WHERE continent is not null
	ORDER BY 3,4


--SELECT * 
--	--FROM [Portfolio Project]..CovidVaccinations
--	--ORDER BY 3,4


-- Select data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM [Portfolio Project]..CovidDeaths
	ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	FROM [Portfolio Project]..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population go Covid
SELECT Location, date, population,total_cases,  (total_cases/population)*100 as CovidPercentage
	FROM [Portfolio Project]..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location, population,MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
	FROM [Portfolio Project]..CovidDeaths
	GROUP BY Location, Population
	ORDER BY PercentPopulationInfected desc

-- Let's break things down by continent 


-- Showing countries with highest death count per population
SELECT continent,MAX(cast(total_deaths as bigint)) AS TotalDeathCount
	FROM [Portfolio Project]..CovidDeaths
	WHERE continent is not null
	GROUP BY continent
	ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
	FROM [Portfolio Project]..CovidDeaths
	WHERE continent is not null
	--GROUP BY date
	ORDER BY 1,2


-- Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
		ON dea.location = vac.location
		and dea.date = vac.date
		WHERE dea.continent is not NULL
		ORDER BY 1,2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
		ON dea.location = vac.location
		and dea.date = vac.date
		WHERE dea.continent is not NULL
		--ORDER BY 2,3: CANNOT USE ORDER BY CLAUSE IN VIEWS, DERIVED TABLES, SUBQUERIES
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	(RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
		ON dea.location = vac.location
		and dea.date = vac.date
		WHERE dea.continent is not NULL
		--ORDER BY 2,3: CANNOT USE ORDER BY CLAUSE IN VIEWS, DERIVED TABLES, SUBQUERIES

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project]..CovidDeaths AS dea
	JOIN [Portfolio Project]..CovidVaccinations AS vac
		ON dea.location = vac.location
		and dea.date = vac.date
		WHERE dea.continent is not NULL
		--ORDER BY 1,2,3

SELECT * 
FROM PercentPopulationVaccinated