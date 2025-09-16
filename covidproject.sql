# Covid 19 Data Exploration 

SELECT * 
FROM CovidPortfolio.coviddeaths;

# Keep only rows with a continent value so we get countries, not continent or world totals(WHERE continent is not null).
SELECT *
FROM CovidPortfolio.coviddeaths
WHERE continent is not null
ORDER BY location, 'date';

SELECT location, 'date', total_cases, new_cases, total_deaths, population
FROM CovidPortfolio.coviddeaths
ORDER BY location, 'date';

# Total Cases vs Total Deaths in the United States
# Shows likelihood of dying if you contract covid
SELECT location, `date`, total_cases, total_deaths, (total_deaths / NULLIF(total_cases,0)) * 100 AS deathpercentage
FROM CovidPortfolio.coviddeaths
WHERE location LIKE '%states%' 
ORDER BY location, `date`;

# Total Cases vs Population in the United States
# Shows what percentage of poupulation infected with Covid
SELECT location, `date`, total_cases, population, (total_cases / population) * 100 AS percentpopulationinfected
FROM CovidPortfolio.coviddeaths
WHERE location LIKE '%states%'
ORDER BY location, `date`;

-- Peak COVID-19 Infection Rates by Location
SELECT location, population, MAX(total_cases) AS highestinfectioncount, MAX((total_cases / population) * 100) AS percentpopulationinfected
FROM CovidPortfolio.coviddeaths
GROUP BY location, populationcoviddeaths
ORDER BY percentpopulationinfected DESC;

# Global COVID-19 Death Rankings (by Country)
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolio.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

# Breaking Things Down By Continent
# Highest Reported COVID-19 Deaths by Continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolio.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

# Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM CovidPortfolio.coviddeaths
WHERE continent IS NOT NULL;

# Cumulative Vaccinations Over Time by Location
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM  CovidPortfolio.coviddeaths dea
JOIN CovidPortfolio.covidvaccinations vac
ON dea.location = vac.location
AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.`date`;


# Using CTE
WITH PopvsVac AS (
	SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.`date`) AS RollingPeopleVaccinated
    FROM CovidPortfolio.coviddeaths dea
    JOIN CovidPortfolio.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.`date` = vac.`date`
    WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PopvsVac;

