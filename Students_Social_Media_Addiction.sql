CREATE DATABASE Students_Social_Media_Addiction_DB;

USE Students_Social_Media_Addiction_DB;

SELECT *
FROM students_social_media_addiction;

DESCRIBE students_social_media_addiction;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Student_ID INT PRIMARY KEY NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Age INT NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Gender VARCHAR(10) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Academic_Level VARCHAR(50) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Country VARCHAR(100) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Avg_Daily_Usage_Hours DOUBLE(5,2) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Most_Used_Platform VARCHAR(50) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Affects_Academic_Performance VARCHAR(10) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Sleep_Hours_Per_Night DOUBLE(5,2) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Mental_Health_Score INT NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Relationship_Status VARCHAR(50) NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Conflicts_Over_Social_Media INT NOT NULL;

ALTER TABLE students_social_media_addiction
MODIFY COLUMN Addicted_Score INT NOT NULL;

-- 1. Descriptive Statistics
-- Q.1 What is the average daily social media usage by academic level?

SELECT
	Academic_Level,
    ROUND(AVG(avg_daily_usage_hours), 2) AS Average_by_Academic_Level
FROM students_social_media_addiction
GROUP BY Academic_Level
ORDER BY Average_by_Academic_Level DESC;

-- Q.2 What is the average mental health score by gender?

SELECT 
	Gender,
    ROUND(AVG(mental_health_score), 2) AS Average_by_Gender
FROM students_social_media_addiction
GROUP BY Gender
ORDER BY Average_by_Gender DESC;

-- Q.3 Count how many students use each social media platform most frequently.

SELECT
	Most_Used_Platform,
    COUNT(*)  AS Number_of_Students
FROM students_social_media_addiction
GROUP BY Most_Used_Platform
ORDER BY Number_of_Students DESC;

-- Q.4 What is the average addiction score for students who report that social media affects their academic performance?

SELECT
	Affects_Academic_Performance,
    ROUND(AVG(addicted_score), 2) AS Average_by_Addicted_Score
FROM students_social_media_addiction
GROUP BY Affects_Academic_Performance
ORDER BY Average_by_Addicted_Score DESC; 
	
-- 2. Behavioral Insights

-- Q.5 What is the correlation between average daily usage and mental health score? 
--  (Use Python visualization for this, SQL for data prep)

--  Q.6 What is the average sleep hours for students addicted (score > 7) to social media vs those not addicted?

SELECT 
    CASE
        WHEN addicted_score > 7 THEN 'Addicted'
        ELSE 'Not Addicted'
    END AS Addiction_Status,
    ROUND(AVG(sleep_hours_per_night), 2) AS Average_Sleep_Hours
FROM students_social_media_addiction
GROUP BY 
    CASE
        WHEN addicted_score > 7 THEN 'Addicted'
        ELSE 'Not Addicted'
    END
ORDER BY Average_Sleep_Hours DESC;
			
-- Q.7 How does relationship status influence conflicts over social media?

SELECT
	Relationship_Status,
    ROUND(AVG(conflicts_over_social_media), 2) AS Average_Conflict_Score,
    COUNT(*) AS Respondents
FROM students_social_media_addiction
GROUP BY Relationship_Status
ORDER BY Respondents;

-- Demographics
-- Q.8 Which country has the highest average addiction score?

SELECT 
	Country,
    ROUND(AVG(addicted_score), 2) AS Highest_Average_Addiction_Score
FROM students_social_media_addiction
GROUP BY Country
ORDER BY Highest_Average_Addiction_Score DESC;

-- Q9. Show the average mental health score by country and gender.

SELECT 
    country,
    gender,
    mental_health_score,
    ROUND(
        AVG(mental_health_score) OVER (
            PARTITION BY country, gender
        ), 2
    ) AS Average_Mental_Score
FROM students_social_media_addiction
ORDER BY Average_Mental_Score DESC;

-- Q10. Count of students from each academic level by country.

SELECT 
    academic_level,
    country,
    Number_Of_Students,
    RANK() OVER (ORDER BY Number_Of_Students) AS student_rank
FROM (
    SELECT 
        academic_level,
        country,
        COUNT(*) AS Number_Of_Students
    FROM students_social_media_addiction
    GROUP BY academic_level, country
) t
ORDER BY Number_Of_Students;

-- 4. Impact Analysis

-- Q.11 Compare average academic-affecting users vs non-affecting in terms of:

-- Sleep Hours

-- Usage Hours

-- Addiction Score

SELECT
	affects_academic_performance,
    ROUND(AVG(sleep_hours_per_night), 2) AS Average_Sleep_Hours,
    ROUND(AVG(avg_daily_usage_hours), 2) AS Average_Daily_Usage,
    ROUND(AVG(addicted_score), 2) AS Average_Addicted_Score
FROM students_social_media_addiction
GROUP BY Affects_Academic_Performance
ORDER BY average_sleep_hours, average_daily_usage, average_addicted_score;

--  Q12. For each academic level, find the percentage of students who said social media affects their academics.

SELECT
	academic_level,
    ROUND(COUNT(CASE WHEN affects_academic_performance = 'Yes' THEN 1 END) * 100 / COUNT(*), 2) AS Affected_Percentage
FROM students_social_media_addiction
GROUP BY academic_level
ORDER BY affected_percentage DESC;

-- 5. Advanced SQL (Window Functions / Ranking)

--  Q13. Rank students within their academic level by addiction score.

SELECT 
    student_id,
    academic_level,
    addicted_score,
    RANK() OVER (
        PARTITION BY academic_level 
        ORDER BY addicted_score DESC
    ) AS addiction_rank
FROM students_social_media_addiction;

--  Q14. For each country, find the student with the highest daily usage.

SELECT
	country, 
    student_id, 
    avg_daily_usage_hours
FROM (
    SELECT 
        country,
        student_id,
        avg_daily_usage_hours,
        RANK() OVER (PARTITION BY country) AS rnk
    FROM students_social_media_addiction
) ranked
WHERE rnk = 1
ORDER BY Avg_Daily_Usage_Hours DESC;

--  Q15. Use a window function to calculate the average addiction score within each academic level.

SELECT 
    student_id,
    academic_level,
    addicted_score,
    ROUND(
		AVG(addicted_score) OVER (
			PARTITION BY academic_level), 2
    ) AS average_addiction_score_within_level
FROM students_social_media_addiction
ORDER BY Addicted_Score DESC;

--  Q16. Categorize students into "Low", "Moderate", and "High" social media users based on Avg_Daily_Usage_Hours:

--  Low: < 3 hrs
--  Moderate: 3–6 hrs
--  High: > 6 hrs
--  Then show how these categories correlate with mental health scores.

SELECT 
    usage_category,
    COUNT(*) AS total_students,
    ROUND(AVG(avg_daily_usage_hours), 2) AS avg_daily_usage,
    ROUND(AVG(mental_health_score), 2) AS avg_mental_health_score
FROM (
    SELECT 
        CASE 
            WHEN avg_daily_usage_hours < 3 THEN 'Low'
            WHEN avg_daily_usage_hours BETWEEN 3 AND 6 THEN 'Moderate'
            ELSE 'High'
        END AS usage_category,
        avg_daily_usage_hours,
        mental_health_score
    FROM students_social_media_addiction
) categorized
GROUP BY usage_category
ORDER BY total_students DESC;

