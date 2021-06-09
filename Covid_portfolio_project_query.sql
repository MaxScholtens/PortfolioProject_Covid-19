--Selecteren van de te gebruiken data
SELECT		location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population
FROM		Covid_Deaths
ORDER BY	location, date

--Totaal aantal geinfecteerden versus Totaal aantal overleden in Nederland
--Toont de waarschijnlijkheid van overlijden aan Covid in Nederland op een bepaalde datum. Gesorteerd op hoogste waarschijnlijkheid van overlijden
SELECT		location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		new_deaths,
		population, 
		CAST((CAST(total_deaths AS DECIMAL (12,2)) / CAST(total_cases AS DECIMAL(12,2)))*100 AS decimal (10,2)) AS Doodspercentage
			
FROM		Covid_Deaths
WHERE		Location LIKE 'Netherlands'
ORDER BY	Doodspercentage DESC

--Totaal aantal nieuwe infecties versus de totale populatie in Nederland
--Toont het percentage geinfecteerden in Nederland ten opzichte van de populatie op een bepaalde datum.
SELECT		location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		new_deaths,
		population,
		CAST((CAST(total_cases AS DECIMAL (12,2)) / CAST(population AS DECIMAL(12,2)))*100 AS decimal (10,2)) AS InfectiePercentage

FROM		Covid_Deaths
WHERE		Location LIKE 'Netherlands'
ORDER BY	InfectiePercentage DESC

--Landen met het hoogste infectiepercentage
SELECT		Location, 
		Population, 
		MAX(total_cases) as Hoogst_aantal_geinfecteerden,  
		MAX(CAST((CAST(total_cases AS DECIMAL (12,2)) / CAST(population AS DECIMAL(12,2)))*100 AS decimal (10,2))) as MAX_InfectiePercentage
FROM		Covid_Deaths
GROUP BY	Location, Population
ORDER BY	MAX_InfectiePercentage desc

--Landen met de hoogste sterftecijfers per populatie
Select		Location, 
			MAX(Total_deaths) as TotalDeathCount
From		Covid_Deaths

Where		Continent LIKE '%_%'
Group by	Location
order by	TotalDeathCount desc

--COVID statistieken van de wereld versus die van Nederland
--Een vergelijking van COVID infectie- en overlijdensstatistieken van nederland en de rest van de wereld
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

		MAX(new_deaths)	AS Dodelijkste_dag,

				(
					SELECT MAX(new_deaths)
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Dodelijkste_dag_NL,

			SUM(new_deaths)	AS Totaal_doden,

				(
					SELECT SUM(new_deaths)
					FROM Covid_Deaths
					WHERE Location LIKE 'Netherlands'
				)	AS Totaal_doden_NL
FROM		Covid_Deaths
WHERE		Continent LIKE '%_%'
GROUP BY	Location, population, continent
ORDER BY	Gemiddeld_#_doden_p_dag DESC

--Breakdown wereldwijd en per continent

--Toont de continenten met de hoogste sterftecijfers per populatie
SELECT		continent, 
		MAX(Total_deaths) AS Totaal_aantal_overleden
FROM		Covid_Deaths
WHERE		Continent LIKE '%_%'
GROUP BY	continent
ORDER BY	Totaal_aantal_overleden DESC

--Wereldwijde cijfers
SELECT		SUM(new_cases) AS Totaal_geinfecteerd, 
		SUM(cast(new_deaths as int)) AS Totaal_aantal_overleden, 
		SUM(CAST(new_deaths AS DECIMAL(12,2)))/SUM(CAST(new_cases AS DECIMAL(12,2)))*100 AS Doodspercentage
FROM		Covid_Deaths
WHERE		Continent LIKE '%_%'
ORDER BY	1,2

--VACCINATIE statistieken en controles

-- Landen die wel in de Covid_Deaths tabel zitten maar niet in de Covid_Vaccinations
SELECT		DISTINCT location
FROM		Covid_Deaths
WHERE		location NOT IN		(
					SELECT DISTINCT Location
					FROM Covid_Vaccinations
								)

--Top 5 landen met meest gezette prikken

SELECT TOP 5	Continent,
		Location,
		SUB.Som_gezette_prikken
				
FROM			(SELECT		Continent, 
							Location, 
							SUM(New_Vaccinations)		AS	Som_gezette_prikken
				FROM		Covid_Vaccinations
				WHERE		Continent LIKE '%_%'
				GROUP BY	Continent,
							Location)					AS	SUB

GROUP BY	Continent,
		Location,
		SUB.Som_gezette_prikken
ORDER BY	SUB.Som_gezette_prikken DESC	

--CTE Toont het percentage van de populatie die tenminste 1 vaccinatie prik heeft gekregen in Nederland.

With PopvsVac
			(Continent, 
			 Location, 
			 Date, 
			 Population, 
			 New_Vaccinations, 
			 Running_total_vaccinaties)
as
(
Select		 D.continent, 
		 D.location, 
		 D.date, 
		 D.population, 
		 V.new_vaccinations, 
		 SUM(V.new_vaccinations) OVER (Partition by D.Location Order by D.location, D.Date) as Running_total_vaccinaties

From		Covid_Deaths AS D
Join		Covid_Vaccinations AS V
ON			D.location = V.location
AND			D.date = V.date
WHERE		D.Continent LIKE '%_%'
AND			D.location LIKE '%Netherlands%'
)

Select *, (CAST(Running_total_vaccinaties AS DECIMAL(12,2))/Population)*100
From PopvsVac

--CTE + CASE statement om de vaccinatie voortgang te beoordelen in de Benelux per datum
WITH PopvsVac
			(Continent, 
			 Location, 
			 Date, 
			 Population, 
			 New_Vaccinations, 
			 Running_total_vaccinaties)
AS
(
Select		 	 D.continent, 
			 D.location, 
			 D.date, 
			 D.population, 
			 V.new_vaccinations, 
			 SUM(V.new_vaccinations) OVER (Partition by D.Location Order by D.location, D.Date) as Running_total_vaccinaties

From		Covid_Deaths AS D
Join		Covid_Vaccinations AS V
ON			D.location = V.location
AND			D.date = V.date
)
Select *,	CASE WHEN (CAST(Running_total_vaccinaties AS DECIMAL(12,2))/CAST(Population AS DECIMAL(12,2))*100) > 50 THEN 'Meer dan 50% gevaccineerd'
			WHEN (CAST(Running_total_vaccinaties AS DECIMAL(12,2))/CAST(Population AS DECIMAL(12,2))*100) > 25 THEN 'Meer dan 25% gevaccineerd'
			WHEN (CAST(Running_total_vaccinaties AS DECIMAL(12,2))/CAST(Population AS DECIMAL(12,2))*100) > 10 THEN 'Meer dan 10% gevaccineerd'
			ELSE 'Onder 10%' END AS vaccinatie_beoordeling
From PopvsVac
WHERE		PopvsVac.Location IN (
									SELECT location
									FROM Covid_Deaths
									WHERE location LIKE '%Netherlands%' 
									OR location LIKE '%Belgium%'
									OR location LIKE '%Luxem%'
								 )
