create database Credit_card;



use Credit_card;
1. Create cc_detail table

CREATE TABLE cc_detail (
    Client_Num INT,
    Card_Category VARCHAR(20),
    Annual_Fees INT,
    Activation_30_Days INT,
    Customer_Acq_Cost INT,
    Week_Start_Date DATE,
    Week_Num VARCHAR(20),
    Qtr VARCHAR(10),
    current_year INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Ct INT,
    Avg_Utilization_Ratio DECIMAL(10,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(10,3),
    Delinquent_Acc VARCHAR(5)
);

2. Create cc_detail table

CREATE TABLE cust_detail (
    Client_Num INT,
    Customer_Age INT,
    Gender VARCHAR(5),
    Dependent_Count INT,
    Education_Level VARCHAR(50),
    Marital_Status VARCHAR(20),
    State_cd VARCHAR(50),
    Zipcode VARCHAR(20),
    Car_Owner VARCHAR(5),
    House_Owner VARCHAR(5),
    Personal_Loan VARCHAR(5),
    Contact VARCHAR(50),
    Customer_Job VARCHAR(50),
    Income INT,
    Cust_Satisfaction_Score INT
);

-- Revenue by Education Level
SELECT 
    c.Education_Level,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    c.Education_Level
ORDER BY 
    Revenue DESC;


-- Revenue by Dependent Count
SELECT 
    c.Dependent_Count,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    c.Dependent_Count
ORDER BY 
    Revenue DESC;


-- Revenue by Income Group
SELECT 
    CASE 
        WHEN c.Income < 30000 THEN 'Low Income (<30K)'
        WHEN c.Income BETWEEN 30000 AND 70000 THEN 'Middle Income (30K-70K)'
        WHEN c.Income > 70000 THEN 'High Income (>70K)'
    END AS Income_Group,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    Income_Group
ORDER BY 
    Revenue DESC;


-- Revenue by State
SELECT 
    c.State_cd,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    c.State_cd
ORDER BY 
    Revenue DESC;


-- Revenue by Age Group
SELECT 
    CASE 
        WHEN c.Customer_Age < 25 THEN 'Under 25'
        WHEN c.Customer_Age BETWEEN 25 AND 40 THEN '25-40'
        WHEN c.Customer_Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE 'Above 60'
    END AS Age_Group,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    Age_Group
ORDER BY 
    Revenue DESC;


-- Revenue by Year
SELECT 
    d.current_year,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cc_detail d
GROUP BY 
    d.current_year
ORDER BY 
    d.current_year;


-- Revenue by Month
SELECT 
    EXTRACT(MONTH FROM d.Week_Start_Date) AS Month,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cc_detail d
GROUP BY 
    EXTRACT(MONTH FROM d.Week_Start_Date)
ORDER BY 
    Month;


-- Revenue by Gender
SELECT 
    c.Gender,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    c.Gender
ORDER BY 
    Revenue DESC;


-- Revenue by Customer Job
SELECT 
    c.Customer_Job,
    SUM(d.Annual_Fees + d.Total_Trans_Amt + d.Interest_Earned) AS Revenue
FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num
GROUP BY 
    c.Customer_Job
ORDER BY 
    Revenue DESC;


-- Week-over-Week Revenue Growth
WITH weekly_revenue AS (
    SELECT 
        Week_Start_Date,
        SUM(Annual_Fees + Total_Trans_Amt + Interest_Earned) AS Revenue
    FROM 
        cc_detail
    GROUP BY 
        Week_Start_Date
),
revenue_with_lag AS (
    SELECT 
        Week_Start_Date,
        Revenue,
        LAG(Revenue) OVER (ORDER BY Week_Start_Date) AS Prev_Week_Revenue
    FROM 
        weekly_revenue
)
SELECT 
    Week_Start_Date,
    Revenue,
    Prev_Week_Revenue,
    ROUND(
        CASE 
            WHEN Prev_Week_Revenue = 0 THEN NULL
            ELSE ((Revenue - Prev_Week_Revenue) / Prev_Week_Revenue) * 100
        END, 2
    ) AS WoW_Growth_Percentage
FROM 
    revenue_with_lag
ORDER BY 
    Week_Start_Date;


-- customer group uses credit cards
SELECT 
    c.Education_Level,
    
    CASE 
        WHEN c.Customer_Age < 25 THEN 'Under 25'
        WHEN c.Customer_Age BETWEEN 25 AND 40 THEN '25-40'
        WHEN c.Customer_Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE 'Above 60'
    END AS Age_Group,

    c.Customer_Job,

    CASE 
        WHEN c.Income < 30000 THEN 'Low Income (<30K)'
        WHEN c.Income BETWEEN 30000 AND 70000 THEN 'Middle Income (30K-70K)'
        ELSE 'High Income (>70K)'
    END AS Income_Group,

    COUNT(d.Client_Num) AS Total_Users,
    SUM(d.Total_Trans_Ct) AS Total_Transactions,
    SUM(d.Total_Trans_Amt) AS Total_Spend

FROM 
    cust_detail c
JOIN 
    cc_detail d ON c.Client_Num = d.Client_Num

GROUP BY 
    c.Education_Level,
    Age_Group,
    c.Customer_Job,
    Income_Group

ORDER BY 
    Total_Spend DESC;

