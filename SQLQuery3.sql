Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2 

--Looking at Total cases vs Total deaths , 
--shows likelihood of dying if you get covid in your country / USA
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%States%'
Order by 1,2

--Looking at Total Cases vs Population 
--Shows what percentage of population got covid
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%States%'
Order by 1,2


 --Looking at countries with highest infection rate compared to population 
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, Population
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population 
Select Location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By Location
Order by TotalDeathCount desc

--Breaking total death down by continents 
Select Continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By continent
Order By TotalDeathCount desc

--Correct Version of total death by continents
Select Location, MAX(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is null
Group By Location
Order By TotalDeathCount desc

--Global Numbers with Date
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Date
Order by 1,2

--total deaths/total cases
Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where Continent is not null
--Group by Date
Order by 1,2


--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinateed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3



--USING CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinateed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)

Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMPORARY TABLE 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinateed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date


SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 


-- CREATE VIEW TO STORE DATA FOR VISUALIZATIONS 

Create View ThePercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinateed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null


Select * 
 From ThePercentPopulationVaccinated
