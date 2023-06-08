use Covid_project

select *
from Covid_deaths
-- continent is null for some lines:
-- where continent is not null
order by 3,4

select *
from Covid_vaccinations
-- continent is null for some lines:
-- where continent is not null
order by 3,4

-- Select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, new_deaths, population
from Covid_deaths
order by 1,2


-- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Covid_deaths
where continent is not null
order by 1,2


-- Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as infected_population_percentage
from Covid_deaths
where continent is not null
order by 1,2


-- Countries with highest infection count compared with population

select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infected_population_percentage
from Covid_deaths
where continent is not null
group by location, population
order by infected_population_percentage desc


-- Countries with highest death count per population

select location, population, MAX(total_deaths) as highest_death_count, MAX((total_deaths/population))*100 as death_percentage
from Covid_deaths
where continent is not null
group by location, population
order by death_percentage desc


-- Continents with highest death count per population

select continent, SUM(population) as continent_population, MAX(total_deaths) as highest_death_count, MAX((total_deaths/population))*100 as death_percentage
from Covid_deaths
where continent is not null
group by continent
order by death_percentage desc


-- Global numbers

set arithabort off
set ansi_warnings off
-- there are some zero values in 'new_cases', so the above must be done in order for the division below to take place
select date, SUM(new_cases) as new_cases_per_day, SUM(new_deaths) as deaths_per_day, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
from Covid_deaths
where continent is not null
group by date
order by 1

select SUM(new_cases) as new_cases_per_day, SUM(new_deaths) as deaths_per_day, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
from Covid_deaths
where continent is not null
order by 1


-- Joining tables

select *
from Covid_deaths deaths
join Covid_vaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
order by 3,4


-- Total population vs vaccinations

select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(vaccinations.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_vaccination_number
from Covid_deaths deaths
join Covid_vaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2,3


-- Use CTE to perform calculation on rolling vaccination number

with population_vs_vaccination (continent, location, date, population, new_vaccinations, rolling_vaccination_number)
as (
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(vaccinations.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_vaccination_number
from Covid_deaths deaths
join Covid_vaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
)
select *, (rolling_vaccination_number/population)*100 as rolling_vaccination_percentage
from population_vs_vaccination
order by 2,3


-- Create view to store data for visualisations

drop view if exists vaccinated_population_percentage
create view vaccinated_population_percentage as
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(vaccinations.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_vaccination_number
from Covid_deaths deaths
join Covid_vaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

select *
from vaccinated_population_percentage
order by 2,3