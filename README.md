# PortfolioProject_Covid-19
Een demonstratie van opgedane SQL ervaring in de vorm van verkennende data analyse op een Covid-19 dataset

-- Selecteren van de te gebruiken data
SELECT		location, 
			date, 
			total_cases, 
			new_cases, 
			total_deaths, 
			population
FROM		Covid_Deaths
ORDER BY	location, date

-- Totaal aantal geinfecteerden versus Totaal aantal overleden in Nederland
-- Toont de waarschijnlijkheid van overlijden aan Covid in Nederland op een bepaalde datum. Gesorteerd op hoogste waarschijnlijkheid van overlijden
SELECT		location, 
			date, 
			total_cases, 
			new_cases, 
			total_deaths, 
			new_deaths,
			population, 

			CAST((CAST(total_cases AS DECIMAL (12,2)) / CAST(population AS DECIMAL(12,2)))*100 AS decimal (10,2)) AS InfectiePercentage,
			CAST((CAST(total_deaths AS DECIMAL (12,2)) / CAST(total_cases AS DECIMAL(12,2)))*100 AS decimal (10,2)) AS Doodspercentage
			
FROM		Covid_Deaths
WHERE		Location LIKE 'Netherlands'
ORDER BY	Doodspercentage DESC

-- Doodsstatistieken van de wereld versus die van Nederland
-- Een vergelijking van COVID infectie- en overlijdensstatistieken van nederland en de rest van de wereld
SELECT		Location,
			continent,
			population,
			MAX(CAST(total_cases AS decimal(12,2))/CAST(population AS decimal(12,2)))*100 AS Infectiepercentage,

				(
					SELECT MAX(CAST(total_cases AS decimal(12,2))/CAST(population AS decimal(12,2)))
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Infectiepercentage_NL,

			SUM(CAST(new_deaths AS decimal(12,2))/CAST(population AS decimal(12,2)))*100 AS Doden_per_populatie,

				(
					SELECT SUM(CAST(new_deaths AS decimal(12,2))/CAST(population AS decimal(12,2)))
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Doden_per_populatie_NL,

			AVG(CAST(new_deaths AS decimal(12,2)))	AS Gemiddeld_#_doden_p_dag,

				(
					SELECT AVG(CAST(new_deaths AS decimal(12,2)))
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Gemiddeld_#_doden_p_dag_NL,

			MAX(new_deaths)							AS Dodelijkste_dag,

				(
					SELECT MAX(new_deaths)
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Dodelijkste_dag_NL,

			SUM(new_deaths)							AS Totaal_doden,

				(
					SELECT SUM(new_deaths)
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Totaal_doden_NL
FROM		Covid_Deaths
WHERE		Continent LIKE '%_%'
GROUP BY	Location, population, continent
ORDER BY	Gemiddeld_#_doden_p_dag DESC
