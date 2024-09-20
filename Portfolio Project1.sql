Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Total Cases Vs Total Deaths
Select location, date, total_cases, total_deaths, isnull(total_deaths/nullif (total_cases,0),0)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where location LIKE '%states%'
order by 1,2

-- Total Cases vs Population

Select location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
order by 1,2

--Countries with highest infection rate
Select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PopulationInfectedPercent
 From PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Group by location, population
order by PopulationInfectedPercent desc

--Countries with highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeath
 From PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is not NULL
Group by location
order by TotalDeath desc


--Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeath
 From PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is not NULL
Group by continent
order by TotalDeath desc


--Continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeath
 From PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is not NULL
Group by continent
order by TotalDeath desc



--Global Numbers
   
 Select date, SUM(new_cases), SUM(cast(new_deaths as int)) as DeathPercentage
 From PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is not NULL
Group by date
order by 1,2



-- --Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
---- From PortfolioProject..CovidDeaths
---- Where location LIKE '%states%'
--Where continent is not NULL
--Group by date
--order by 1,2



--Total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
order by 2,3




--use CTE

With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingpeopleVaccinated/Population)*100
From PopvsVac





--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3

Select *, (RollingpeopleVaccinated/Population)*100
From #PercentPopulationVaccinated			




--Create view to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3