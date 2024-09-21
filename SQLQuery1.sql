select *
from CovidProject..CovidDeaths

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths

--ALTER TABLE CovidProject..CovidDeaths ALTER COLUMN total_cases FLOAT

--Looking at Total Cases vs Total Deaths to highlight Covid's impact on mortality rate in Egypt.
Select location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From CovidProject..CovidDeaths
Where location = 'Egypt'

--Looking at Total Cases vs Population showing how many people got Covid in Egypt
Select location, date, total_cases, population,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float,population), 0)) * 100 AS Casespercentage
From CovidProject..CovidDeaths
Where location = 'Egypt'


--Looking at the total number Covid deaths according to locations descendingly
Select location, population, max(total_deaths) AS TotalDeathCount
From CovidProject..CovidDeaths
Where continent = ''
Group By location, population 
Order By max(total_deaths) DESC


--Looking at Total Population VS Vaccination
Select D.location, D.date, D.population, V.new_vaccinations, 
Sum(Convert(int,V.new_vaccinations)) OVER (Partition By D.location Order By D.location, D.date) AS totalVaccines
From CovidProject..CovidDeaths AS D
Join CovidProject..CovidVaccinations AS V
	on D.location = V.location AND D.date = V.date
Where D.continent is not null
Order By location

--Using CTE
With PopvsVac (location, date, population, new_vaccinations, totalVaccines ) AS 
(Select D.location, D.date, D.population, V.new_vaccinations, 
Sum(Convert(bigint,V.new_vaccinations)) OVER (Partition By D.location Order By D.location, D.date) AS totalVaccines
From CovidProject..CovidDeaths AS D
Join CovidProject..CovidVaccinations AS V
	on D.location = V.location AND D.date = V.date
Where D.continent is not null)
Select *, (convert(float,totalVaccines)/Nullif(convert(float,population),0))*100
From PopvsVac 


--Using a temp Table 
Drop Table if exists #PercentPopulationVaccinated --VERY IMPORTANT!
Create Table #PercentPopulationVaccinated
(location nvarchar(300),
date datetime,
population numeric,
new_vaccinations numeric,
totalVaccines numeric)
Insert into #PercentPopulationVaccinated
Select D.location, D.date, D.population, V.new_vaccinations, 
Sum(Convert(int,V.new_vaccinations)) OVER (Partition By D.location Order By D.location, D.date) AS totalVaccines
From CovidProject..CovidDeaths AS D
Join CovidProject..CovidVaccinations AS V
	on D.location = V.location AND D.date = V.date
Where D.continent is not null
Select *, (totalVaccines/population)*100
From #PercentPopulationVaccinated

