/*
## Questions

- **Question 01**:  Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers.
- **Question 02**:  Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). I can see by visual inspection that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this?
- **Question 03**: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table.
- **Question 04**: Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. Please note that the transactions are stored in the betting table and there is a product code in that table  that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report. 
- **Question 05**: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions.
- **Question 06**: As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December.
- **Question 07**: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November.
- **Question 08**: Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas.
- **Question 09**: Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products. 
- **Question 10**: The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked. 

- **Free form analysis**: the extra mile in this project is doing an EDA to point out interesting avenues of exploration for this dataset. Where are the large pools of money? What are profitable periods? Can we segment our customers? Present a few insights that you were able to glean during your manipulation of the data.
*/
-- Add a new colum in betting that changes string into date for BetDate
USE ih_gambling;
ALTER TABLE betting ADD COLUMN BetDateNew DATE;
UPDATE betting 
SET BetDateNew = STR_TO_DATE(BetDate, '%d/%m/%Y');
ALTER TABLE betting DROP COLUMN BetDate;
ALTER TABLE betting CHANGE BetDateNew BetDate DATE;



-- Question 01
SELECT
Title,
FirstName,
LastName,
DateOfBirth
FROM customer;

-- Question 02:
WITH customer_group_count AS (
SELECT
	CustomerGroup,
	COUNT(DISTINCT CustId) AS number_of_customers
FROM customer
GROUP BY CustomerGroup
)
SELECT
	CustomerGroup,
	number_of_customers
FROM customer_group_count
ORDER BY number_of_customers DESC;

-- Question 03
SELECT
	customer.CustId,
	customer.AccountLocation,
	Title,
	FirstName,
	LastName,
	CreateDate,
	CountryCode,
	Language,
	Status,
	DateOfBirth,
	Contact,
	CustomerGroup,
	CurrencyCode,
	DailyDepositLimit,
	StakeScale,
	Sourceprod
FROM
customer
LEFT JOIN account
ON customer.CustId = account.CustId;

-- **Question 04**: Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. Please note that the transactions are stored in the betting table and there is a product code in that table  that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report. 

SELECT
	BetDate,
    product.Product,
    ROUND(SUM(Bet_Amt),2) AS MoneyBet
FROM product
LEFT JOIN betting
ON (product.ClassId = betting.ClassId AND product.CategoryId = betting.CategoryId)
GROUP BY BetDate, product
ORDER BY BetDate DESC;


-- **Question 05**: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions.
SELECT
	BetDate,
    product.Product,
    ROUND(SUM(Bet_Amt),2) AS MoneyBet
FROM product
LEFT JOIN betting
ON (product.ClassId = betting.ClassId AND product.CategoryId = betting.CategoryId)
WHERE BetDate >= '2012-11-01'
AND product.Product = 'Sportsbook'
GROUP BY BetDate, product
ORDER BY BetDate DESC;


-- **Question 06**: As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December.
SELECT
	CurrencyCode,
    CustomerGroup,
    ROUND(SUM(Bet_Amt),2) AS MoneyBet
FROM product
LEFT JOIN betting
ON (product.ClassId = betting.ClassId AND product.CategoryId = betting.CategoryId)
LEFT JOIN account
ON betting.AccountNo = account.AccountNo
LEFT JOIN customer
ON account.CustId = customer.CustId
WHERE BetDate >= '2012-12-01'
GROUP BY CurrencyCode, CustomerGroup;


-- **Question 07**: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November.
SELECT
	DATE_FORMAT(BetDate, '%Y-%m-01') AS Month,
	Title,
	FirstName,
	LastName,
	ROUND(SUM(Bet_Amt),2) AS NovBetAmt
FROM
customer
LEFT JOIN
account ON customer.CustId = account.CustId
LEFT JOIN betting
ON	account.AccountNo = betting.AccountNo
WHERE BetCount >= 0
AND BetDate BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY 1,2,3,4;

-- **Question 08**: Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas.

SELECT
customer.CustId,
COUNT(DISTINCT product.product) AS ProductCount
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
LEFT JOIN product
ON (betting.ClassId = product.ClassId AND betting.CategoryId = product.CategoryId)
GROUP BY customer.CustId
HAVING COUNT(DISTINCT product.product) > 1;


SELECT
customer.CustId,
customer.FirstName,
COUNT(DISTINCT product.product) AS ProductCount
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
LEFT JOIN product
ON (betting.ClassId = product.ClassId AND betting.CategoryId = product.CategoryId)
WHERE product.Product IN ('Vegas','Sportsbook')
GROUP BY customer.CustId
HAVING COUNT(DISTINCT product.Product) > 1;


-- **Question 09**: Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products. 

SELECT
customer.CustId,
product.Product,
ROUND(SUM(Bet_Amt),2) AS BetAmt
FROM customer
LEFT JOIN account
ON customer.CustId = account.CustId
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
LEFT JOIN product
ON (betting.ClassId = product.ClassId AND betting.CategoryId = product.CategoryId)
WHERE product.Product = 'Sportsbook'
GROUP BY customer.CustId
HAVING COUNT(DISTINCT product.Product) = 1
AND ROUND(SUM(Bet_Amt),2) > 0;


-- **Question 10**: The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked. 
USE ih_gambling;

WITH RankedBets AS (
SELECT
    account.CustId,
	product.Product,
    betting.Bet_Amt,
    ROW_NUMBER() OVER (PARTITION BY account.CustId ORDER BY betting.Bet_Amt DESC) AS rn
FROM account
LEFT JOIN betting
ON account.AccountNo = betting.AccountNo
LEFT JOIN product
ON (betting.ClassId = product.ClassId AND betting.CategoryId = product.CategoryId)
WHERE product.Product IS NOT NULL
)
SELECT
*
FROM
RankedBets
WHERE rn =1;



-- Extra Metric:
-- Customer Lifetime Value (CLV)
-- This metric gives a comprehensive view of a customer’s value to the business over time. It combines:
--  Total Bet Amount
--  Total Win Amount
--  Net Revenue (Bet - Win)
--  Number of Bets
--  Products interacted with
--  Time range of betting activity

SELECT
    c.CustId,
    c.FirstName,
    c.LastName,
    c.CustomerGroup,
    SUM(b.BetCount) AS TotalBets,
    ROUND(SUM(b.Bet_Amt),2) AS TotalBetAmount,
    ROUND(SUM(b.Win_Amt),2) AS TotalWinAmount,
    ROUND(SUM(b.Bet_Amt - b.Win_Amt),2) AS NetRevenue,
    MIN(b.BetDate) AS FirstBetDate,
    MAX(b.BetDate) AS LastBetDate,
	MAX(b.BetDate) - MIN(b.BetDate) AS Days_Active,
	TIMESTAMPDIFF(MONTH, MIN(b.BetDate), MAX(b.BetDate)) AS Months_Active,
    COUNT(DISTINCT b.Product) AS ProductsUsed
FROM customer c
JOIN account a ON c.CustId = a.CustId
JOIN betting b ON a.AccountNo = b.AccountNo
GROUP BY
c.CustId,
c.FirstName,
c.LastName,
c.CustomerGroup
ORDER BY NetRevenue DESC;


