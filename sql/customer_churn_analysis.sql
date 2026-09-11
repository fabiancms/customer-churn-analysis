-- Active: 1788925117783@@127.0.0.1@3306
SELECT COUNT(*) AS total_customers
FROM customers;

-- ============================================================
-- 2. DATA QUALITY
-- ============================================================

-- Check missing values in key variables
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN customerID IS NULL OR TRIM(customerID) = '' THEN 1 ELSE 0 END) AS customerID_missing,
    SUM(CASE WHEN gender IS NULL OR TRIM(gender) = '' THEN 1 ELSE 0 END) AS gender_missing,
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS tenure_missing,
    SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END) AS monthlycharges_missing,
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS totalcharges_missing,
    SUM(CASE WHEN Churn IS NULL OR TRIM(Churn) = '' THEN 1 ELSE 0 END) AS churn_missing
FROM customers;


-- Investigate missing TotalCharges
SELECT
    customerID,
    tenure,
    Contract,
    MonthlyCharges,
    TotalCharges,
    Churn
FROM customers
WHERE TotalCharges IS NULL;


-- Check duplicated customers
SELECT
    customerID,
    COUNT(*) AS record_count
FROM customers
GROUP BY customerID
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. OVERALL CHURN
-- ============================================================

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM customers),
        2
    ) AS percentage
FROM customers
GROUP BY Churn;


-- ============================================================
-- 4. CHURN BY CONTRACT
-- ============================================================

SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY Contract
ORDER BY churn_rate DESC;


-- ============================================================
-- 5. CHURN BY TENURE
-- ============================================================

SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY tenure_group
ORDER BY
    CASE tenure_group
        WHEN '0-12 months' THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-48 months' THEN 3
        ELSE 4
    END;


    -- ============================================================
-- 6. CHURN BY CONTRACT + TENURE
-- ============================================================

SELECT
    Contract,
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY Contract, tenure_group
ORDER BY churn_rate DESC;


-- ============================================================
-- 7. CHURN BY INTERNET SERVICE
-- ============================================================

SELECT
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY InternetService
ORDER BY churn_rate DESC;



-- ============================================================
-- 8. CHURN BY CONTRACT + INTERNET SERVICE
-- ============================================================

SELECT
    Contract,
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY Contract, InternetService
ORDER BY churn_rate DESC;


-- ============================================================
-- 9. FINAL DATASET FOR POWER BI
-- ============================================================

DROP VIEW IF EXISTS customer_churn_final;

CREATE VIEW customer_churn_final AS
SELECT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_group,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    COALESCE(TotalCharges, 0) AS TotalCharges,
    Churn,
    CASE
        WHEN Churn = 'Yes' THEN 1
        ELSE 0
    END AS churn_flag
FROM customers;


-- ============================================================
-- 10. CHECK FINAL VIEW
-- ============================================================

SELECT *
FROM customer_churn_final
LIMIT 10;


-- ============================================================
-- 11. VALIDATE FINAL VARIABLES
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN TotalCharges = 0 THEN 1 ELSE 0 END) AS zero_total_charges,
    SUM(churn_flag) AS churned_customers,
    COUNT(*) - SUM(churn_flag) AS active_customers
FROM customer_churn_final;