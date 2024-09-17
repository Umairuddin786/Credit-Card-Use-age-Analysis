create database if not exists Credit_Card;
CREATE TABLE customer (
    Client_Num varchar(150) PRIMARY KEY,
    Customer_Age INT,
    Gender varCHAR(50),
    Dependent_Count INT,
    Education_Level VARCHAR(50),
    Marital_Status VARCHAR(50),
    state_cd varCHAR(50),
    Zipcode int,
    Car_Owner varCHAR(50),
    House_Owner varCHAR(50),
    Personal_loan varCHAR(50),
    contact VARCHAR(50),
    Customer_Job VARCHAR(50),
    Income int,
    Cust_Satisfaction_Score INT
);

CREATE TABLE credit_card (
    Client_Num varchar(150),
    Card_Category VARCHAR(50),
    Annual_Fees int,
    Activation_30_Days INT,
    Customer_Acq_Cost int,
    Week_Start_Date DATE,
    Week_Num VARCHAR(50),
    Qtr VARCHAR(50),
    current_year year,
    Credit_Limit int,
    Total_Revolving_Bal int,
    Total_Trans_Amt int,
    Total_Trans_Vol INT,
    Avg_Utilization_Ratio DECIMAL(5, 3),
    Use_Chip VARCHAR(50),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(15, 2),
    Delinquent_Acc INT,
    FOREIGN KEY (Client_Num) REFERENCES customer(Client_Num)
    
);
# Credit Card Useage Analysis 
# Kpis

#1. Revenue
select 
      sum(Annual_Fees+
      Total_Trans_Amt+
      Interest_Earned) as Total_Revenue
from credit_card;

# 2. Interest
select
      sum(interest_Earned) as Interest
from credit_card;

# 3. Amount
select 
       sum(total_Trans_amt) as Transaction_Amount
from credit_card;

# 4. Weekly revenue
with Weekly_Revenue as (
select
      week(week_Start_Date) as Week,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card
group by week(Week_Start_Date)
),
Revenue_Growth as (
select
     week,
     Total_revenue,
     lag(total_revenue,1) over (order by week) as Previous_Week_Revenue
from weekly_Revenue)
select
     week,
     total_Revenue,
     Previous_Week_Revenue,
     round(((Total_Revenue - Previous_week_Revenue) / previous_week_Revenue) * 100,2) as WOW_Revenue
from revenue_Growth
where Previous_week_Revenue is not null
group by week
order by WOW_Revenue desc;
 
# 5. Transactions 
select sum(Total_Trans_Vol) as Total_Transactions
from credit_card;

# 6. Customers
select count(client_num) as Coustomers
from credit_card;

# 7. AVG transactions
select avg(Total_Trans_Vol) as Avg_Transactions
from credit_card;

# 8. AVG Crdit Card Limit
select avg(Credit_Limit) as Avg_Credit_Limit
from credit_card;

# 9. Income 
select sum(income) as Total_Income
from customer;

# 10. AVG Css
select avg(Cust_Satisfaction_Score) as Avg_CSS
from customer;

# A. Overview dashboard

# Revenue by gender
select 
      cu.gender,
      sum(cc.Annual_Fees+cc.Interest_Earned+cc.Total_Trans_Amt) as Gender_Revenue,
      (Select sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) 
      from credit_card) as Total_Revenue,
      round(
      (sum(cc.Annual_Fees+cc.Interest_Earned+cc.Total_Trans_Amt) /
      (Select sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) 
      from credit_card))*100,2
      ) as Percentage_Contribution
from credit_card cc
Join customer cu on cc.Client_Num = cu.Client_Num
group by cu.Gender;


# Revenue by sources
SELECT 
       Revenue_Source,
       Revenue_Amount,
       ROUND((Revenue_Amount / Total_revenue)*100,2)AS Percentage_contribution
FROM(
      SELECT
             'Annual_Fees' AS Revenue_Source,
             SUM(annual_fees) AS Revenue_Amount
		FROM credit_card
UNION ALL
       
       SELECT 
              'Interest Earned' AS Revenue_Source,
              SUM(Interest_Earned) AS Revenue_Amount
		FROM credit_card
UNION ALL
         
         SELECT
               'Total Transaction Amount' AS Revenue_Source,
               SUM(Total_Trans_Amt)
		FROM credit_card
) AS Revenue_By_Source,
      (SELECT 
              SUM(Annual_Fees + Interest_Earned+ Total_Trans_Amt) AS Total_Revenue
FROM credit_card) AS ToTAL;

# Transaction BY Month
select
      month(week_Start_Date) as Month,
      sum(Total_Trans_Vol) as Transactions
from credit_card
group by month
order by month;

# Revenue by Month
select 
	  month(week_start_date) as Month,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Revenue
from credit_card
group by month
order by revenue desc;

# Revenue Sources by Month
select
       month(week_start_date) as Month,
       sum(Annual_Fees) as Annual_Fees,
       sum(Interest_Earned) as Interest_Earned,
       sum(Total_Trans_Amt) as Transaction_Amount
from credit_card
group by month
order by Month;

# Revenue by Card
select 
       Card_Category,
       sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Revenue
from credit_card
group by Card_Category
order by revenue desc;

# Revenue by chip
select 
      Use_Chip,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Revenue
from credit_card
group by Use_Chip
order by revenue desc;

# Revenue by Income Group
WITH  Total_Revenue AS(
 SELECT
     SUM(cc.Annual_Fees+cc.Interest_Earned+cc.Total_Trans_Amt) as Total_Revenue
 From credit_card cc
 ),
Income_Group AS(
   SELECT
      CASE 
           WHEN cu.income <35000 THEN "LOW"
           WHEN cu.income >=35000 AND cu.income <70000 Then "MED"
           ELSE "High"
		END AS Income_Group,
		SUM(cc.Annual_Fees+cc.Interest_Earned+cc.Total_Trans_Amt) as Revenue_Amount 
	From credit_card cc
    
    JOIN customer cu ON cc.Client_Num = cu.Client_Num
    GROUP BY Income_Group
    )
SELECT 
       igr.income_group,
       igr.revenue_Amount,
       ROUND((igr.revenue_Amount / tr.total_revenue)*100,2) AS Percentage_Contribution
FROM 
     Income_Group igr,
     Total_Revenue tr
ORDER BY Percentage_Contribution DESC;

# Revenue by Age Group
With Age_Group as (
  select
      case
          when cu.age <30 Then "20-30"
          when cu.age >= 30 and cu.age <40 then "30-40"
          when cu.age >= 40 and cu.age <50 then "40-50"
          when cu.age >= 50 and cu.age <60 then "50_60"
          else "60+"
		End as Age_Group,
        sum(cc.Annual_Fees+cc.Interest_Earned+cc.Total_Trans_Amt) as Total_Revenue
	From credit_card cc
    Join customer cu on cc.Client_Num = cu.Client_Num
    group by Age_Group
    order by Total_Revenue DESC
    )
Select  
      age_Group,
      Total_Revenue
from age_group;

# Revenue By education
select 
      Education_level as Education,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc 
Join customer cu on cc.Client_Num = cu.Client_Num
group by education
order by total_revenue desc;

# Revenue by Customer job
select 
      Customer_job as Job_Role,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc 
join customer cu on cc.Client_Num = cu.Client_Num
group by job_Role
order by total_revenue desc;

# Revenue by Exp
select 
      EXp_Type as Expense_Type,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc
join customer cu on cc.Client_Num = cu.Client_Num
group by expense_type
order by total_revenue desc;

# QTR revenue and transaction
select
        qtr,
       sum(Total_Trans_Vol) as Transactions,
       sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Revenue
from credit_card cc
group by qtr
order by revenue desc;

# Customer Report
# Revenue by month and gender
select 
	  gender,
      Month(Week_Start_Date) as Month,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc
join customer cu on cc.Client_Num = cu.Client_Num
group by month, gender
order by month,gender;

# Revenue by Income and gender
WITH Income_Group AS(
  select
	CASE
        WHEN  cu.income <35000 THEN "low"
        WHEN  cu.income >=35000 AND cu.income <70000 THEN "Med"
        ELSE "High" 
	END AS  Income_Group,
    cu.gender,
    SUM(cc.Annual_Fees+cc.Interest_Earned+cc.Total_Trans_Amt) as Revenue_Amount
FROM credit_card cc 
JOIN customer cu ON cc.Client_Num  = cu.Client_Num
GROUP BY Income_Group,cu.gender
)
SELECT 
       Income_Group,
       gender,
       revenue_Amount
FROM income_Group
ORDER BY income_Group,gender;

# Revenue by gender and marital status
Select 
       Marital_Status,
       Gender,
       sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc 
Join customer cu on cc.Client_Num = cu.Client_Num
group by Marital_Status,gender
order by Marital_Status,Gender;
       
# Top 5 state
select
	   state_cd as State,
	   sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc 
join customer cu on cc.Client_Num = cu.Client_Num
group by State
order by Total_revenue desc
limit 5;

# Revenue by Education And Gender
select 
       education_level as Education,
       gender,
       sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc 
join customer cu on cc.Client_Num = cu.Client_Num
group by Education_Level, gender
order by Education_Level, gender;

# Revenue by job role and gender
select
      customer_Job as Job_Role,
      gender,
      sum(Annual_Fees+Interest_Earned+Total_Trans_Amt) as Total_Revenue
from credit_card cc 
join customer cu on cc.Client_Num = cu.Client_Num
group by job_role, Gender
order by job_role, Gender;

# Revenue by age group and gender
WITH Age_Group AS(
   SELECT
      CASE
           WHEN age <35 THEN "20-35"
           WHEN age >=35 AND age <40 THEN "30-40"
           WHEN age >=40 AND age <50 THEN "40-50"
           WHEN age >=50 AND age <60 THEN "50-60"
           ELSE "60+"
		END AS  Age_Group,
        cu.gender,
        SUM(CC.Annual_Fees+CC.Interest_Earned+CC.Total_Trans_Amt) as Total_Revenue
	FROM credit_card cc
    JOIN customer cu ON cc.Client_Num = cu.Client_Num
    GROUP BY Age_Group, Gender
    
    )
SELECT
       Age_group,
       Gender,
       Total_Revenue
From Age_Group
order by Age_Group,gender;
        
# Revenue by car owners 
With Total_Consumer as (
  select count(*) as Total_count
from customer
),
Car_Owners as (
select count(*) as Car_Owners_count
from customer 
where Car_Owner = 'Yes'
)
select 
       'Car Owners' as Category,
       car_owners_count as Count,
       Round((car_owners_count/total_count)*100,2) as Percentage
from car_owners,
     Total_Consumer;

# Revenue by House owners 
With Total_Consumer as (
  select count(*) as Total_count
from customer
),
House_Owners as (
select count(*) as House_Owners_count
from customer 
where House_Owner = 'Yes'
)
select 
       'House Owners' as Category,
       House_owners_count as Count,
       Round((House_owners_count/total_count)*100,2) as Percentage
from House_owners,
     Total_Consumer;
       