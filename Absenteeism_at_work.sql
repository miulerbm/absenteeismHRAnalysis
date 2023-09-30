-- Empezamos a construir la DB


-- Vamos a cear una tabla con JOIN

SELECT *
FROM dbo.Absenteeism_at_work as a
-- Vamos a asociar la tabla principal (izq) 'Absenteeism'
-- con la tabla 'compensation' para tener en una sola tabla
-- Los datos de cada individuo (ID)
-- Se emplean alias para hacer más cortas las referencias
LEFT JOIN dbo.compensation as b ON a.ID = b.ID
-- Ahora, se desea tomar a esta tabla generada y unirla con
-- La tabla 'Reasons', a fin de contar con los datos consolidados
LEFT JOIN dbo.Reasons as r ON a.Reason_for_absence = r.Number;


-- Respondiendo a las preguntas de negocio:

-- Lista de 1000 empleados a los que darle un incentivo de 1000 USD.
-- Encontrar a los más saludables.
-- Criterios: que no fumen, que no tomen

-- Definimos una Window Function con el nombre "AvgAbsenteeism" para 
-- calcular el promedio de días de ausentismo
WITH AvgAbsenteeism AS (
    SELECT AVG(a.Absenteeism_time_in_hours) AS AvgAbsenteeismTime
    FROM dbo.Absenteeism_at_work as a
)

-- Filtramos según criterio para encontrar a los 
-- empleados más saludables y aptos para el bonus
SELECT *
FROM dbo.Absenteeism_at_work as a
WHERE a.Social_drinker = 0 AND a.Social_smoker = 0
-- Un BMI (Body mass index) saludable menor a 25
AND a.Body_mass_index < 25
-- Usamos la ventana para comparar con el promedio de Absenteeism_time_in_hours
AND a.Absenteeism_time_in_hours < (SELECT AvgAbsenteeismTime FROM AvgAbsenteeism);


-- Calcular el incremento de compensacion para no fumadores
-- Usaremos el budget de 983, 221 para calcular la compensacion

-- Primero obtenemos cuántos no fumadores hay (686)
SELECT COUNT(*) AS nonsmokers FROM Absenteeism_at_work as a
WHERE a.Social_smoker = 0;

-- El total de horas que trabaja cada empleado se estima
-- tomando el total de horas al año por cada uno x 686 empleados
-- Resultado de: 5 x 8 x 52 x 686 = 1426880
SELECT (5*8*52*686);
-- 983221/1426880 = 0.6890705595424983 -> Incremento por hora
-- que se le dará a cada uno de los 686 empleados no fumadores
-- Calculado a partir del presupuesto (budget) de 983221 USD
-- Anualmente, esto representaría: 1414.4 USD al año extra.

-- CONCLUSION: Incremento de 0.68/hr para los no fumadores

-- OPTIMIZANDO EL QUERY PARA LOS DATOS CONSOLIDADOS:
-- Vamos a categorizar a ciertos individuos con un CASE
SELECT
	a.ID
	, r.Reason
	, a.Month_of_absence
	, a.Body_mass_index
	-- Categorizando por BMI
	, CASE	WHEN Body_mass_index <= 19	THEN 'Underweight'
			WHEN Body_mass_index <= 25	THEN 'Healthy Weight'
			WHEN Body_mass_index <= 30	THEN 'Overweight'
			WHEN Body_mass_index > 30	THEN 'Obese'
			ELSE 'Unknown' END AS BMI_Category
	-- Categorizando por estaciones:
	, CASE	WHEN a.Month_of_absence IN (12,1,2) THEN 'Winter'
			WHEN a.Month_of_absence IN (3,4,5) THEN 'Spring'
			WHEN a.Month_of_absence IN (6,7,8) THEN 'Summer'
			WHEN a.Month_of_absence IN (9,10,11) THEN 'Fall'
			ELSE 'Unknown' END as Season_Names
	, a.Month_of_absence
	, a.Day_of_the_week
	, a.Transportation_expense
	, a.Education
	, a.Son
	, a.Social_drinker
	, a.Social_smoker
	, a.Pet
	, a.Disciplinary_failure
	, a.Age
	, a.Work_load_Average_day
	, a.Absenteeism_time_in_hours
FROM dbo.Absenteeism_at_work as a
-- Vamos a asociar la tabla principal (izq) 'Absenteeism'
-- con la tabla 'compensation' para tener en una sola tabla
-- Los datos de cada individuo (ID)
-- Se emplean alias para hacer más cortas las referencias
LEFT JOIN dbo.compensation as b ON a.ID = b.ID
-- Ahora, se desea tomar a esta tabla generada y unirla con
-- La tabla 'Reasons', a fin de contar con los datos consolidados
LEFT JOIN dbo.Reasons as r ON a.Reason_for_absence = r.Number;





