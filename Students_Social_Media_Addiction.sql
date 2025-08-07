CREATE DATABASE Students_Social_Media_Addiction;

USE Students_Social_Media_Addiction;

-- 1. Descriptive Statistics

-- Q1. What is the average daily social media usage by academic level?

SELECT academic_level, ROUND(AVG(avg_daily_usage_hours), 2) AS Average_by_AcademicLevel
FROM socialmedia
GROUP BY academic_level
ORDER BY average_by_academiclevel DESC;

-- Q2. What is the average mental health score by gender?

SELECT gender, ROUND(AVG(mental_health_score), 2) AS Average_by_Gender
FROM socialmedia
GROUP BY gender
ORDER BY average_by_gender DESC;

-- Q3. Count how many students use each social media platform most frequently.

SELECT most_used_platform, COUNT(*) number_of_students
FROM socialmedia
GROUP BY most_used_platform
ORDER BY number_of_students DESC;

-- Q4. What’s the average addiction score for students who report that social media affects their academic performance?

SELECT affects_academic_performance, ROUND(AVG(addicted_score), 2) AS Average_by_Addicted_Score
FROM socialmedia
GROUP BY affects_academic_performance
ORDER BY average_by_addicted_score DESC;

-- 2. Behavioral Insights

-- Q5. What is the correlation between average daily usage and mental health score? 
--  (Use Python visualization for this, SQL for data prep)

SELECT avg_daily_usage_hours, mental_health_score
FROM socialmedia
WHERE avg_daily_usage_hours IS NOT NULL
AND mental_health_score IS NOT NULL
ORDER BY mental_health_score DESC;

--  Q6. What is the average sleep hours for students addicted (score > 7) to social media vs ---    those not addicted?

SELECT ROUND(AVG(sleep_hours_per_night), 2) AS Average_Sleep_Hours,
    CASE
        WHEN addicted_score > 7 Then 'Addicted'
        ELSE 'Not Addicted'
    END AS Addiction_Status
FROM socialmedia
GROUP BY addiction_status
ORDER BY addiction_status DESC;

-- Q7. How does relationship status influence conflicts over social media?

SELECT relationship_status, ROUND(AVG(conflicts_over_social_media), 2) AS Average_Conflict_Score, COUNT(*) AS Respondents
FROM socialmedia
GROUP BY relationship_status
ORDER BY Respondents DESC;

-- 3. Demographic Breakdown

--  Q8. Which country has the highest average addiction score?

SELECT DISTINCT country, ROUND(AVG(addicted_score),2) AS Average_addiction_Score
FROM socialmedia
GROUP BY country
ORDER BY average_addiction_score DESC;

--  Q9. Show the average mental health score by country and gender.

SELECT country, gender, ROUND(AVG(mental_health_score), 2) AS Average_Mental_Score
FROM socialmedia
GROUP BY country, gender
ORDER BY Average_Mental_Score DESC;

--  Q10. Count of students from each academic level by country.

SELECT academic_level, COUNT(*) AS Number_of_Students
FROM socialmedia
GROUP BY academic_level
ORDER BY number_of_students DESC;

-- 4. Impact Analysis

--  Q11. Compare average academic-affecting users vs non-affecting in terms of:

--  Sleep hours
--  Usage hours
--  Addiction score

SELECT affects_academic_performance, ROUND(AVG(sleep_hours_per_night), 2) AS Average_Sleep_Hours, ROUND(AVG(avg_daily_usage_hours), 2) AS Average_Daily_Usage, ROUND(AVG(addicted_score), 2) AS Average_Addicted_Score
FROM socialmedia
GROUP BY affects_academic_performance
ORDER BY average_sleep_hours, average_daily_usage, average_addicted_score;

--  Q12. For each academic level, find the percentage of students who said social media       --  affects their academics.

SELECT academic_level,
        ROUND(COUNT(CASE WHEN affects_academic_performance = 'Yes' THEN 1 END) * 100 / COUNT(*), 2) AS Affected_Percentage
FROM socialmedia
GROUP BY academic_level
ORDER BY affected_percentage DESC;

-- 5. Advanced SQL (Window Functions / Ranking)

--  Q13. Rank students within their academic level by addiction score.

SELECT 
    student_id,
    academic_level,
    addicted_score,
    RANK() OVER (PARTITION BY addicted_score ORDER BY academic_level DESC
    ) AS addiction_rank
FROM 
socialmedia;

--  Q14. For each country, find the student with the highest daily usage.

SELECT country, MAX(avg_daily_usage_hours) AS Student_Highest_Usage
FROM socialmedia
GROUP BY country
ORDER BY student_highest_usage DESC;

--  Q15. Use a window function to calculate the average addiction score within each academic --  level.

SELECT 
    student_id,
    academic_level,
    addicted_score,
    AVG(addicted_score) OVER (PARTITION BY academic_level ORDER BY academic_level DESC
    ) AS average_addiction_score_within_level
FROM 
    socialmedia;
    
--  Q16. Categorize students into "Low", "Moderate", and "High" social media users based on          Avg_Daily_Usage_Hours:

--  Low: < 3 hrs
--  Moderate: 3–6 hrs
--  High: > 6 hrs
--  Then show how these categories correlate with mental health scores.

SELECT 
    usage_category,
    COUNT(*) AS total_students,
    ROUND(AVG(avg_daily_usage_hours), 2) AS avg_daily_usage
FROM (
    SELECT 
        CASE 
            WHEN avg_daily_usage_hours < 3 THEN 'Low'
            WHEN avg_daily_usage_hours BETWEEN 3 AND 6 THEN 'Moderate'
            WHEN avg_daily_usage_hours > 6 THEN 'High'
        END AS usage_category,
        avg_daily_usage_hours
    FROM 
        socialmedia
) AS categorized
GROUP BY 
    usage_category
ORDER BY 
    total_students DESC;

