select *
from portofolioproject..CovidDeaths
order by 3,4

select *
from portofolioproject..CovidVaccinations
order by 3,4

--data i will be using

select location, date, total_cases, new_cases, total_deaths, population
from portofolioproject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portofolioproject..CovidDeaths
where location like '%indonesia%'
order by 1,2

--looking at total cases vs population
--shows % population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
from portofolioproject..CovidDeaths
where location like '%indonesia%'
order by 1,2

--looking at country with highest infection rate compared to Population

select location, population, max(total_cases) as HighestInfection, max(total_cases/population)*100 as PercentPopulationInfected
from portofolioproject..CovidDeaths
--where location like '%indonesia%'
group by location, population
order by PercentPopulationInfected desc

--showing the countries with highest death count/population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from portofolioproject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc

--breaking things down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from portofolioproject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continent with highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from portofolioproject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeath, sum(cast(new_deaths as int))/sum(new_cases)*100 
as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portofolioproject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portofolioproject..CovidDeaths dea
Join portofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portofolioproject..CovidDeaths dea
Join portofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
From portofolioproject..CovidDeaths dea
Join portofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portofolioproject..CovidDeaths dea 
Join portofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated