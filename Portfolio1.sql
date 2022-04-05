--Select * from [Portfolio Project].dbo.CovidDeaths$ where continent is not null;

--select the data that we are going to use 
select location,date, total_cases,new_cases, total_deaths, population 
from [Portfolio Project].dbo.CovidDeaths$  
order by 1,2

-- looking at total cases vs total deaths
--shows chances of death if you get infected by covid
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_death 
from [Portfolio Project].dbo.CovidDeaths$ where location in ('India') 
 order by 1,2

--looking at total cases VS population
-- what percent of population got covid
select location,date, total_cases, population, (total_cases/population)*100 as percentage_infection
 from [Portfolio Project].dbo.CovidDeaths$ where location in ('India') 
 order by 1,2

-- looking at countries with highest infection rate compared to population 
select location,population, max((total_cases/population)*100) as percentage_infection
from [Portfolio Project].dbo.CovidDeaths$ 
group by location,population 
order by 4 desc

-- showiing the countries with highest death count per population
select location, max(cast(total_deaths as int)) as higeshtdeath 
from [Portfolio Project].dbo.CovidDeaths$ 
where continent is not null 
group by location
order by 2 desc

-- continents with highest death count
select continent, max(cast(total_deaths as int)) as higeshtdeath 
from [Portfolio Project].dbo.CovidDeaths$ 
where continent is not null 
group by continent 
order by 2 desc

-- count of new cases in continents
select date,continent, SUM(new_cases) --total_cases,total_deaths,(total_deaths/total_cases)*100 as deathperecentage
from [Portfolio Project].dbo.CovidDeaths$ 
where continent is not null 
group by date, continent
order by 1,2 desc

--calculating the rate of death with respect to total new cases 
select date,SUM(new_cases)  as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/NullIf(SUM(new_cases),0)  * 100  as deathperecentage 
from [Portfolio Project].dbo.CovidDeaths$ 
where continent is not null 
group by date , continent
order by 1  desc

--rate of death with respect to total cases
select date, continent, location, sum(cast(total_deaths as int))/sum(cast(total_cases as int)) * 100 as rate
from [Portfolio Project].dbo.CovidDeaths$ where continent is not null group by date, continent , location 
 order by 1  desc

--total population vs vaccinations
select death.continent, death.location,death.date, death.population,vacc.new_vaccinations,
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER(Partition by death.location order by death.location,death.date)  as total_vaccinated
from [Portfolio Project].dbo.CovidDeaths$  death 
JOIN [Portfolio Project].dbo.CovidVaccinations$ vacc 
on death.location =vacc.location and death.date = vacc.date
where death.continent is not null  order by 2,3


-- use a  cte 

WITH PopVsVac(continent, location, date, population, new_vaccinations, total_vaccinated )
as
(
select death.continent, death.location,death.date, death.population,vacc.new_vaccinations,
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER(Partition by death.location order by death.location,death.date)  as total_vaccinated
from [Portfolio Project].dbo.CovidDeaths$  death 
JOIN [Portfolio Project].dbo.CovidVaccinations$ vacc 
on death.location =vacc.location and death.date = vacc.date
where death.continent is not null ) select *, (total_vaccinated/population) * 100 as rateofvaccinated from PopVsVac

-- maximum vaccinations 
select death.continent,  max(total_vaccinations)
from [Portfolio Project].dbo.CovidDeaths$  death 
JOIN [Portfolio Project].dbo.CovidVaccinations$ vacc 
on death.location =vacc.location and death.date = vacc.date
where death.continent is not null 
group by death.continent  order by 1

-- temp table 
DROP table if exists #percentpopvaccinated
create table #percentpopvaccinated (
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric ,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopvaccinated
select death.continent, death.location,death.date, death.population,vacc.new_vaccinations,
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER(Partition by death.location order by death.location,death.date)  as total_vaccinated
from [Portfolio Project].dbo.CovidDeaths$  death 
JOIN [Portfolio Project].dbo.CovidVaccinations$ vacc 
on death.location =vacc.location and death.date = vacc.date
select *, (rollingpeoplevaccinated/population) * 100 as rateofvaccinated from #percentpopvaccinated


-- creating view to store data for visuals
create view PercentPopVacc as 
select death.continent, death.location,death.date, death.population,vacc.new_vaccinations,
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER(Partition by death.location order by death.location,death.date)  as total_vaccinated
from [Portfolio Project].dbo.CovidDeaths$  death 
JOIN [Portfolio Project].dbo.CovidVaccinations$ vacc 
on death.location =vacc.location and death.date = vacc.date where death.continent is not null

select * from PercentPopVacc

drop view if exists PercentPopVaccinated