select *
from PortfolioProject..CovidDeaths
order by 3, 4

--select *
--from CovidVaccinations
--order by 3,4


--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1, 2

-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (cast(total_deaths as dec)/cast(total_cases as dec))*100 as DeathsPercentage
from CovidDeaths$
where location like 'United States'
order by DeathsPercentage desc
 

 -- Looking at the Total Cases vs Population
 -- Shows what percentage of the population got Covid

 select location, date, total_cases, population, (cast(total_cases as dec)/population)*100 as PercentPopulationInfected
from CovidDeaths$
where location like '%States%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

 select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as dec))/population)*100 as PercentPopulationInfected
from CovidDeaths$
--where location like '%Afghan%'
--where total_cases is not null
group by location, population
order by PercentPopulationInfected desc

--select *
--from CovidDeaths
--where continent is not null -- can add this line to each script for more accurate data
--order by 3,4

 select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--select location, total_cases, population, cast(total_cases as dec)/population
--from dbo.CovidDeaths$
--where location like 'Argentina'
--order by total_cases 



--select total_cases, population
--from CovidDeaths
--order by total_cases 


 select location, max(cast(total_deaths as int)) as TotalDeathCount
 from CovidDeaths$
 where continent is null
 group by location
 order by TotalDeathCount desc

  --showing continents with the highest death count per population

  select continent, max(cast(total_deaths as int)) as TotalDeathCount
 from CovidDeaths$
 where continent is not null
 group by continent
 order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as dec))/sum(cast(new_cases as dec))*100 as DeathPercentage --, total_deaths, (cast(total_deaths as dec)/cast(total_cases as dec))*100 as DeathsPercentage
from CovidDeaths$
--where location like United States
where continent is not null
and new_cases<>0
group by date
order by 1,2 

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as dec))/sum(cast(new_cases as dec))*100 as DeathPercentage --, total_deaths, (cast(total_deaths as dec)/cast(total_cases as dec))*100 as DeathsPercentage
from CovidDeaths$
--where location like United States
where continent is not null
and new_cases<>0
--group by date
order by 1,2 

--Looking at the Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as dec)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as dec)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVacccinated/Population)*100
from PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)




insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as dec)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as dec)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated