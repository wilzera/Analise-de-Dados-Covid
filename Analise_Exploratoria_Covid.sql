--- Separando as colunas que iremos utilizar
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


--- Comparando a qtd. de casos X qtd. mortes no Brasil
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'PorcentagemDeMortes' 
FROM CovidDeaths
WHERE location = 'Brazil'
ORDER BY 1,2


--- Comparando a qtd. total de casos X popula��o no Brasil
SELECT location, date, total_cases, (total_cases/population)*100 AS 'PorcentagemDaPopulacaoComCovid' 
FROM CovidDeaths
WHERE location = 'Brazil'
AND continent IS NOT NULL
ORDER BY 1,2


--- Pa�ses com a maior taxa de infec��o em rela��o a popula��o
SELECT location, population AS 'Popula��o', MAX(total_cases) AS 'MaiorQtdCasos', MAX((total_cases/population))*100 AS 'PorcentagemDaPopulacaoComCovid' 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY PorcentagemDaPopulacaoComCovid DESC


--- Pa�ses com a  maior quantidade de mortes
SELECT Location, MAX(CAST(TOTAL_DEATHS as int)) AS 'TotalMortes'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalMortes DESC


--- Continentes com a maior quantidade de mortes
SELECT Continent, MAX(CAST(TOTAL_DEATHS as int)) AS 'TotalMortes'
FROM CovidDeaths
GROUP BY Continent
ORDER BY TotalMortes DESC
-----------------------------------------------------------------------------


--- Taxa de mortalidade global
SELECT date, SUM(new_cases) AS 'Qtd.Casos', SUM(CAST(new_deaths AS INT)) AS 'Qtd.Mortes', (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS 'TaxaDeMortalidade'
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-----------------------------------------------------------------------------

--- Popula��o total VS Qtd. Vacina��es

SELECT
deaths.continent , deaths.location, deaths.date, deaths.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS 'TotalVacina��es'
FROM CovidDeaths deaths
JOIN CovidVaccinations vac ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.location IS NOT NULL 
ORDER BY 1,2,3


--- CTE (Common Table Expression) para apresentar a popula��o total VS Qtd. vacina��es
WITH PopulacaoVacinada (Continent, Location, Date, Population, New_vaccinations, TotalVacina��es)
AS (
SELECT
deaths.continent , deaths.location, deaths.date, deaths.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS 'TotalVacina��es'
FROM CovidDeaths deaths
JOIN CovidVaccinations vac ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.location IS NOT NULL 
)
SELECT *, (TotalVacina��es/Population)*100 AS 'TaxaPopulacaoVacinada'
FROM PopulacaoVacinada


--- Tabela Tempor�ria 
DROP TABLE IF EXISTS #PorcentagemPopulacaoVacinada
CREATE TABLE #PorcentagemPopulacaoVacinada
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations numeric,
TaxaPopulacaoVacinada numeric
)


--- Adicionando dados na tabela tempor�ria
INSERT INTO #PorcentagemPopulacaoVacinada
SELECT
deaths.continent , deaths.location, deaths.date, deaths.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS 'TotalVacina��es'
FROM CovidDeaths deaths
JOIN CovidVaccinations vac ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.location IS NOT NULL 


--- Criando uma view para consultar estes dados depois
CREATE VIEW PorcentagemPopulacaoVacinada AS
SELECT
deaths.continent , deaths.location, deaths.date, deaths.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS 'TotalVacina��es'
FROM CovidDeaths deaths
JOIN CovidVaccinations vac ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.location IS NOT NULL 
