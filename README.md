# Consumer Insights & Donor Behavior — SQL Analysis
### Portfolio Project | Mit Mehta | MSMRA @ MSU Eli Broad

## Overview
This project applies SQL analysis to explore consumer behavior, donor segmentation, and campaign performance — directly inspired by my market research work with NexGen Archery (n=401 survey respondents) and Archive (n≈400 consumer insights study).

The analysis answers 12 business questions across 5 areas using advanced SQL techniques including window functions, CTEs, cohort analysis, and ranking functions.

## Business Questions Answered

**Donor Segmentation**
- How do donors segment by frequency and what does each segment contribute?
- Which income brackets drive the most donation revenue?
- What is the average donation value by segment?

**Retention & Repeat Behavior**
- What is the overall donor retention rate?
- How long do repeat donors take between donations?
- How does retention vary by acquisition cohort?

**Channel & Campaign Performance**
- Which acquisition channels drive the most donors and revenue?
- Which campaign types convert at the highest rate?

**Geographic & Demographic Insights**
- Which regions have the highest donor concentration?
- How does donation behavior differ by gender?

**Advanced Analytics**
- Running totals and 7-day moving averages over time
- Regional donor ranking by quartile using window functions

## SQL Techniques Used
- Window functions — RANK(), NTILE(), SUM() OVER(), AVG() OVER()
- CTEs and subqueries
- Cohort analysis
- CASE WHEN segmentation
- Multi-table JOINs
- Aggregate functions with HAVING
- Date functions —
