--Covid portfolio project scripts

select *
from [PortfolioProject].[dbo].[CovidDeaths$]
where continent is not null;

select location, date, population,	total_cases, new_cases, total_deaths, new_deaths
from [PortfolioProject].[dbo].[CovidDeaths$]
where continent is not null;

--total cases vs total deaths
--death percentage

select location, date, population,	total_cases, total_deaths, (total_deaths / total_cases) * 100 as deathPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
where location like '%Indi%' and continent is not null
order by location, date
;

--total cases vs population
-- affected ratio

select location, date, population,	total_cases, (total_cases / population) * 100 as InfectedPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
where location like '%Indi%' and continent is not null
order by location, date
;

--Highest infected rate compared to population

select location, population,  max(total_cases) HighestInfectedCount, max ((total_cases / population) * 100) as HighestInfectedPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
where continent is not null
--where location like '%Indi%' 
Group by Location,population--,total_cases
order by location
;


--highest deathcount per population

select location, population, max(cast(total_deaths as int)) HighestDeathCount--, max ((total_deaths / population) * 100) as HighestDeathPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
--where location like '%Indi%' 
where continent is not null
Group by Location,population
order by HighestDeathCount desc
;


--showing continents with highest deathcount per population

select location, population, max(cast(total_deaths as int)) HighestDeathCount, (max ((cast(total_deaths as int)) / population) * 100) as HighestDeathPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
--where location like '%Indi%' 
where continent is not null
Group by Location,population
order by 4 desc
;

--Global death count by date


select date, sum(cast(new_deaths as int)) DeathCount
from [PortfolioProject].[dbo].[CovidDeaths$]
--where location like '%Indi%' 
where continent is not null
Group by date
order by 2 desc
;

--Global death count 

select min(date) as StartDAte, max(date) as LastDate,sum(cast(new_deaths as int)) WorldDeathCount
from [PortfolioProject].[dbo].[CovidDeaths$]
--where location like '%Indi%' 
where continent is not null
--Group by date
--order by 1 
;


--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations],
sum(cast(vac.new_vaccinations as int )) over (partition by vac.location order by vac.location, vac.date) rolling_vacc
from  [PortfolioProject].[dbo].[CovidDeaths$] dea
join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 --CTE

 With popvsvac (continent, location,date,population, new_vaccinations, rolling_vacc)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations],
sum(cast(vac.new_vaccinations as int )) over (partition by vac.location order by vac.location, vac.date) rolling_vacc
from  [PortfolioProject].[dbo].[CovidDeaths$] dea
join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (rolling_vacc/population)*100 pecentvaccintion
 from popvsvac


 --temp table

drop table if exists #pecentpopulationvaccinated;

 create table #pecentpopulationvaccinated
 (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
rolling_vac_count nvarchar(255)
 );

 insert into #pecentpopulationvaccinated 
 select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations],
sum(cast(vac.new_vaccinations as int )) over (partition by vac.location order by vac.location, vac.date) rolling_vacc
from  [PortfolioProject].[dbo].[CovidDeaths$] dea
join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 ;

 select *
 from #pecentpopulationvaccinated;

 --create view

 create view pecentpopulationvaccinated
 as
 select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations],
sum(cast(vac.new_vaccinations as int )) over (partition by vac.location order by vac.location, vac.date) rolling_vacc
from  [PortfolioProject].[dbo].[CovidDeaths$] dea
join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 ;

 
 select *
 from pecentpopulationvaccinated;

select * 
from #pecentpopulationvaccinated;