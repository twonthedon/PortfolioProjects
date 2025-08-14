SELECT 
    *
FROM
    CovidDeath
WHERE
	continent is not null
ORDER BY 3 , 4;

-- SELECT *
-- FROM CovidVaccinations
-- ORDER BY 3 , 4;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
WHERE continent is not null
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM CovidDeath
-- WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulatoinInfected
FROM CovidDeath
-- WHERE location LIKE '%states%'
GROUP BY Location, Population
ORDER BY 4 DESC;

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeath
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Breaking things down by Continent

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeath
-- WHERE location LIKE '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Showing contintents with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,
dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,
dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3;
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE IF exists PERCENTPOPULATIONVACCINATED
CREATE TABLE PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_caccinations numeric,
RollingPeopleVaccinated numeric

INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,
dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3;
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Creating View to store data for later Vizualization

Create View PERCENTPOPULATIONVACCINATED 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location,
dae.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3





















