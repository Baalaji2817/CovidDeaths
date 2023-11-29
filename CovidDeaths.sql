--COVID DEATH
SELECT * FROM portfolioproject..CovidDeath
--WHERE continent NOT LIKE '%0'
ORDER BY 3,4;

--Total deaths vs Total cases
SELECT location, date, total_deaths, total_cases, CASE WHEN total_cases = 0 THEN 0 ELSE (total_deaths/total_cases)*100 END as Death_Percentage
FROM portfolioproject..CovidDeath
WHERE continent NOT LIKE '%0'
ORDER BY 1,2;

--Percentage of population got covid
SELECT location, date, population, total_cases, CASE WHEN total_cases = 0 THEN 0 ELSE ((total_cases/population)*100) END as Percentage_of_population
FROM portfolioproject..CovidDeath
--WHERE location LIKE 'Ind%' AND continent NOT LIKE '%0'
ORDER BY 1,2;

--Country with highest infection rate
SELECT location, population, MAX(total_cases) as HighInfectedCount, (MAX(total_cases/population)*100) as PercentPopulationInfected
FROM portfolioproject..CovidDeath
WHERE continent NOT LIKE '%0'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--showing countires with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount, (MAX(total_deaths/population)*100) as PercentPopulationdead
FROM portfolioproject..CovidDeath
--WHERE continent NOT LIKE '%0'
GROUP BY location
ORDER BY TotalDeathCount DESC;

--showing continent with highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount, (MAX(total_deaths/population)*100) as PercentPopulationdead
FROM portfolioproject..CovidDeath
WHERE continent NOT LIKE '%0'
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE (SUM(new_deaths)/SUM(new_cases)*100) END as Percentage_of_death
FROM portfolioproject..CovidDeath
WHERE continent NOT LIKE '0%'
--GROUP BY date
ORDER BY 1,2;

-- COVID VACCINATION

SELECT * FROM portfolioproject..CovidVaccination
ORDER BY 3,4;

-- TOTAL POPULATION VS TOTAL VACCINATION BY JOINING TWO TABLES

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM portfolioproject..CovidDeath dea
JOIN portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT LIKE '0%'
ORDER BY 2,3;

-- USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM portfolioproject..CovidDeath dea
JOIN portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT LIKE '0%'
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccination/population)*100 as PercentageVaccination
FROM popvsvac
ORDER BY 2,3


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM portfolioproject..CovidDeath dea
JOIN portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent NOT LIKE '0%'
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccination/population)*100 as PercentageVaccination
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM portfolioproject..CovidDeath dea
JOIN portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT LIKE '0%'
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated