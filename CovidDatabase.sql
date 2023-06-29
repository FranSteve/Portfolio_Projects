Select *		
From PortfolioProject..CovidDeaths
Order by 3,4

Select *		
From PortfolioProject..CovidVaccinations
Where continent is not null
Order by 3,4



--Select the data we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population		
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at total Cases vstotal deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases , total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%States%'
Order by 1,2


--Looking at total cases vs Population
--what percentage of population got covid
Select location, date, total_cases , population, (cast(total_cases as float)/cast(population as float))*100 as CasesPercentage
From PortfolioProject..CovidDeaths
Where Location like '%Cyprus'
Order by 5 DESC


-- Looking at Countries with Highest Infection Rate compared to population
Select location, MAX(cast (population as float)) as Population, MAX(cast(total_cases as float)) as HighestInfectionCount, MAX(cast(total_cases as float)/cast(population as float))*100 as HighestCasesPercentage
From PortfolioProject..CovidDeaths
Group By location
Order by 4 DESC


Select location, MAX (population)
From PortfolioProject..CovidDeaths
Group By location
Order by 2 DESC


-- Looking at Countries with Highest Death Count compared to population
Select location, MAX(cast (population as bigint)) as Population, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order by 3 DESC


-- Let's break by continent
Select continent, MAX(cast (population as bigint)) as Population, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order by 3 DESC


-- Global Numbers
Select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as float)) as TotalDeaths ,SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
--total_cases, total_deaths, Cast(total_deaths as float)/Cast(total_cases as float)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order by 1 


--Join two data sets
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	AND dea.date=vac.date
Where dea.continent is not null
Order by 2,3 


--Looking at TotalPopulation vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	AND dea.date=vac.date
Where dea.continent is not null
Order by 2,3 


-- Summing up the newvaccinations by using partition by two see the total vaccinations done untill a particular day
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location , dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	AND dea.date=vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, VaccinationRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location , dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	AND dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (VaccinationRollingCount/Population)*100
From PopvsVac



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
VaccinationRollingCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location , dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	AND dea.date=vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (VaccinationRollingCount/Population)*100 
From #PercentPopulationVaccinated




--Creating a view to store data for ater visualisation
DROP VIEW IF EXISTS PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location , dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location= vac.location
	AND dea.date=vac.date
Where dea.continent is not null
--Order by 2,3



Select *
From PercentPopulationVaccinated