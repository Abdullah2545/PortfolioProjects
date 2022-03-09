/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

show databases;
use covid19;
show tables;

select * from coviddeaths;


-- Filtering Data

Select Location, STR_TO_DATE(date_, '%m/%d/%Y') as Date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2;


-- Death ratio in Pakisatn

Select Location, STR_TO_DATE(date_, '%m/%d/%Y') as Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathRatio
From CovidDeaths
Where location like '%paki%'
and continent is not null 
order by 1,2;


-- Percentage of population infected with Covid

Select Location, STR_TO_DATE(date_, '%m/%d/%Y') as Date, Population, total_cases,  (total_cases/population)*100 as CasesRatio
From CovidDeaths
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as CasesRatio
From CovidDeaths
Group by Location, Population
order by CasesRatio desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


-- Showing contintents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date_, cd.population, vc.new_vaccinations
, SUM(vc.new_vaccinations) OVER (Partition by cd.Location Order by cd.Date_) as RollingPeopleVaccinated
From coviddeaths cd
Join covidvaccinations vc
	On cd.location = vc.location
	and cd.date_ = vc.date
where cd.continent is not null 
order by 2,3;


-- Total Polulation vs Vaccinations

With PopvsVac as
(
Select cd.continent, cd.location, cd.date_, cd.population, vc.new_vaccinations
, SUM(vc.new_vaccinations) OVER (Partition by cd.Location Order by cd.Date_) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date_ = vc.date
where cd.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

-- DROP Table if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date_ datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
Insert into PercentPopulationVaccinated
Select cd.Continent, cd.Location, STR_TO_DATE(cd.date_, '%m/%d/%Y') as Date_, cd.Population, vc.New_vaccinations
, SUM(vc.new_vaccinations) OVER (Partition by cd.Location Order by cd.Date_) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date_ = vc.date;
    
select *,((RollingPeopleVaccinated/Population)*100)
from PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
Drop Table if exists PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
Select cd.Continent, cd.Location, STR_TO_DATE(cd.date_, '%m/%d/%Y') as Date_, cd.Population, vc.New_vaccinations
, SUM(vc.new_vaccinations) OVER (Partition by cd.Location Order by cd.Date_) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date_ = vc.date
where cd.continent is not null ;

select * from PercentPopulationVaccinated;