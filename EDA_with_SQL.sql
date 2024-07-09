SELECT * FROM covid_analysis.coviddeaths;

select * from covid_analysis.coviddeaths;

select * from covid_analysis.covidvaccinations;

select *from covid_analysis.coviddeaths where continent is not null order by 3,4;

select *from covid_analysis.covidvaccinations order by 3;

-- selecting the data what we are using
SELECT Location, date, total_cases, total_deaths,population FROM covid_analysis.coviddeaths 
where continent is not null
order by 1,2;

-- looking at Total Cases vs Total Deaths in India
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deaths_Percentage FROM covid_analysis.coviddeaths 
where location like '%india' order by 1,2;

-- Looking at Total Cases vs Population in India
SELECT Location, date, total_cases, population,(total_cases/population)*100 as Deaths_Percentage FROM covid_analysis.coviddeaths 
where location like '%india' order by 1,2;

-- Looking at Countries with Highest Information Rate compared to Population
SELECT location, max( total_cases)as HighestInfectionCount , population,max(total_cases/population)*100 as PopulationInfectedPercentage FROM covid_analysis.coviddeaths 
-- where location like '%india' 
group  by location,population
order by PopulationInfectedPercentage desc;

-- Showing Countries with Highest Death Count per Population

SELECT location, max(total_deaths)as TotalDeathCount  FROM covid_analysis.coviddeaths 
-- where location like '%india' 
where continent is not null
group  by location
order by HighestDeathCount desc;

-- Let's Break Down by Continent

SELECT continent, max(total_deaths)as HighestDeathCount  FROM covid_analysis.coviddeaths 
-- where location like '%india' 
where continent is not null
group  by continent
order by HighestDeathCount desc;

-- showing continents with the highest death count per population

select continent ,population,max(total_deaths) as TotalDeathCounts from covid_analysis.coviddeaths
where continent is not null
group by Continent,population order by TotalDeathCounts;

-- Global Numbers
select date,sum(new_cases)as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage from covid_analysis.coviddeaths
where continent is not null
group by date order by 1,2;

-- covidvaccinations

select * from covid_analysis.covidvaccinations;

 -- joining two tables 
select * from covid_analysis.coviddeaths cd left join  covid_analysis.covidvaccinations cv on cd.location = cv.location;

-- Looking at total populations vs vaccinations

select cd.continent ,cd.location ,cd.date,cd.population,cv.new_vaccinations , sum(cv.new_vaccinations) over (partition by cd.location order by cd.location ,cd.date) as RollingPeopleVaccinated
from covid_analysis.coviddeaths cd join covid_analysis.covidvaccinations cv 
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null order by 2,3;

-- using CTE

with popvsvac(continent,loaction,date,population,new_vaccincations,RollingPeopleVaccinated)
as
(
	select cd.continent ,cd.location ,cd.date,cd.population,cv.new_vaccinations , sum(cv.new_vaccinations) over (partition by cd.location order by cd.location ,cd.date) as RollingPeopleVaccinated
from covid_analysis.coviddeaths cd join covid_analysis.covidvaccinations cv 
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

)
select *,(RollingPeoplevaccinated/population)*100 from popvsvac;

-- Temp Table

CREATE TABLE PopulationVaccinatedPercentage3 (
    continent NVARCHAR(255),
    location NVARCHAR(200),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
INSERT INTO PopulationVaccinatedPercentage3
SELECT 
    cd.continent,
    cd.location,
    STR_TO_DATE(cd.date, '%d-%m-%Y') AS date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM 
    covid_analysis.coviddeaths cd
JOIN 
    covid_analysis.covidvaccinations cv 
ON 
    cd.location = cv.location 
    AND STR_TO_DATE(cd.date, '%d-%m-%Y') = STR_TO_DATE(cv.date, '%d-%m-%Y')
WHERE 
    cd.continent IS NOT NULL 
ORDER BY 
    cd.location, STR_TO_DATE(cd.date, '%d-%m-%Y');
    
SELECT *,
       (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
    PopulationVaccinatedPercentage3;
    
-- creating view 

CREATE VIEW formatted_coviddeaths AS 
SELECT 
    continent,
    location,
    STR_TO_DATE(date, '%d-%m-%Y') AS date,
    population
FROM 
    covid_analysis.coviddeaths;

CREATE VIEW formatted_covidvaccinations AS 
SELECT 
    location,
    STR_TO_DATE(date, '%d-%m-%Y') AS date,
    new_vaccinations
FROM 
    covid_analysis.covidvaccinations;

CREATE VIEW PopulationVaccinatedPercentage1 AS 
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS RollingPeopleVaccinated
FROM 
    covid_analysis.coviddeaths cd 
JOIN 
    covid_analysis.covidvaccinations cv 
ON 
    cd.location = cv.location 
    AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL;

