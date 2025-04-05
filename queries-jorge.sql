USE ih_gambling

-- **Question 01**:  Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers.

SELECT `Title`, `FirstName`, `LastName`, `DateOfBirth`
FROM customer


-- **Question 02**:  Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). I can see by visual inspection that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this?

SELECT `CustomerGroup`, COUNT(`CustId`)
FROM customer
GROUP BY `CustomerGroup`


-- **Question 03**: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table.

SELECT * 
FROM customer
LEFT JOIN account
ON  account.`CustId` = customer.`CustId`


-- **Question 04**: Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. Please note that the transactions are stored in the betting table and there is a product code in that table  that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report. 

-- modify the data from DD/MM/YYYY to YYYY-MM-DD before converting to Date type
UPDATE betting
SET `BetDate` = STR_TO_DATE(`BetDate`, '%d/%m/%Y');

-- converting to Date type
ALTER TABLE betting
MODIFY COLUMN `BetDate` DATE;

SELECT `BetDate`, product.`ClassId`, product.`CategoryId`, SUM(`Bet_Amt`) AS `total_amount`
FROM betting
JOIN product
ON betting.`ClassId` = product.`ClassId`
GROUP BY product.`ClassId`, product.`CategoryId`, `BetDate`
ORDER BY `BetDate` ASC


-- **Question 05**: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions.

SELECT `BetDate`, product.`ClassId`, product.`CategoryId`, product.`Product`, SUM(`Bet_Amt`) AS `total_amount`
FROM betting
JOIN product
ON betting.`ClassId` = product.`ClassId`
WHERE (`BetDate` >= "2012-11-01") AND (product.`Product` = "Sportsbook")
GROUP BY product.`ClassId`, product.`CategoryId`, product.`Product`, `BetDate` 
ORDER BY `BetDate` ASC


-- **Question 06**: As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December.

SELECT account.`CurrencyCode`, customer.`CustomerGroup`, product.`Product`, SUM(betting.`Bet_Amt`) AS `total_amount`
FROM betting
JOIN product
ON betting.`ClassId` = product.`ClassId`
JOIN account
ON betting.`AccountNo` = account.`AccountNo`
JOIN customer
ON account.`CustId` = customer.`CustId`
WHERE (`BetDate` >= "2012-12-01")
GROUP BY account.`CurrencyCode`, customer.`CustomerGroup`, product.`Product`
ORDER BY account.`CurrencyCode`, customer.`CustomerGroup`, product.`Product`


-- **Question 07**: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November.

CREATE TEMPORARY TABLE customers_and_account_no
SELECT customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`, account.`AccountNo`
FROM customer 
JOIN account
ON customer.`CustId` = `account`.`CustId`

CREATE TEMPORARY TABLE november_betting_with_customers
SELECT `BetDate`, `Title`, `FirstName`, `LastName`, customers_and_account_no.`AccountNo`, betting.`Bet_Amt`
FROM betting
RIGHT JOIN customers_and_account_no -- RIGHT so it shows customers without bets
ON betting.`AccountNo` = customers_and_account_no.`AccountNo`
WHERE ((`BetDate` >= "2012-11-01") AND (`BetDate` <= "2012-11-30")) OR (`BetDate` IS NULL) -- including null so it shows customers without bets

SELECT `Title`, `FirstName`, `LastName`, SUM(`Bet_Amt`)
FROM november_betting_with_customers
GROUP BY `Title`, `FirstName`, `LastName`


-- **Question 08**: Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas.

-- number of products per player (customer)
SELECT customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`, COUNT(DISTINCT product.`Product`) AS count_of_products
FROM betting
LEFT JOIN product
ON product.`ClassId` = betting.`ClassId`
LEFT JOIN account
ON account.`AccountNo` = betting.`AccountNo`
LEFT JOIN customer
ON customer.`CustId` = account.`CustId`
GROUP BY customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`

SELECT customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`, COUNT(DISTINCT product.`Product`) AS count_of_products
FROM betting
LEFT JOIN product
ON product.`ClassId` = betting.`ClassId`
LEFT JOIN account
ON account.`AccountNo` = betting.`AccountNo`
LEFT JOIN customer
ON customer.`CustId` = account.`CustId`
WHERE (product.`Product` = "Sportsbook") OR (product.`Product` = "Vegas") 
GROUP BY customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`
HAVING COUNT(DISTINCT product.`Product`) = 2 -- this allows for a conditional based on the GROUP BY


-- **Question 09**: Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products. 

SELECT customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`, SUM(betting.`Bet_Amt`) AS total_bet
FROM betting
LEFT JOIN product
ON product.`ClassId` = betting.`ClassId`
LEFT JOIN account
ON account.`AccountNo` = betting.`AccountNo`
LEFT JOIN customer
ON customer.`CustId` = account.`CustId`
WHERE (product.`Product` = "Sportsbook") AND (betting.`Bet_Amt` > 0)
GROUP BY customer.`CustId`, customer.`Title`, customer.`FirstName`, customer.`LastName`
HAVING COUNT(DISTINCT product.`Product`) = 1 -- this allows for a conditional based on the GROUP BY


-- **Question 10**: The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked.

-- ! PENDING


