-- Bank Customer Churn Analysis



-- Tables used:
/*
•	Bank_Churn
•	Active_Customer
•	Credit_Card
•	Exit_Customer
*/


/* Queries used */


--Create The Tables 
CREATE TABLE IF NOT EXISTS bank_churn
(
	RowNumber SERIAL,
	CustomerId INTEGER PRIMARY KEY,
	Surname VARCHAR(50) NOT NULL,
	CreditScore INTEGER NOT NULL,
	Geography VARCHAR(50),
	Gender VARCHAR(50),
	Age INTEGER,
	Tenure INTEGER,
	Balance FLOAT,
	NumOfProducts INTEGER,
	HasCrCard INTEGER,
	IsActiveMember INTEGER,
	EstimatedSalary FLOAT,
	Exited INTEGER
);

COPY Bank_Churn FROM 'D:\Projects\SQL Project\Bank Churn Project\Bank_Churn.csv' with CSV HEADER;


CREATE TABLE IF NOT EXISTS active_customer
(
	IsActiveMember INTEGER,
	Active_Category VARCHAR(10) 
);

COPY Active_Customer FROM 'D:\Projects\SQL Project\Bank Churn Project\Active_Customer.csv' with CSV HEADER;

CREATE TABLE IF NOT EXISTS credit_card
(
	HasCrCard INTEGER PRIMARY KEY,
	Credit_card VARCHAR(10)
);


COPY Credit_Card FROM 'D:\Projects\SQL Project\Bank Churn Project\Credit_card.csv' with CSV HEADER;


CREATE TABLE IF NOT EXISTS exit_customer
(
	Exited INTEGER PRIMARY KEY,
	Exit_category VARCHAR(10)
);

COPY Exit_Customer FROM 'D:\Projects\SQL Project\Bank Churn Project\Exit_Customer.csv' with CSV HEADER;


--First dataset look
SELECT * FROM bank_churn;
SELECT * FROM active_customer;
SELECT * FROM credit_card;
SELECT * FROM exit_customer;


-- Database Size
SELECT pg_size_pretty(pg_database_size('Bank Customer Churn')) AS database_size;


-- Table Sizes
SELECT pg_size_pretty(pg_relation_size('bank_churn'));
SELECT pg_size_pretty(pg_relation_size('active_customer'));
SELECT pg_size_pretty(pg_relation_size('credit_card'));
SELECT pg_size_pretty(pg_relation_size('exit_customer'));


-- Row count of tables
SELECT COUNT(*) AS Row_Count FROM bank_churn;
SELECT COUNT(*) AS Row_Count FROM active_customer;
SELECT COUNT(*) AS Row_Count FROM credit_card;
SELECT COUNT(*) AS Row_Count FROM exit_customer;


-- Column count of bank_churn table
SELECT COUNT(*) AS column_Count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bank_churn';


-- Check Dataset Information of bank_churn table 
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bank_churn';


-- Get column names with data type from bank_churn table
SELECT column_name,data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='bank_churn';


-- Calculating number of null values in each column
SELECT
    COUNT(CASE WHEN RowNumber IS NULL THEN 1 END) AS RowNumber_null_count,
    COUNT(CASE WHEN CustomerId IS NULL THEN 1 END) AS CustomerId_null_count,
    COUNT(CASE WHEN Surname IS NULL THEN 1 END) AS Surname_null_count,
    COUNT(CASE WHEN CreditScore IS NULL THEN 1 END) AS CreditScore_null_count,
    COUNT(CASE WHEN Geography IS NULL THEN 1 END) AS Geography_null_count,
    COUNT(CASE WHEN Gender IS NULL THEN 1 END) AS Gender_null_count,
    COUNT(CASE WHEN Age IS NULL THEN 1 END) AS Age_null_count,
    COUNT(CASE WHEN Tenure IS NULL THEN 1 END) AS Tenure_null_count,
    COUNT(CASE WHEN Balance IS NULL THEN 1 END) AS Balance_null_count,
    COUNT(CASE WHEN NumOfProducts IS NULL THEN 1 END) AS NumOfProducts_null_count,
    COUNT(CASE WHEN HasCrCard IS NULL THEN 1 END) AS HasCrCard_null_count,
    COUNT(CASE WHEN IsActiveMember IS NULL THEN 1 END) AS IsActiveMember_null_count,
    COUNT(CASE WHEN EstimatedSalary IS NULL THEN 1 END) AS EstimatedSalary_null_count,
    COUNT(CASE WHEN Exited IS NULL THEN 1 END) AS Exited_null_count
FROM bank_churn;
/*No null value found*/


-- Dropping Unnecessary column like rownumber 
ALTER TABLE bank_churn
DROP COLUMN rownumber;

SELECT * FROM bank_churn 
LIMIT 10;
-- rownumber column removed


-- Total customers of Bank
SELECT COUNT(*) AS total_customers
FROM bank_churn;


-- Total active members
SELECT COUNT(*) AS active_customers_count FROM bank_churn
INNER JOIN active_customer
ON bank_churn.IsActiveMember = active_customer.IsActiveMember
WHERE active_customer.active_category = 'Yes';


-- Total In-active members
SELECT COUNT(*) - (SELECT COUNT(*) FROM bank_churn 
				   INNER JOIN active_customer
                   ON bank_churn.IsActiveMember = active_customer.IsActiveMember
                   WHERE active_customer.active_category = 'Yes') AS in_active_customers_count
FROM bank_churn;


-- Total credit card holders
SELECT COUNT(*) AS credit_card_holders_count FROM bank_churn
INNER JOIN credit_card
ON bank_churn.hascrcard = credit_card.hascrcard
WHERE credit_card.credit_card = 'Yes';


-- Total non-credit card holders
SELECT COUNT(*) AS non_credit_card_holders_count
FROM bank_churn
INNER JOIN credit_card
ON bank_churn.hascrcard = credit_card.hascrcard
WHERE credit_card.credit_card = 'No';


-- Total customers Exited
SELECT COUNT(*) AS customers_exited_count 
FROM bank_churn
INNER JOIN exit_customer 
ON bank_churn.exited = exit_customer.exited
WHERE exit_customer.exit_category = 'Yes';


-- Total retained customers 
SELECT COUNT(*) AS customers_retained_count
FROM bank_churn
INNER JOIN exit_customer
ON bank_churn.exited = exit_customer.exited
WHERE exit_customer.exit_category = 'No';


-- Credit score type based on credit score
SELECT creditscore,
CASE 
    WHEN creditscore >= 800 AND creditscore <= 850 THEN 'Excellent'
	WHEN creditscore >= 740 AND creditscore <= 799 THEN 'Very Good'
	WHEN creditscore >= 670 AND creditscore <= 739 THEN 'Good'
	WHEN creditscore >= 580 AND creditscore <= 669 THEN 'Fair'
	ELSE 'Poor'
END AS credit_score_type
FROM bank_churn
LIMIT 5;


-- Customer churn with respect to credit score type
SELECT 
CASE 
    WHEN creditscore >= 800 AND creditscore <= 850 THEN 'Excellent'
	WHEN creditscore >= 740 AND creditscore <= 799 THEN 'Very Good'
	WHEN creditscore >= 670 AND creditscore <= 739 THEN 'Good'
	WHEN creditscore >= 580 AND creditscore <= 669 THEN 'Fair'
	ELSE 'Poor'
END AS credit_score_type,COUNT(CustomerId)AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer
ON bank_churn.Exited = exit_customer.Exited
WHERE exit_customer.exit_category = 'Yes'
GROUP BY credit_score_type
ORDER BY exit_customer_count DESC;
/* This shows that the customers who have Fair and poor credit score type are more prone to exit bank and 
the customer who have credit score type as Excellent are least expected to exit the bank. */


-- Customer churn with respect to whether the customer is an active member or not
SELECT Active_Category, COUNT(CustomerId)AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer ON bank_churn.Exited = exit_customer.Exited
INNER JOIN active_customer ON bank_churn.IsActiveMember = active_customer.IsActiveMember
WHERE exit_customer.exit_category = 'Yes'
GROUP BY Active_Category
ORDER BY exit_customer_count DESC;
/* This shows that the customers who are inactive have higher chance to exit bank than the ones who are active. */ 


-- Customer churn with respect to HasCrCard
SELECT credit_card,COUNT(customerId) AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer ON bank_churn.Exited = exit_customer.Exited
INNER JOIN credit_card ON bank_churn.HasCrCard = credit_card.HasCrCard
WHERE exit_customer.exit_category = 'Yes'
GROUP BY credit_card
ORDER BY exit_customer_count DESC;
/* Customers who have credit card are more likely to exit bank as compared to who don't have credit card. */


-- Customer churn with respect to Geography
SELECT geography,count(customerId) AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer 
ON bank_churn.exited = exit_customer.exited
WHERE exit_customer.exit_category= 'Yes'
GROUP BY geography
ORDER BY exit_customer_count DESC;
/* Customers from Germany and France are most likely to exit the bank. */


-- Customer churn with respect to Number of products
SELECT NumOfProducts,COUNT(customerId) AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer 
ON bank_churn.Exited = exit_customer.Exited
WHERE exit_customer.exit_category = 'Yes'
GROUP BY NumOfProducts
ORDER BY exit_customer_count DESC;
/* Customers who avail only 1 product are most likely to exit the bank. */


-- Customer churn with respect to Tenure
SELECT Tenure,COUNT(customerId) AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer 
ON bank_churn.Exited = exit_customer.Exited
WHERE exit_customer.exit_category = 'Yes'
GROUP BY Tenure
ORDER BY exit_customer_count DESC
LIMIT 5;
/* Customers who have a tenure of 1 year are most likely to exit the bank. */


-- Customer churn with respect to age group
WITH CTE_1 AS
(
	SELECT *,
CASE 
    WHEN age >= 18 AND age <= 20 THEN '18-20'
	WHEN age >= 21 AND age <= 30 THEN '21-30'
	WHEN age >= 31 AND age <= 40 THEN '31-40'
	WHEN age >= 41 AND age <= 50 THEN '41-50'
	WHEN age >= 51 AND age <= 60 THEN '51-60'
	ELSE '>60'
END AS age_group
FROM bank_churn
)

SELECT age_group,COUNT(CustomerId)AS exit_customer_count
FROM CTE_1
INNER JOIN exit_customer
ON CTE_1.Exited = exit_customer.Exited
WHERE exit_customer.exit_category = 'Yes'
GROUP BY age_group
ORDER BY exit_customer_count DESC;
/* Customers in the age group of 41-50 are most likely to exit the bank. */


-- Customer churn with respect to balance group
WITH CTE_1 AS
(
	SELECT *,
CASE 
    WHEN balance >= 0 AND balance <= 100000 THEN '0-100000'
	WHEN balance >= 100001 AND balance <= 150000 THEN '100000-150000'
	WHEN balance >= 150001 AND balance <= 200000 THEN '150001-200000'
	WHEN balance >= 200001 AND balance <= 250000 THEN '200001-250000'
	ELSE '>250000'
END AS balance_group
FROM bank_churn
)
,CTE_2 AS 
(
SELECT balance_group,COUNT(CustomerId)AS exit_customer_count,
	DENSE_RANK() OVER(ORDER BY COUNT(CustomerId) DESC) AS rank
FROM CTE_1
INNER JOIN exit_customer
ON CTE_1.Exited = exit_customer.Exited
WHERE exit_customer.exit_category = 'Yes'
GROUP BY balance_group
)

SELECT balance_group, exit_customer_count
FROM CTE_2
WHERE rank = 1;
/* Customers in the balance group 100000-150000 are most likely to exit the bank. */


-- Customer churn with respect to Gender
SELECT Gender,COUNT(customerId) AS exit_customer_count
FROM bank_churn
INNER JOIN exit_customer 
ON bank_churn.Exited = exit_customer.Exited
WHERE exit_customer.exit_category = 'Yes'
GROUP BY Gender
ORDER BY exit_customer_count DESC;
/* Female customers are more likely to exit the bank in comparison to male customers. */


/* Since Female customers are having more tendency to exit the bank, so now studying the effect of other parameters
on the female customers churn */

-- Effect of Geography leading to Female customers churn
CREATE EXTENSION tablefunc;

SELECT Gender,France,Germany,Spain
FROM CROSSTAB('SELECT Gender 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM Bank_churn 
    			INNER JOIN exit_customer
                ON Bank_churn.Exited = exit_customer.Exited
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY Gender,Geography
    			ORDER BY Gender,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(Gender VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female Customers who are from France are most likely to exit bank. */


-- Effect of credit score type and Geography leading to female customers churn
CREATE TEMPORARY TABLE credit_score AS
(SELECT *,
CASE 
    WHEN creditscore >= 800 AND creditscore <= 850 THEN 'Excellent'
	WHEN creditscore >= 740 AND creditscore <= 799 THEN 'Very Good'
	WHEN creditscore >= 670 AND creditscore <= 739 THEN 'Good'
	WHEN creditscore >= 580 AND creditscore <= 669 THEN 'Fair'
	ELSE 'Poor'
END AS credit_score_type
FROM bank_churn);

SELECT credit_score_type,France,Germany,Spain
FROM CROSSTAB('SELECT credit_score_type 
			, Geography
			, COUNT(customerId) as exit_customer_count
			FROM credit_score 
			INNER JOIN exit_customer
			ON credit_score.Exited = exit_customer.Exited
			WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
			GROUP BY credit_score_type,Geography
			ORDER BY credit_score_type,Geography',
		'VALUES (''France''), (''Germany''), (''Spain'')')
AS final_result(credit_score_type VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female Customers having Fair credit score type and who are from Germany are most likely to exit bank. */


-- Effect of age group and Geography leading to Female customers churn
CREATE TEMPORARY TABLE age_table AS
(	SELECT *,
CASE 
    WHEN age >= 18 AND age <= 20 THEN '18-20'
	WHEN age >= 21 AND age <= 30 THEN '21-30'
	WHEN age >= 31 AND age <= 40 THEN '31-40'
	WHEN age >= 41 AND age <= 50 THEN '41-50'
	WHEN age >= 51 AND age <= 60 THEN '51-60'
	ELSE '>60'
END AS age_group
FROM bank_churn
 );
 
SELECT age_group
, COALESCE(France, 0) AS France
, COALESCE(Germany, 0) AS Germany
, COALESCE(Spain, 0) AS Spain
FROM CROSSTAB('SELECT age_group 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM age_table 
    			INNER JOIN exit_customer
                ON age_table.Exited = exit_customer.Exited
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY age_group,Geography
				ORDER BY age_group,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(age_group VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female customers in the age group of 41-50 who are from Germany are most likely to exit bank. */


-- Effect of Tenure and Geography leading to Female customers churn
SELECT Tenure
, COALESCE(France, 0) AS France
, COALESCE(Germany, 0) AS Germany
, COALESCE(Spain, 0) AS Spain
FROM CROSSTAB('SELECT Tenure 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM bank_churn 
    			INNER JOIN exit_customer
                ON bank_churn.Exited = exit_customer.Exited
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY Tenure,Geography
				ORDER BY Tenure,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(Tenure VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female customers with a tenure of 1 year and who are from Germany are most likely to exit bank. */


-- Effect of number of products and Geography leading to Female customers churn
SELECT NumOfProducts,France,Germany,Spain
	FROM CROSSTAB('SELECT NumOfProducts 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM bank_churn 
    			INNER JOIN exit_customer
                ON bank_churn.Exited = exit_customer.Exited
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY NumOfProducts,Geography
				ORDER BY NumOfProducts,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(NumOfProducts VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female customers with a number of products as 1 and who are from Germany are most likely to exit bank. */


-- Effect of having credit card and Geography leading to Female customers churn
SELECT Credit_card,France,Germany,Spain
	FROM CROSSTAB('SELECT Credit_card 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM bank_churn 
    			INNER JOIN exit_customer ON bank_churn.Exited = exit_customer.Exited
				INNER JOIN credit_card ON bank_churn.HasCrCard = credit_card.HasCrCard
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY Credit_card,Geography
				ORDER BY Credit_card,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(Credit_card VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female customers with credit card and who are from France and Germany are most likely to exit bank. */


-- Effect of active customer status and Geography leading to Female customers churn
SELECT Active_Category,France,Germany,Spain
	FROM CROSSTAB('SELECT Active_Category 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM bank_churn 
    			INNER JOIN exit_customer ON bank_churn.Exited = exit_customer.Exited
				INNER JOIN active_customer ON bank_churn.IsActiveMember = active_customer.IsActiveMember
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY Active_Category,Geography
				ORDER BY Active_Category,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(Active_Category VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female customers who are not active members and who are from France and Germany are most likely to exit bank. */


-- Effect of balance group and Geography leading to Female customers churn
CREATE TEMPORARY TABLE balance_table AS
(	SELECT *,
CASE 
    WHEN balance >= 0 AND balance <= 100000 THEN '0-100000'
	WHEN balance >= 100001 AND balance <= 150000 THEN '100000-150000'
	WHEN balance >= 150001 AND balance <= 200000 THEN '150001-200000'
	WHEN balance >= 200001 AND balance <= 250000 THEN '200001-250000'
	ELSE '>250000'
END AS balance_group
FROM bank_churn
 );
 
SELECT balance_group
, COALESCE(France, 0) AS France
, COALESCE(Germany, 0) AS Germany
, COALESCE(Spain, 0) AS Spain
FROM CROSSTAB('SELECT balance_group 
    			, Geography
    			, COUNT(customerId) as exit_customer_count
    			FROM balance_table 
    			INNER JOIN exit_customer
                ON balance_table.Exited = exit_customer.Exited
                WHERE exit_customer.exit_category = ''Yes'' AND gender = ''Female''
    			GROUP BY balance_group,Geography
				ORDER BY balance_group,Geography',
            'VALUES (''France''), (''Germany''), (''Spain'')')
    AS final_result(balance_group VARCHAR, France BIGINT, Germany BIGINT, Spain BIGINT);
/* Female customers with account balance between 100000 and 150000 and who are from Germany are most likely to exit bank. */




 




