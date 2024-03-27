SELECT *
From PortfolioProject. .CovidDeaths$
ORDER BY 3, 4


--SELECT *
--From PortfolioProject. .COVIDVACCINATIONS$
--ORDER BY 3, 4

--SELECT DATA WE ARE GOING TO BE USING

SELECT location, date, total_cases cases, new_cases, total_deaths, population
From PortfolioProject. .CovidDeaths$
ORDER BY 1, 2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS

--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject. .CovidDeaths$
Where location like '%States%'
ORDER BY 1, 2

--Looking at Total cases vs Population
-- shows what percentage of population got covid

SELECT location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject. .CovidDeaths$
--Where location like '%States%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT location,  population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject. .CovidDeaths$
--Where location like '%States%'
Group by location,  population
ORDER BY 4 desc


--Showing countries with highest death counts per population

SELECT location, Max(cast(total_deaths as int)) as TotalDeathscount
From PortfolioProject. .CovidDeaths$
--Where location like '%States%'
Where continent is not Null
Group by location
ORDER BY totaldeathscount desc

--Lets break things down by continent
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathscount
From PortfolioProject. .CovidDeaths$
--Where location like '%States%'
Where continent is not Null
Group by continent
ORDER BY totaldeathscount desc

--Showing continents with the highest death count per population
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathscount
From PortfolioProject. .CovidDeaths$
--Where location like '%States%'
Where continent is not Null
Group by continent
ORDER BY totaldeathscount desc

--Global Numbers

SELECT SUM(new_cases) as Total_Cases, SUM(cast(New_Deaths as int)) as Total_deaths, SUM(cast(New_Deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject. .CovidDeaths$
--Where location like '%States%'
Where continent is not null
--Group By date
ORDER BY 1, 2

--Looking at total Population Vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..COVIDVACCINATIONS$  vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2, 3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..COVIDVACCINATIONS$  vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2, 3

--USE CTE
WIth PopvsVAc (Continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..COVIDVACCINATIONS$  vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVAc





--Temp Tables

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..COVIDVACCINATIONS$  vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..COVIDVACCINATIONS$  vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3