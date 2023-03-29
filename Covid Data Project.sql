--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM covid_data_project..CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
SELECT Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM covid_data_project..CovidDeaths
WHERE location Like 'Australia' 
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT Location, Date, Population, Total_Cases, (total_cases/population)*100 as Percentage_Population_Infected
FROM covid_data_project..CovidDeaths
WHERE location Like 'Australia' 
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to their Population
SELECT Location, Population, MAX(Total_Cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_Population_Infected
FROM covid_data_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY Percentage_Population_Infected DESC

--Looking at Death Count per Continent
SELECT Continent, MAX(Total_Deaths) as Total_Death_Count
FROM covid_data_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY Total_Death_Count DESC

--Looking at New Cases vs New Deaths Globally Grouped by Date
SELECT Date, SUM(new_cases) as Global_New_Cases, SUM(new_deaths) as Global_New_Deaths, 
SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as Global_Death_Percentage
FROM covid_data_project..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
--SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vax.New_Vaccinations,
--SUM(CAST(vax.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as People_Vaccinated
--FROM covid_data_project..CovidDeaths dea
--JOIN covid_data_project..CovidVaccinations vax
--	ON dea.location = vax.location 
--	AND dea.date = vax.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

--Looking at Total Population vs Vaccinations with CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vax.New_Vaccinations,
SUM(CAST(vax.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as People_Vaccinated
FROM covid_data_project..CovidDeaths dea
JOIN covid_data_project..CovidVaccinations vax
	ON dea.location = vax.location 
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (People_Vaccinated/Population)*100 as Vaccination_Percentage
FROM PopVsVac

--Creating Views

CREATE VIEW Percent_Population_Vaccinated as 
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vax.New_Vaccinations,
SUM(CAST(vax.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.Date) as People_Vaccinated
FROM covid_data_project..CovidDeaths dea
JOIN covid_data_project..CovidVaccinations vax
	ON dea.location = vax.location 
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL

CREATE VIEW Total_Deaths_per_Continent as
SELECT Continent, MAX(Total_Deaths) as Total_Death_Count
FROM covid_data_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
--ORDER BY Total_Death_Count DESC