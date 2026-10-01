-- =========================================================
-- Credit Risk & Loan Default Analysis
-- SQL Project Script
-- Tools: PostgreSQL + Power BI
-- =========================================================
--
-- NOTE:
-- This script contains the queries used during the project.
-- The analytical logic and queries are kept unchanged.
-- =========================================================


-- =========================================================
-- 1. TABLE SETUP
-- =========================================================

DROP TABLE IF EXISTS loan_raw; 

CREATE TABLE loan_raw ( 
    application_id VARCHAR(20), 
    loan_amnt NUMERIC, 
    term INTEGER, 
    int_rate NUMERIC, 
    grade VARCHAR(5), 
    emp_length VARCHAR(20), 
    home_ownership VARCHAR(30), 
    annual_inc NUMERIC, 
    verification_status VARCHAR(30), 
    loan_status INTEGER, 
    purpose VARCHAR(50), 
    addr_state VARCHAR(5), 
    dti NUMERIC, 
    delinq_2yrs NUMERIC, 
    revol_util NUMERIC, 
    application_type VARCHAR(30), 
    fico_score NUMERIC 
); 


-- =========================================================
-- 2. DATA VALIDATION
-- =========================================================

SELECT COUNT(*) AS total_rows 
FROM loan_raw; 


SELECT *  
FROM loan_raw 
LIMIT 10; 


SELECT  
    loan_status, 
    COUNT(*) AS applications 
FROM loan_raw 
GROUP BY loan_status 
ORDER BY loan_status; 


SELECT  
    MIN(annual_inc) AS minimum_income,  
    MAX(annual_inc) AS maximum_income, 
    ROUND(AVG(annual_inc),2) AS average_income 
FROM loan_raw; 


SELECT 
    MIN(dti) AS minimum_dti, 
    MAX(dti) AS maximum_dti, 
    ROUND(AVG(dti), 2) AS average_dti 
FROM loan_raw; 


SELECT 
    MIN(fico_score) AS minimum_fico, 
    MAX(fico_score) AS maximum_fico, 
    ROUND(AVG(fico_score), 2) AS average_fico 
FROM loan_raw; 


SELECT 
    MIN(loan_amnt) AS minimum_loan, 
    MAX(loan_amnt) AS maximum_loan, 
    ROUND(AVG(loan_amnt), 2) AS average_loan 
FROM loan_raw; 


SELECT 
    COUNT(*) AS total_rows, 
    COUNT(application_id) AS application_id_present, 
    COUNT(annual_inc) AS income_present, 
    COUNT(dti) AS dti_present, 
    COUNT(fico_score) AS fico_present, 
    COUNT(loan_amnt) AS loan_amount_present, 
    COUNT(loan_status) AS status_present 
FROM loan_raw; 


SELECT  
    application_id,  
    COUNT(*) AS duplicate_id 
FROM loan_raw 
GROUP BY application_id 
HAVING COUNT(*) > 1; 


-- =========================================================
-- 3. ANALYTICAL TABLE
-- =========================================================

CREATE TABLE loan_analysis AS 
SELECT *  
FROM loan_raw; 


ALTER TABLE loan_analysis  
ADD COLUMN default_flag INTEGER; 


UPDATE loan_analysis  
SET default_flag =  
    CASE  
        WHEN loan_status = 1 THEN 1  
        ELSE 0 
    END; 


SELECT 
    loan_status, 
    default_flag, 
    COUNT(*) AS applications 
FROM loan_analysis 
GROUP BY loan_status, default_flag 
ORDER BY loan_status, default_flag; 


-- =========================================================
-- 4. FEATURE ENGINEERING
-- =========================================================

ALTER TABLE loan_analysis 
ADD COLUMN income_band VARCHAR(30); 


UPDATE loan_analysis 
SET income_band =  
    CASE 
        WHEN annual_inc < 40000 THEN 'Low income' 
        WHEN annual_inc < 80000 THEN 'Middle income' 
        WHEN annual_inc < 120000 THEN 'Upper middle income' 
        ELSE 'High income' 
    END; 


ALTER TABLE loan_analysis 
ADD COLUMN dti_band VARCHAR(30); 


UPDATE loan_analysis 
SET dti_band = 
    CASE 
        WHEN dti < 20 THEN 'Low DTI' 
        WHEN dti < 35 THEN 'Moderate DTI' 
        WHEN dti < 50 THEN 'High DTI' 
        ELSE 'Very High DTI' 
    END; 


ALTER TABLE loan_analysis 
ADD COLUMN fico_band VARCHAR(30); 


UPDATE loan_analysis 
SET fico_band = 
    CASE 
        WHEN fico_score < 580 THEN 'Very Low' 
        WHEN fico_score < 670 THEN 'Low' 
        WHEN fico_score < 740 THEN 'Good' 
        WHEN fico_score < 800 THEN 'Very Good' 
        ELSE 'Excellent' 
    END; 


-- =========================================================
-- 5. DEFAULT RATE ANALYSIS
-- =========================================================

SELECT  
    COUNT(*) AS Total_applications,  
    SUM(default_flag) AS defaulted_applications, 
    ROUND( 
        SUM(default_flag) * 100 / COUNT(*) ,2) 
    AS default_rate 
FROM loan_analysis; 


SELECT  
    income_band, 
    COUNT(*) AS Total_application, 
    SUM(default_flag) AS defaulted_applications, 
    ROUND(SUM(default_flag) * 100 / COUNT(*) ,2) AS default_rate 
FROM loan_analysis 
GROUP BY income_band  
ORDER BY default_rate DESC; 


SELECT  
    dti_band, 
    COUNT(*) AS Total_applications, 
    SUM(default_flag) AS default_applications, 
    ROUND( SUM(default_flag) * 100 / COUNT(*) , 2) AS default_rate 
FROM loan_analysis 
GROUP BY dti_band 
ORDER BY default_rate DESC; 


SELECT  
    fico_band, 
    COUNT(*) AS Total_applications, 
    SUM(default_flag) AS default_applications, 
    ROUND(SUM(default_flag) * 100 / COUNT(*)) AS default_rate 
FROM loan_analysis 
GROUP BY fico_band 
ORDER BY default_rate DESC; 


SELECT  
    emp_length,  
    COUNT(*) AS Total_applications 
FROM loan_analysis 
GROUP BY emp_length 
ORDER BY Total_applications DESC; 


SELECT  
    emp_length, 
    COUNT(*) AS Total_applications, 
    SUM(default_flag) AS default_applications, 
    ROUND(SUM(default_flag) * 100 / COUNT(*)) AS default_rate 
FROM loan_analysis 
GROUP BY emp_length 
ORDER BY default_rate DESC; 


SELECT  
    purpose, 
    COUNT(*) AS Total_applications, 
    SUM(default_flag) AS default_applications, 
    ROUND(SUM(default_flag) * 100 / COUNT(*)) AS default_rate 
FROM loan_analysis 
GROUP BY purpose 
ORDER BY default_rate DESC; 


SELECT  
    addr_state, 
    COUNT(*) AS Total_applications, 
    SUM(default_flag) AS default_applications, 
    ROUND(SUM(default_flag) * 100 / COUNT(*)) AS default_rate 
FROM loan_analysis 
GROUP BY addr_state 
ORDER BY default_rate DESC; 


-- =========================================================
-- 6. RULE-BASED RISK SCORING
-- =========================================================

ALTER TABLE loan_analysis 
ADD COLUMN risk_score INTEGER; 


UPDATE loan_analysis 
SET risk_score =  
    CASE 
        WHEN dti_band IN ('High DTI' , 'Very High DTI') THEN 2 
        WHEN dti_band = 'Moderate DTI' THEN 1 
        ELSE 0  
    END 

   +CASE 
        WHEN fico_band IN ('Very Low' , 'Low') THEN 2 
        WHEN fico_band = ('Good') THEN 1 
        ELSE 0 
    END 

   +CASE 
        WHEN income_band = 'Low income' THEN 1 
        ELSE 0 
    END 

   +CASE 
        WHEN emp_length::integer <= 1 THEN 1 
        ELSE 0  
    END; 


SELECT 
    risk_score, 
    COUNT(*) AS applications 
FROM loan_analysis 
GROUP BY risk_score 
ORDER BY risk_score; 


ALTER TABLE loan_analysis 
ADD COLUMN risk_level VARCHAR(20); 


UPDATE loan_analysis 
SET risk_level = 
    CASE 
        WHEN risk_score <= 1 THEN 'Low Risk' 
        WHEN risk_score <= 3 THEN 'Medium Risk' 
        ELSE 'High Risk' 
    END; 


SELECT 
    risk_level, 
    COUNT(*) AS applications 
FROM loan_analysis 
GROUP BY risk_level 
ORDER BY 
    CASE 
        WHEN risk_level = 'Low Risk' THEN 1 
        WHEN risk_level = 'Medium Risk' THEN 2 
        WHEN risk_level = 'High Risk' THEN 3 
    END; 


SELECT 
    risk_level, 
    COUNT(*) AS total_applications, 
    SUM(default_flag) AS defaulted_applications, 
    ROUND( 
        SUM(default_flag) * 100.0 / COUNT(*), 
        2 
    ) AS default_rate 
FROM loan_analysis 
GROUP BY risk_level 
ORDER BY 
    CASE 
        WHEN risk_level = 'High Risk' THEN 1 
        WHEN risk_level = 'Medium Risk' THEN 2 
        WHEN risk_level = 'Low Risk' THEN 3 
    END; 


-- =========================================================
-- 7. MANUAL REVIEW PRIORITIZATION
-- =========================================================

ALTER TABLE loan_analysis 
ADD COLUMN manual_review_flag VARCHAR(20); 


UPDATE loan_analysis  
SET manual_review_flag = 
    CASE 
    WHEN risk_level = 'High Risk' THEN 'Manual Review' 
    ELSE 'Standard Review' 
END 


SELECT  
    manual_review_flag, 
    COUNT(*) AS applications 
FROM loan_analysis 
GROUP BY manual_review_flag 
ORDER BY manual_review_flag; 


SELECT  
    manual_review_flag, 
    COUNT(*) AS applications, 
    SUM(default_flag) AS default_applications , 
    ROUND(SUM(default_flag) * 100 / COUNT(*) , 2) AS default_rate 
    FROM loan_analysis 
GROUP BY manual_review_flag 
ORDER BY default_rate DESC; 


-- =========================================================
-- 8. POWER BI VIEW
-- =========================================================

CREATE OR REPLACE VIEW loan_risk_powerbi AS 
SELECT 
    application_id, 
    loan_amnt, 
    term, 
    int_rate, 
    grade, 
    emp_length, 
    home_ownership, 
    annual_inc, 
    verification_status, 
    loan_status, 
    default_flag, 
    purpose, 
    addr_state, 
    dti, 
    delinq_2yrs, 
    revol_util, 
    application_type, 
    fico_score, 
    income_band, 
    dti_band, 
    fico_band, 
    risk_score, 
    risk_level, 
    manual_review_flag 
FROM loan_analysis; 


-- =========================================================
-- 9. FINAL VALIDATION
-- =========================================================

SELECT * 
FROM loan_risk_powerbi 
LIMIT 10; 


SELECT 
    COUNT(*) AS total_rows, 
    COUNT(risk_score) AS risk_score_present, 
    COUNT(risk_level) AS risk_level_present, 
    COUNT(manual_review_flag) AS manual_review_present 
FROM loan_risk_powerbi; 


SELECT 
    application_id, 
    annual_inc, 
    dti, 
    fico_score, 
    purpose, 
    addr_state, 
    income_band, 
    dti_band, 
    fico_band, 
    risk_score, 
    risk_level, 
    manual_review_flag 
FROM loan_risk_powerbi 
LIMIT 10;
