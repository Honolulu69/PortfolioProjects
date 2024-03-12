/*
Covid 19 Data Exploration 

Skills used in this project: Aggregate Functions, Joins, Converting Data Types, Window Functions, CTE's, Temp Tables, Creating Views

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Initial Data Selection from CovidDeaths Table

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Query showing the likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Query showing the percentage of the population that has been infected with Covid-19

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentOfPopInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Query showing countries with highest infection rate compared to Population

Select Location, Population, MAX(total_cases) as MaxInfectionCount,  Max((total_cases/population))*100 as PercentOfPopInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentOfPopInfected desc


-- Query showing countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as totaldeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by totaldeathCount desc



-- CONTINENTAL QUERIES

-- Query Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as totaldeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by totaldeathCount desc



-- Global Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percent_Conti
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Query showing the percentage of the population that has received at least one dose of the Covid vaccine.
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacc
--, (RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacc
--, (RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVacc/Population)*100
From PopvsVacc



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVacc
Create Table #PercentPopulationVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacc numeric
)

Insert into #PercentPopulationVacc
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacc
--, (RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVacc/Population)*100
From #PercentPopulationVacc




-- Creating a View to store data for further visualizations

Create View PercentPopulationVacc as
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacc
--, (RollingPeopleVacc/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 


