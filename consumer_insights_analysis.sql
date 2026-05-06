-- ================================================
-- Consumer Insights & Donor Behavior Analysis
-- Author: Mit Mehta | MSMRA @ MSU Eli Broad
-- Dataset: Charity Donations & Consumer Behavior
-- ================================================

-- ================================================
-- SECTION 1: DONOR SEGMENTATION
-- ================================================

-- Q1: How many donors fall into each donation frequency segment?
SELECT 
    CASE 
        WHEN donation_count = 1 THEN 'One-time Donor'
        WHEN donation_count BETWEEN 2 AND 5 THEN 'Occasional Donor'
        WHEN donation_count > 5 THEN 'Loyal Donor'
    END AS donor_segment,
    COUNT(*) AS total_donors,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT donor_id, COUNT(*) AS donation_count
    FROM donations
    GROUP BY donor_id
) donor_counts
GROUP BY donor_segment
ORDER BY total_donors DESC;


-- Q2: What is the average donation amount by segment?
SELECT 
    CASE 
        WHEN donation_count = 1 THEN 'One-time Donor'
        WHEN donation_count BETWEEN 2 AND 5 THEN 'Occasional Donor'
        WHEN donation_count > 5 THEN 'Loyal Donor'
    END AS donor_segment,
    ROUND(AVG(total_donated), 2) AS avg_donation,
    ROUND(SUM(total_donated), 2) AS total_revenue,
    COUNT(*) AS donor_count
FROM (
    SELECT 
        donor_id,
        COUNT(*) AS donation_count,
        SUM(amount) AS total_donated
    FROM donations
    GROUP BY donor_id
) donor_summary
GROUP BY donor_segment
ORDER BY avg_donation DESC;


-- Q3: Which income brackets contribute the most total donations?
SELECT 
    income_bracket,
    COUNT(DISTINCT donor_id) AS unique_donors,
    ROUND(SUM(amount), 2) AS total_donated,
    ROUND(AVG(amount), 2) AS avg_donation,
    ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER(), 2) AS pct_of_total
FROM donations d
JOIN donors dem ON d.donor_id = dem.donor_id
GROUP BY income_bracket
ORDER BY total_donated DESC;


-- ================================================
-- SECTION 2: DONOR RETENTION & REPEAT BEHAVIOR
-- ================================================

-- Q4: What is the overall donor retention rate?
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN donation_count > 1 THEN donor_id END) * 100.0 
        / COUNT(DISTINCT donor_id), 2
    ) AS retention_rate_pct,
    COUNT(DISTINCT CASE WHEN donation_count > 1 THEN donor_id END) AS repeat_donors,
    COUNT(DISTINCT donor_id) AS total_donors
FROM (
    SELECT donor_id, COUNT(*) AS donation_count
    FROM donations
    GROUP BY donor_id
) donor_counts;


-- Q5: What is the average time between donations for repeat donors?
SELECT
    donor_id,
    COUNT(*) AS total_donations,
    MIN(donation_date) AS first_donation,
    MAX(donation_date) AS last_donation,
    ROUND(
        DATEDIFF(MAX(donation_date), MIN(donation_date)) / (COUNT(*) - 1), 0
    ) AS avg_days_between_donations
FROM donations
GROUP BY donor_id
HAVING COUNT(*) > 1
ORDER BY avg_days_between_donations ASC
LIMIT 20;


-- Q6: Cohort analysis — retention by first donation year
SELECT
    first_donation_year,
    COUNT(DISTINCT donor_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN returned = 1 THEN donor_id END) AS retained_donors,
    ROUND(
        COUNT(DISTINCT CASE WHEN returned = 1 THEN donor_id END) * 100.0 
        / COUNT(DISTINCT donor_id), 2
    ) AS retention_rate
FROM (
    SELECT
        donor_id,
        YEAR(MIN(donation_date)) AS first_donation_year,
        CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END AS returned
    FROM donations
    GROUP BY donor_id
) cohort_data
GROUP BY first_donation_year
ORDER BY first_donation_year;


-- ================================================
-- SECTION 3: CHANNEL & CAMPAIGN PERFORMANCE
-- ================================================

-- Q7: Which acquisition channel drives the most donors?
SELECT
    acquisition_channel,
    COUNT(DISTINCT donor_id) AS total_donors,
    ROUND(SUM(amount), 2) AS total_donated,
    ROUND(AVG(amount), 2) AS avg_donation,
    RANK() OVER(ORDER BY SUM(amount) DESC) AS revenue_rank
FROM donations d
JOIN donors dem ON d.donor_id = dem.donor_id
GROUP BY acquisition_channel
ORDER BY total_donated DESC;


-- Q8: What is the conversion rate by campaign type?
SELECT
    campaign_type,
    COUNT(*) AS total_contacts,
    SUM(converted) AS total_conversions,
    ROUND(SUM(converted) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN converted = 1 THEN amount END), 2) AS avg_converted_donation
FROM campaigns
GROUP BY campaign_type
ORDER BY conversion_rate_pct DESC;


-- ================================================
-- SECTION 4: GEOGRAPHIC & DEMOGRAPHIC INSIGHTS
-- ================================================

-- Q9: Which regions have the highest donor concentration?
SELECT
    region,
    COUNT(DISTINCT donor_id) AS total_donors,
    ROUND(SUM(amount), 2) AS total_donated,
    ROUND(AVG(amount), 2) AS avg_donation,
    ROUND(COUNT(DISTINCT donor_id) * 100.0 / SUM(COUNT(DISTINCT donor_id)) OVER(), 2) AS pct_of_donors
FROM donations d
JOIN donors dem ON d.donor_id = dem.donor_id
GROUP BY region
ORDER BY total_donors DESC;


-- Q10: Gender breakdown of donor behavior
SELECT
    gender,
    COUNT(DISTINCT donor_id) AS total_donors,
    ROUND(AVG(amount), 2) AS avg_donation,
    ROUND(SUM(amount), 2) AS total_donated,
    ROUND(
        COUNT(DISTINCT CASE WHEN donation_count > 1 THEN d.donor_id END) * 100.0 
        / COUNT(DISTINCT d.donor_id), 2
    ) AS repeat_donor_rate
FROM donations d
JOIN donors dem ON d.donor_id = dem.donor_id
JOIN (
    SELECT donor_id, COUNT(*) AS donation_count
    FROM donations
    GROUP BY donor_id
) dc ON d.donor_id = dc.donor_id
GROUP BY gender
ORDER BY total_donated DESC;


-- ================================================
-- SECTION 5: ADVANCED WINDOW FUNCTIONS
-- ================================================

-- Q11: Running total of donations over time
SELECT
    donation_date,
    amount,
    SUM(amount) OVER(ORDER BY donation_date) AS running_total,
    AVG(amount) OVER(ORDER BY donation_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 7_day_avg
FROM donations
ORDER BY donation_date;


-- Q12: Rank donors by total contribution within each region
SELECT
    region,
    donor_id,
    total_donated,
    RANK() OVER(PARTITION BY region ORDER BY total_donated DESC) AS regional_rank,
    NTILE(4) OVER(PARTITION BY region ORDER BY total_donated DESC) AS quartile
FROM (
    SELECT
        dem.region,
        d.donor_id,
        SUM(d.amount) AS total_donated
    FROM donations d
    JOIN donors dem ON d.donor_id = dem.donor_id
    GROUP BY dem.region, d.donor_id
) regional_summary
ORDER BY region, regional_rank
LIMIT 50;
