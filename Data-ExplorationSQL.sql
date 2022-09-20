SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Total Cases vs Total Deaths
-- Liklihood of dying if contract covid in country
Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Total cases vs Population
-- % of population covid +
Select Location, date, total_cases,  population, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


-- Countries w/ Highest Infection Rate : Population

Select Location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


-- Countries w/ Highest Death Rate per Population

Select Location, population, MAX(cast(Total_deaths AS int)) AS TotalDeathCount, MAX(cast(total_deaths AS int)/population)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by Location
order by TotalDeathCount desc

Select Location, population, MAX(cast(Total_deaths AS int)) AS TotalDeathCount, MAX((cast(Total_deaths AS int))/population)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by Location, population
order by DeathPercentage desc

-- Break Down by continent
Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathCount desc


-- Continents w/ Highest Death Count

Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM
  (new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1, 2


-- Total Population vs Vaccinations 
-- CONVERT

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- USE CTE
With PopVacPercentage (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) AS RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinationCount/Population) as PercentageVaxxed
From PopVacPercentage



-- Temp Table

DROP table if exists #PercentPopVaxed
Create Table #PercentPopVaxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaxxes numeric,
RollingVaxCount numeric
)
Insert into #PercentPopVaxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) AS RollingVaxCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingVaxCount/Population)*100 as PercentVaxxed
From #PercentPopVaxed


-- Creating View to store data for later visualization

Create View PercentPopVaxxed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) AS RollingVaxCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopVaxxed