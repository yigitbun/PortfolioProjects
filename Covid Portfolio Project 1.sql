/* Covid 19 Data Exploration */

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be using

Select location,date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%germany%'
where continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population is infected with Covid

Select Location,date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%germany%'
where continent is not null
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%germany%'
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%germany%'
where continent is not null
Group by Location
order by TotalDeathCount desc



-- Breaking down by Continent

-- Showing Continents with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%germany%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%germany%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vaccination

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.Date) as CumulativeNewVaccinations
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, CumulativeNewVaccinations)
as (
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.Date) as CumulativeNewVaccinations
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
-- order by 2,3
)
Select *, (CumulativeNewVaccinations/Population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeNewVaccinations numeric
)


Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.location 
Order by dth.location, dth.Date) as CumulativeNewVaccinations
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
-- where dth.continent is not null
-- order by 2,3

Select *, (CumulativeNewVaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualisations


Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.location 
Order by dth.location, dth.Date) as CumulativeNewVaccinations
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
-- order by 2,3


Select *
From PercentPopulationVaccinated
