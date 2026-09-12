USE Bellabeat_Analysis;
GO

-- =====================================================
-- BELLABEAT CASE STUDY
-- QUESTION 1:
-- What are some trends in smart device usage?
-- =====================================================


-- 1. Overall Smart Device Usage & Activity
SELECT
    COUNT(DISTINCT Id) AS TotalUsers,
    COUNT(*) AS TotalDailyRecords,
    ROUND(AVG(CAST(TotalSteps AS FLOAT)), 0) AS AvgDailySteps,
    ROUND(AVG(CAST(TotalDistance AS FLOAT)), 2) AS AvgDailyDistance,
    ROUND(AVG(CAST(Calories AS FLOAT)), 0) AS AvgDailyCalories,
    ROUND(AVG(CAST(VeryActiveMinutes AS FLOAT)), 0) AS AvgVeryActiveMinutes,
    ROUND(AVG(CAST(FairlyActiveMinutes AS FLOAT)), 0) AS AvgFairlyActiveMinutes,
    ROUND(AVG(CAST(LightlyActiveMinutes AS FLOAT)), 0) AS AvgLightlyActiveMinutes,
    ROUND(AVG(CAST(SedentaryMinutes AS FLOAT)), 0) AS AvgSedentaryMinutes
FROM dbo.dailyActivity;



-- =====================================================
-- 2. ACTIVITY TRENDS BY DAY OF WEEK
-- =====================================================

SELECT
    DATENAME(WEEKDAY, ActivityDate) AS DayOfWeek,
    COUNT(*) AS Records,
    ROUND(AVG(CAST(TotalSteps AS FLOAT)), 0) AS AvgDailySteps,
    ROUND(AVG(CAST(TotalDistance AS FLOAT)), 2) AS AvgDailyDistance,
    ROUND(AVG(CAST(Calories AS FLOAT)), 0) AS AvgDailyCalories,
    ROUND(
        AVG(
            CAST(
                VeryActiveMinutes
                + FairlyActiveMinutes
                + LightlyActiveMinutes
                AS FLOAT
            )
        ), 0
    ) AS AvgActiveMinutes
FROM dbo.dailyActivity
GROUP BY
    DATENAME(WEEKDAY, ActivityDate),
    DATEPART(WEEKDAY, ActivityDate)
ORDER BY
    DATEPART(WEEKDAY, ActivityDate);


-- =====================================================
-- 3. HOURLY ACTIVITY TREND
-- =====================================================
SELECT
    DATEPART(HOUR, hs.ActivityHour) AS HourOfDay,
    COUNT(*) AS Records,
    ROUND(AVG(CAST(hs.StepTotal AS FLOAT)), 0) AS AvgHourlySteps,
    ROUND(AVG(CAST(hc.Calories AS FLOAT)), 0) AS AvgHourlyCalories,
    ROUND(AVG(CAST(hi.AverageIntensity AS FLOAT)), 2) AS AvgIntensity
FROM Bellabeat_Analysis.dbo.hourlySteps AS hs
INNER JOIN Bellabeat_Analysis.dbo.hourlyCalories AS hc
    ON hs.Id = hc.Id
    AND hs.ActivityHour = hc.ActivityHour
INNER JOIN Bellabeat_Analysis.dbo.hourlyIntensities AS hi
    ON hs.Id = hi.Id
    AND hs.ActivityHour = hi.ActivityHour
GROUP BY
    DATEPART(HOUR, hs.ActivityHour)
ORDER BY
    HourOfDay ASC;

-- =====================================================
-- 4. SLEEP BEHAVIOR
-- QUESTION 1:
-- What are some trends in smart device usage?
-- =====================================================

SELECT 
    Id, 
    COUNT(DISTINCT logId) AS SleepLogs, 
    COUNT(*) AS TotalSleepRecords, 
    ROUND( 
        COUNT(*) * 1.0 / COUNT(DISTINCT logId), 
        0 
    ) AS AvgMinutesPerSleepLog 
FROM [Bellabeat_Analysis].[dbo].[minuteSleep] 
GROUP BY Id 
ORDER BY AvgMinutesPerSleepLog DESC;


-- =====================================================
-- 5. USER ENGAGEMENT / TRACKING CONSISTENCY
-- QUESTION 1:
-- What are some trends in smart device usage?
-- =====================================================

SELECT
    Id,
    COUNT(*) AS DaysTracked,
    MIN(ActivityDate) AS FirstTrackedDate,
    MAX(ActivityDate) AS LastTrackedDate
FROM [Bellabeat_Analysis].[dbo].[dailyActivity]
GROUP BY Id
ORDER BY DaysTracked DESC;


-- =====================================================
-- 6. ACTIVITY VS SLEEP BEHAVIOR
-- QUESTION 1:
-- What are some trends in smart device usage?
-- =====================================================

WITH Activity AS (
    SELECT
        Id,
        AVG(CAST(TotalSteps AS FLOAT)) AS AvgDailySteps,
        AVG(CAST(Calories AS FLOAT)) AS AvgDailyCalories,
        AVG(CAST(VeryActiveMinutes AS FLOAT)) AS AvgVeryActiveMinutes,
        AVG(CAST(FairlyActiveMinutes AS FLOAT)) AS AvgFairlyActiveMinutes,
        AVG(CAST(LightlyActiveMinutes AS FLOAT)) AS AvgLightlyActiveMinutes,
        AVG(CAST(SedentaryMinutes AS FLOAT)) AS AvgSedentaryMinutes
    FROM [Bellabeat_Analysis].[dbo].[dailyActivity]
    GROUP BY Id
),
Sleep AS (
    SELECT
        Id,
        COUNT(DISTINCT logId) AS SleepLogs,
        COUNT(*) AS TotalSleepRecords
    FROM [Bellabeat_Analysis].[dbo].[minuteSleep]
    GROUP BY Id
)
SELECT
    a.Id,
    ROUND(a.AvgDailySteps, 0) AS AvgDailySteps,
    ROUND(a.AvgDailyCalories, 0) AS AvgDailyCalories,
    ROUND(a.AvgVeryActiveMinutes, 0) AS AvgVeryActiveMinutes,
    ROUND(a.AvgFairlyActiveMinutes, 0) AS AvgFairlyActiveMinutes,
    ROUND(a.AvgLightlyActiveMinutes, 0) AS AvgLightlyActiveMinutes,
    ROUND(a.AvgSedentaryMinutes, 0) AS AvgSedentaryMinutes,
    s.SleepLogs,
    s.TotalSleepRecords
FROM Activity AS a
LEFT JOIN Sleep AS s
    ON a.Id = s.Id
ORDER BY AvgDailySteps DESC;
--Smart-device features are not used consistently across all users; activity tracking is more broadly represented than sleep tracking.


-- =====================================================
-- 7. SMART DEVICE FEATURE ENGAGEMENT
-- QUESTION 1:
-- What are some trends in smart device usage?
-- =====================================================

SELECT
    COUNT(DISTINCT da.Id) AS ActivityUsers,
    COUNT(DISTINCT ms.Id) AS SleepUsers,
    COUNT(DISTINCT da.Id) - COUNT(DISTINCT ms.Id) AS ActivityOnlyUsers
FROM [Bellabeat_Analysis].[dbo].[dailyActivity] AS da
LEFT JOIN [Bellabeat_Analysis].[dbo].[minuteSleep] AS ms
    ON da.Id = ms.Id;