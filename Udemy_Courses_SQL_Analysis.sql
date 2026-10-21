/*
PROJECT: Udemy Courses Data Analysis
TOOLS: MySQL
SOURCE FILE: udemy.csv
ROWS: 3,678 | COLUMNS: 12

IMPORTANT:
1. Import udemy.csv into MySQL as a table named `udemy_courses`.
2. Keep column names as shown in the CSV:
   course_id, course_title, url, is_paid, price, num_subscribers,
   num_reviews, num_lectures, level, content_duration,
   published_timestamp, subject
3. `is_paid` is TRUE/FALSE in the CSV. Depending on the import wizard,
   MySQL may store it as 1/0 or text. Query 3 shows how to inspect it.
4. `published_timestamp` is stored as ISO text, e.g. 2017-01-18T20:58:58Z.
   The queries use STR_TO_DATE to parse it.
5. This script is prepared from the provided dataset structure; run it in
   your MySQL database and adjust the table name if your import uses another name.
*/

-- =========================================================
-- 1. Preview data
-- =========================================================
SELECT *
FROM udemy_courses
LIMIT 10;

-- =========================================================
-- 2. Dataset size and unique course count
-- =========================================================
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT course_id) AS unique_courses,
    COUNT(DISTINCT subject) AS total_subjects,
    COUNT(DISTINCT level) AS total_course_levels
FROM udemy_courses;

-- =========================================================
-- 3. Check paid/free values and course distribution
-- =========================================================
SELECT is_paid, COUNT(*) AS course_count
FROM udemy_courses
GROUP BY is_paid
ORDER BY course_count DESC;

-- =========================================================
-- 4. Check missing values in important columns
-- =========================================================
SELECT
    SUM(course_id IS NULL) AS missing_course_id,
    SUM(course_title IS NULL OR TRIM(course_title) = '') AS missing_course_title,
    SUM(url IS NULL OR TRIM(url) = '') AS missing_url,
    SUM(is_paid IS NULL) AS missing_is_paid,
    SUM(price IS NULL) AS missing_price,
    SUM(num_subscribers IS NULL) AS missing_subscribers,
    SUM(num_reviews IS NULL) AS missing_reviews,
    SUM(num_lectures IS NULL) AS missing_lectures,
    SUM(level IS NULL OR TRIM(level) = '') AS missing_level,
    SUM(content_duration IS NULL) AS missing_duration,
    SUM(published_timestamp IS NULL OR TRIM(published_timestamp) = '') AS missing_published_timestamp,
    SUM(subject IS NULL OR TRIM(subject) = '') AS missing_subject
FROM udemy_courses;

-- =========================================================
-- 5. Overall KPIs
-- =========================================================
SELECT
    COUNT(*) AS total_courses,
    SUM(CASE WHEN is_paid IN (1, '1', 'TRUE', 'True', 'true') THEN 1 ELSE 0 END) AS paid_courses,
    SUM(CASE WHEN is_paid IN (0, '0', 'FALSE', 'False', 'false') THEN 1 ELSE 0 END) AS free_courses,
    ROUND(AVG(price), 2) AS avg_listed_price,
    ROUND(AVG(num_subscribers), 2) AS avg_subscribers_per_course,
    SUM(num_subscribers) AS total_subscriber_count_across_courses,
    SUM(num_reviews) AS total_reviews,
    ROUND(AVG(content_duration), 2) AS avg_duration_hours,
    ROUND(AVG(num_lectures), 2) AS avg_lectures
FROM udemy_courses;

-- =========================================================
-- 6. Courses by subject
-- =========================================================
SELECT
    subject,
    COUNT(*) AS total_courses,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers,
    SUM(num_subscribers) AS total_subscriber_count,
    SUM(num_reviews) AS total_reviews,
    ROUND(AVG(content_duration), 2) AS avg_duration_hours
FROM udemy_courses
GROUP BY subject
ORDER BY total_courses DESC;

-- =========================================================
-- 7. Paid vs free courses by subject
-- =========================================================
SELECT
    subject,
    SUM(CASE WHEN is_paid IN (1, '1', 'TRUE', 'True', 'true') THEN 1 ELSE 0 END) AS paid_courses,
    SUM(CASE WHEN is_paid IN (0, '0', 'FALSE', 'False', 'false') THEN 1 ELSE 0 END) AS free_courses,
    COUNT(*) AS total_courses
FROM udemy_courses
GROUP BY subject
ORDER BY total_courses DESC;

-- =========================================================
-- 8. Course level distribution
-- =========================================================
SELECT
    level,
    COUNT(*) AS total_courses,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM udemy_courses), 2) AS percentage_of_courses,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers
FROM udemy_courses
GROUP BY level
ORDER BY total_courses DESC;

-- =========================================================
-- 9. Top 10 courses by subscribers
-- =========================================================
SELECT course_id, course_title, subject, level, price, num_subscribers, num_reviews
FROM udemy_courses
ORDER BY num_subscribers DESC
LIMIT 10;

-- =========================================================
-- 10. Top 10 courses by reviews
-- =========================================================
SELECT course_id, course_title, subject, price, num_reviews, num_subscribers
FROM udemy_courses
ORDER BY num_reviews DESC
LIMIT 10;

-- =========================================================
-- 11. Highest-priced courses
-- =========================================================
SELECT course_id, course_title, subject, level, price, num_subscribers
FROM udemy_courses
ORDER BY price DESC, num_subscribers DESC
LIMIT 10;

-- =========================================================
-- 12. Free courses with the most subscribers
-- =========================================================
SELECT course_id, course_title, subject, num_subscribers, num_reviews
FROM udemy_courses
WHERE is_paid IN (0, '0', 'FALSE', 'False', 'false')
ORDER BY num_subscribers DESC
LIMIT 10;

-- =========================================================
-- 13. Paid courses with the most subscribers
-- =========================================================
SELECT course_id, course_title, subject, price, num_subscribers, num_reviews
FROM udemy_courses
WHERE is_paid IN (1, '1', 'TRUE', 'True', 'true')
ORDER BY num_subscribers DESC
LIMIT 10;

-- =========================================================
-- 14. Price band analysis
-- =========================================================
SELECT
    CASE
        WHEN price = 0 THEN 'Free'
        WHEN price BETWEEN 1 AND 25 THEN '$1-$25'
        WHEN price BETWEEN 26 AND 50 THEN '$26-$50'
        WHEN price BETWEEN 51 AND 100 THEN '$51-$100'
        ELSE 'Above $100'
    END AS price_band,
    COUNT(*) AS total_courses,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers,
    ROUND(AVG(num_reviews), 0) AS avg_reviews
FROM udemy_courses
GROUP BY price_band
ORDER BY MIN(price);

-- =========================================================
-- 15. Subscriber performance by price
-- =========================================================
SELECT
    price,
    COUNT(*) AS total_courses,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers,
    ROUND(AVG(num_reviews), 0) AS avg_reviews
FROM udemy_courses
GROUP BY price
ORDER BY price;

-- =========================================================
-- 16. Course duration bands
-- =========================================================
SELECT
    CASE
        WHEN content_duration < 1 THEN 'Under 1 hour'
        WHEN content_duration < 3 THEN '1 to under 3 hours'
        WHEN content_duration < 6 THEN '3 to under 6 hours'
        WHEN content_duration < 10 THEN '6 to under 10 hours'
        ELSE '10+ hours'
    END AS duration_band,
    COUNT(*) AS total_courses,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers,
    ROUND(AVG(num_reviews), 0) AS avg_reviews
FROM udemy_courses
GROUP BY duration_band
ORDER BY MIN(content_duration);

-- =========================================================
-- 17. Lecture-count bands
-- =========================================================
SELECT
    CASE
        WHEN num_lectures < 10 THEN 'Under 10 lectures'
        WHEN num_lectures < 25 THEN '10-24 lectures'
        WHEN num_lectures < 50 THEN '25-49 lectures'
        ELSE '50+ lectures'
    END AS lecture_band,
    COUNT(*) AS total_courses,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers,
    ROUND(AVG(content_duration), 2) AS avg_duration_hours
FROM udemy_courses
GROUP BY lecture_band
ORDER BY MIN(num_lectures);

-- =========================================================
-- 18. Publishing trend by year
-- =========================================================
SELECT
    YEAR(STR_TO_DATE(REPLACE(published_timestamp, 'T', ' '), '%Y-%m-%d %H:%i:%sZ')) AS published_year,
    COUNT(*) AS courses_published,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers
FROM udemy_courses
WHERE STR_TO_DATE(REPLACE(published_timestamp, 'T', ' '), '%Y-%m-%d %H:%i:%sZ') IS NOT NULL
GROUP BY published_year
ORDER BY published_year;

-- =========================================================
-- 19. Monthly publishing trend
-- =========================================================
SELECT
    DATE_FORMAT(
        STR_TO_DATE(REPLACE(published_timestamp, 'T', ' '), '%Y-%m-%d %H:%i:%sZ'),
        '%Y-%m'
    ) AS published_month,
    COUNT(*) AS courses_published
FROM udemy_courses
WHERE STR_TO_DATE(REPLACE(published_timestamp, 'T', ' '), '%Y-%m-%d %H:%i:%sZ') IS NOT NULL
GROUP BY published_month
ORDER BY published_month;

-- =========================================================
-- 20. Subject and level combination
-- =========================================================
SELECT
    subject,
    level,
    COUNT(*) AS total_courses,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers
FROM udemy_courses
GROUP BY subject, level
ORDER BY subject, total_courses DESC;

-- =========================================================
-- 21. Courses with high subscribers but relatively few reviews
-- (Use as a discovery list, not a quality judgement.)
-- =========================================================
SELECT
    course_id,
    course_title,
    subject,
    num_subscribers,
    num_reviews,
    ROUND(num_reviews / NULLIF(num_subscribers, 0) * 100, 2) AS reviews_per_100_subscribers
FROM udemy_courses
WHERE num_subscribers >= 1000
ORDER BY num_subscribers DESC
LIMIT 25;

-- =========================================================
-- 22. Reviews per 1,000 subscribers
-- (Engagement proxy; not a course rating.)
-- =========================================================
SELECT
    subject,
    ROUND(SUM(num_reviews) / NULLIF(SUM(num_subscribers), 0) * 1000, 2) AS reviews_per_1000_subscribers,
    SUM(num_reviews) AS total_reviews,
    SUM(num_subscribers) AS total_subscriber_count
FROM udemy_courses
GROUP BY subject
ORDER BY reviews_per_1000_subscribers DESC;

-- =========================================================
-- 23. Courses with zero subscribers
-- =========================================================
SELECT course_id, course_title, subject, price, published_timestamp
FROM udemy_courses
WHERE num_subscribers = 0
ORDER BY published_timestamp DESC;

-- =========================================================
-- 24. Duplicate course IDs (expected to return no rows)
-- =========================================================
SELECT course_id, COUNT(*) AS duplicate_count
FROM udemy_courses
GROUP BY course_id
HAVING COUNT(*) > 1;

-- =========================================================
-- 25. Dashboard-ready subject summary
-- =========================================================
SELECT
    subject,
    COUNT(*) AS total_courses,
    SUM(CASE WHEN is_paid IN (1, '1', 'TRUE', 'True', 'true') THEN 1 ELSE 0 END) AS paid_courses,
    SUM(CASE WHEN is_paid IN (0, '0', 'FALSE', 'False', 'false') THEN 1 ELSE 0 END) AS free_courses,
    ROUND(AVG(price), 2) AS avg_price,
    SUM(num_subscribers) AS total_subscriber_count,
    SUM(num_reviews) AS total_reviews,
    ROUND(AVG(content_duration), 2) AS avg_duration_hours
FROM udemy_courses
GROUP BY subject
ORDER BY total_subscriber_count DESC;

-- =========================================================
-- 26. Dashboard-ready level summary
-- =========================================================
SELECT
    level,
    COUNT(*) AS total_courses,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(num_subscribers), 0) AS avg_subscribers,
    ROUND(AVG(num_reviews), 0) AS avg_reviews,
    ROUND(AVG(content_duration), 2) AS avg_duration_hours
FROM udemy_courses
GROUP BY level
ORDER BY total_courses DESC;
