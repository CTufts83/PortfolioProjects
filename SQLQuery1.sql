SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not Null
Order by 3, 4 

--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--Order by 3, 4 


-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2


-- Looking at the Total Cases vs Total Deaths
-- Shows Likelihood of death if you contracted covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows what Percentatage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentageInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2

--Looking at countries with highest infection rates compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentageInfected DESC

--Showing the countries with the highest death count per population 

SELECT Location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's break things down by Continent

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- More accurate 

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is Null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death counts 

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1, 2 

-- by DATE

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2 


--New Table
-- Looking at total population vs vaccinations

SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS RollingPeopleVaccinated,
	
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS RollingPeopleVaccinated
	
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopVsVac




-- TEMP TABLE

DROP TABLE if Exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS RollingPeopleVaccinated
	
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to Store data for later visulization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS RollingPeopleVaccinated
	
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated


