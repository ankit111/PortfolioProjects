select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--looking at total cases vs total deaths
--shows likelihood of dying if you contact covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--looking at countries with highest infection rate compared to population

select location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, Population
order by PercentPopulationInfected desc

--showing countries with highest death count for population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location
order by TotalDeathCount desc



select *
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3, 4


----lets break things down by continent



select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount desc


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is NULL
group by location
order by TotalDeathCount desc


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount desc

--showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount desc

--global numbers

select  sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (Continent,Location, Date,Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac



--Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255).
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated