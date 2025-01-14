/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From [project portfolio]..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [project portfolio]..CovidDeaths
--Where location like '%states%'
Where continent is not null
and location not in ('world', 'European Union', 'International')
Group by Location
order by TotalDeathCount desc


----------------------------2----------
--European Union is part of Europe--

Select continent, Sum(COALESCE(cast(new_deaths as int),0)) as TotalDeathCount
From [project portfolio]..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


----------------------------3----------

Select
location,
population,
Max(total_cases) as HighestInfectionCount,
Max(total_cases/population)*100 as PercentPopulationInfected
From [project portfolio]..CovidDeaths
Group By location,population
Order By PercentPopulationInfected desc


----------------------------4----------

Select
location,
population,
cast(date as date) as date,
Max(total_cases) as HighestInfectionCount,
Max(total_cases/population)*100 as PercentPopulationInfected
From [project portfolio]..CovidDeaths
Group By location,population,date
Order By PercentPopulationInfected desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


----------------------------1---------------
-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [project portfolio]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- looking at Total Population vs Vaccinations--

select dea.continent, dea.location, convert(date, dea.date) as date, population , isnull(vac.new_vaccinations,0)as new_vaccinations
From [project portfolio]..CovidDeaths dea
join [project portfolio]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
order by 2,3


-- Shows Percentage of Population that has recieved at least one Covid Vaccine--

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [project portfolio]..CovidDeaths dea
Join [project portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



--using CTE--

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [project portfolio]..CovidDeaths dea
Join [project portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac






-- Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
create table   #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPepoleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [project portfolio]..CovidDeaths dea
Join [project portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
select *, (RollingPepoleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [project portfolio]..CovidDeaths dea
Join [project portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
select*
From PercentPopulationVaccinated

