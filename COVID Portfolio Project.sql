select * 
from [Portfolio Project].[dbo].[CovidDeaths$]
order by 3,4

--select * 
--from [Portfolio Project].[dbo].[CovidVaccinations$]
--order by 3,4

---------------------------looking Total Cases vs Total Deaths -------------------------------------
------------------------Shows likelihood of dying if you contract covid in your country----------------------------------

select Location, date, total_cases , total_deaths ,(total_deaths/total_cases)*100 as Death_percentage
from [Portfolio Project].[dbo].[CovidDeaths$]
where Location like '%states%'
order by 1,2

----------------looking Total Cases vs population ---------------
--------------Shows what percentage of population infected with Covid--------------------------
select Location, date, total_cases , population  ,(total_cases/population)*100 as totalcase_percentage
from [Portfolio Project].[dbo].[CovidDeaths$]
where Location like '%states%'
order by 1,2

--------------{{{{{{{{{{{{{{{Countries with Highest Infection Rate compared to Population}}}}}}}}-----------------
select Location, MAX(total_cases) as HighestInfectionCount , Max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project].[dbo].[CovidDeaths$]
Group by Location, Population
order by PercentPopulationInfected desc

---------------Countries with Highest Death Count per Population------------------------------

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
----Select Location, MAX(Total_deaths )as TotalDeathCount
from [Portfolio Project].[dbo].[CovidDeaths$]
--Where location like '%states%'
where Total_deaths is not Null
Group by Location
order by TotalDeathCount desc

----------------------------------- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project].[dbo].[CovidDeaths$]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-------------------------------- GLOBAL NUMBERS Deaths ---------------------------------------

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 From [Portfolio Project].[dbo].[CovidDeaths$]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------CovidVaccinations---------------------------------------------------------------
select *
from  [Portfolio Project].[dbo].[CovidDeaths$] as dea
join  [Portfolio Project].[dbo].[CovidVaccinations$] as vac
 on dea.location = vac.location
 and dea.date = vac.date

------------------ Total Population vs Vaccinations------------------------------
select dea.continent ,dea.location , dea.date , dea.population , vac.new_vaccinations
from  [Portfolio Project].[dbo].[CovidDeaths$] as dea
join  [Portfolio Project].[dbo].[CovidVaccinations$] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not Null
 order by 2,3


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent ,dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
------(RollingPeopleVaccinated/population)*100

from [Portfolio Project].[dbo].[CovidDeaths$] as dea
join  [Portfolio Project].[dbo].[CovidVaccinations$] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not Null
 order by 2,3;

 ----------- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(continent,location, date , population,new_vaccinations,RollingPeopleVaccinated)
as
(
    select dea.continent ,dea.location , dea.date , dea.population , vac.new_vaccinations
    ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    from  [Portfolio Project].[dbo].[CovidDeaths$] as dea
    join  [Portfolio Project].[dbo].[CovidVaccinations$] as vac
    on dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not Null
    ----order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100 as percentageRollingPeopleVaccinated
From PopvsVac;

-----------------------------------------Using Temp Table to perform Calculation on Partition By in previous query--------------------

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from  [Portfolio Project].[dbo].[CovidDeaths$] as dea
    join  [Portfolio Project].[dbo].[CovidVaccinations$] as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations-------------------------------------------

--Create View PercentPopulationVaccinated 
--as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
--from  [Portfolio Project].[dbo].[CovidDeaths$] as dea
--    join  [Portfolio Project].[dbo].[CovidVaccinations$] as vac
-- On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null ;
--SELECT * 
--FROM PercentPopulationVaccinated;
