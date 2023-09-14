
/*

Malaysia Median Salary 

*/


-- ETHNICITY

-- Citizen Overall (Bumiputera, Chinese, Indian and Others)

WITH cte_citizen as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM ethnicity
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median, 
	((median-previous_median)/previous_median)*100 as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_citizen
WHERE variable <> 'Overall' AND sex = 'overall' AND variable IN('Bumiputera', 'Chinese', 'Indian', 'Other (Citizen)')
ORDER BY variable, year


-- Male vs Female Citizen

WITH cte_gender as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex) as previous_median
FROM ethnicity
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median, 
	((median-previous_median)/previous_median)*100 as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_gender
WHERE variable <> 'Overall' AND sex <> 'overall' AND variable IN('Bumiputera', 'Chinese', 'Indian', 'Other (Citizen)')
ORDER BY variable, year, sex


-- Citizen vs Non-Citizen 

WITH cte_overall as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM ethnicity
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median, 
	((median-previous_median)/previous_median)*100 as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_overall
WHERE variable <> 'Overall' AND sex = 'overall' AND variable IN('Citizen', 'Non-Citizen')
ORDER BY variable, year



-- CERTIFICATION

-- Overall

WITH cte_certification as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM certification
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_certification
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY variable, year


-- Latest Overall

WITH cte_certification as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM certification
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_certification
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY CASE
		WHEN variable = 'No certificate/Not applicable' THEN 1
		WHEN variable = 'SPM and below' THEN 2
		WHEN variable = 'STPM/Certificate ' THEN 3
		WHEN variable = 'Diploma' THEN 4
		WHEN variable = 'Degree' THEN 5
	END, year


-- Percentage change accross different certification

WITH cte_certification as 
(SELECT variable, year, sex, median, lag(median) over (partition by year order by CASE
		WHEN variable = 'No certificate/Not applicable' THEN 1
		WHEN variable = 'SPM and below' THEN 2
		WHEN variable = 'STPM/Certificate ' THEN 3
		WHEN variable = 'Diploma' THEN 4
		WHEN variable = 'Degree' THEN 5
	END) as previous_median
FROM certification
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_diff
FROM cte_certification
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY year,
	CASE
		WHEN variable = 'No certificate/Not applicable' THEN 1
		WHEN variable = 'SPM and below' THEN 2
		WHEN variable = 'STPM/Certificate ' THEN 3
		WHEN variable = 'Diploma' THEN 4
		WHEN variable = 'Degree' THEN 5
	END


-- Combining Both

WITH cte_certification as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median, lag(median) over (partition by year order by CASE
		WHEN variable = 'No certificate/Not applicable' THEN 1
		WHEN variable = 'SPM and below' THEN 2
		WHEN variable = 'STPM/Certificate ' THEN 3
		WHEN variable = 'Diploma' THEN 4
		WHEN variable = 'Degree' THEN 5
	END) as previous_certchange
FROM certification
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_certchange)/previous_certchange), 'P') as percent_change_by_cert,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change_by_year,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
	
FROM cte_certification
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY year, CASE
		WHEN variable = 'No certificate/Not applicable' THEN 1
		WHEN variable = 'SPM and below' THEN 2
		WHEN variable = 'STPM/Certificate ' THEN 3
		WHEN variable = 'Diploma' THEN 4
		WHEN variable = 'Degree' THEN 5
	END



-- Male vs Female

WITH cte_genderc as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex) as previous_median
FROM certification
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_genderc
WHERE variable <> 'Overall' AND sex <> 'overall'
ORDER BY 
	CASE
		WHEN variable = 'No certificate/Not applicable' THEN 1
		WHEN variable = 'SPM and below' THEN 2
		WHEN variable = 'STPM/Certificate ' THEN 3
		WHEN variable = 'Diploma' THEN 4
		WHEN variable = 'Degree' THEN 5
	END, year, sex desc


-- STATE

-- Overall

WITH cte_state as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM state
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_state
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY variable, year


-- Male vs Female by State

WITH cte_genderstate as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex desc) as previous_median
FROM state
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_genderstate
WHERE variable <> 'Overall' AND sex <> 'overall'
ORDER BY variable, year, sex desc


-- INDUSTRY

-- Overall

WITH cte_industry as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM industry
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_industry
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY variable, year

-- Male vs Female across different industries

WITH cte_genderindustry as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex desc) as previous_median
FROM industry
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_genderindustry
WHERE variable <> 'Overall' AND sex <> 'overall'
ORDER BY variable, year, sex desc


-- SECTORS

-- Overall

WITH cte_sector as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM sector
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_sector
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY variable, year


-- Male vs Female

WITH cte_gendersector as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex desc) as previous_median
FROM sector
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_gendersector
WHERE variable <> 'Overall' AND sex <> 'overall'
ORDER BY variable, year, sex desc


-- STRATA

-- Overall

WITH cte_strata as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM strata
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_strata
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY variable, year


-- Male vs Female

WITH cte_genderstrata as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex desc) as previous_median
FROM strata
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_genderstrata
WHERE variable <> 'Overall' AND sex <> 'overall'
ORDER BY variable, year, sex desc


-- AGE

-- Overall

WITH cte_age as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable order by year) as previous_median
FROM age
WHERE variable <> 'Overall' AND sex = 'overall')

SELECT variable, year, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_age
WHERE variable <> 'Overall' AND sex = 'overall'
ORDER BY variable, year

-- Male vs Female

WITH cte_genderage as 
(SELECT variable, year, sex, median, lag(median) over (partition by variable, sex order by sex desc) as previous_median
FROM age
WHERE variable <> 'Overall' AND sex <> 'overall')

SELECT variable, year, sex, median,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_change,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over (partition by variable, sex) as avg_change_per_variable,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) over () as avg_change
FROM cte_genderage
WHERE variable <> 'Overall' AND sex <> 'overall'
ORDER BY variable, year, sex desc




-- Average salary differences between Male and Female from 2010 to 2021

WITH cte_mvf as (
SELECT sex, year, median, 
	lag(median) over (partition by year order by sex desc) as previous_median
FROM age
WHERE variable = 'Overall' AND sex <> 'Overall'
)

SELECT year, median, previous_median,
	previous_median-median as difference,
	FORMAT(((median-previous_median)/previous_median), 'P') as percent_difference,
	AVG(ISNULL(((median-previous_median)/previous_median)*100, 0)) OVER () avg_diff,
	AVG(previous_median-median) OVER ()
FROM cte_mvf
WHERE previous_median IS NOT NULL AND median IS NOT NULL
GROUP BY year, median, previous_median, sex
ORDER BY year, sex desc, previous_median

SELECT *
FROM age
