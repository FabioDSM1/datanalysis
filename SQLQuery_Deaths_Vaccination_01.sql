select *
from PortifolioProject.dbo.CovidDeaths$
order by 3, 4

select *
from PortifolioProject.dbo.CovidVaccinations$
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortifolioProject.dbo.CovidDeaths$
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying once infected iby countries

select location, date
	,convert (decimal(15, 0), total_cases) as covid_cases
	,convert (decimal(15, 0), total_deaths) as covid_deaths
	,convert (decimal(15, 2), (convert (decimal(15, 2), total_deaths) / convert (decimal(15, 2), total_cases))) * 100 as death_percentage
from PortifolioProject.dbo.CovidDeaths$
where continent is not null
--where location like '%Brazil%'
order by 1, 2

 -- Looking at Total Cases vs Population
 -- Shows the rate of infection by country

select location, date
	,convert (decimal(15, 0), population) as total_population
	,convert (decimal(15, 0), total_cases) as covid_cases
	,convert (decimal(15, 2),(convert (decimal(15, 2), total_cases) / convert (decimal(15, 2), population))) * 100 as population_infected
from PortifolioProject.dbo.CovidDeaths$
where continent is not null
where location like '%Brazil%'
order by 1, 2

-- Looking at Countries with highest Infection Rate
select location
	,convert (decimal(15, 0), population) as population
	,convert (decimal(15, 0), max(total_cases)) as highest_infection
	,convert (decimal(15, 2),(convert (decimal(15, 2), max(total_cases)) / convert (decimal(15, 2), population))) * 100 as population_infecte
from PortifolioProject.dbo.CovidDeaths$
where continent is not null
group by location, population
order by population_infecte desc

-- Showing Countries with Highest Death Count per Population

select location
	,convert (decimal(15, 0), max(total_deaths)) as total_deaths_count
from PortifolioProject.dbo.CovidDeaths$
where continent is not null
group by location
order by total_deaths_count desc

-- Let's break things down by continent

select location
	,max(cast(total_deaths as numeric)) as total_death_continent
from PortifolioProject.dbo.CovidDeaths$
where continent is null and location not like '%Upper%' and location not like '%Low%' and location not like 'High%' and location not like 'Inter%'
group by location
order by total_death_continent desc

--Global numbers

select SUM(cast(new_cases as numeric)) as new_cases
	,SUM(cast(new_deaths as numeric)) as new_deaths
	,(SUM(cast(new_deaths as numeric)) / SUM(cast(new_cases as numeric)))*100 as death_percentage
from PortifolioProject.dbo.CovidDeaths$
where continent is not null
order by 1, 2

--Looking at Total Population vs Vaccination

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(numeric, vac.new_vaccinations)) over  (Partition by dea.location order by dea.location, dea.date) as total_vaccination
from CovidDeathsTest dea
join PortifolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Albania%'
--group by dea.date, dea.location
order by 2,3

--WITH CTE

with PopvsVac (Continet, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(numeric, vac.new_vaccinations)) over  (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeathsTest dea
join PortifolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Albania%'
--group by dea.date, dea.location
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulation
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

--TEMP TABLE
drop table if exists #PercentPopulationVacinated
create table #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(numeric, vac.new_vaccinations)) over  (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeathsTest dea
join PortifolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null and dea.location like '%Albania%'
--group by dea.date, dea.location
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVacinated

-- Creating View to store data for later visualizations

USE [PortifolioProject]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
create view PercentPopulationVacinatedteste2 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert(numeric, vac.new_vaccinations)) over  (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortifolioProject.dbo.CovidDeaths$ dea
join PortifolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVacinatedteste2