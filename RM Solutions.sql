/* SETUP
/* SETUP
/* SETUP

SHOW
KEYS
FROM ih_gambling.account;

ALTER TABLE ih_gambling.account
ADD PRIMARY KEY (AccountNo (10));

ALTER TABLE ih_gambling.account
ADD FOREIGN KEY (CustID(10));

SELECT *
FROM product;

ALTER TABLE ih_gambling.customer
ADD PRIMARY KEY (CustID);

ALTER TABLE ih_gambling.product
ADD PRIMARY KEY (CLASSID(20));

ALTER TABLE ih_gambling.product
RENAME COLUMN CLASSID TO ClassId;

ALTER TABLE ih_gambling.product
RENAME COLUMN CLASSID TO ClassID;
*/

/*
Question 01:
Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers. */
SELECT 
  Title, 
  FirstName, 
  LastName, 
  DateOfBirth
FROM 
  ih_gambling.customer;

/* 
Question 02:
Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). I can see by visual inspection that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this? */
SELECT 
  CustomerGroup, 
  COUNT(*) AS NumCustomers /* AS NumCustomers gives a name (alias) to the count column. */
FROM 
  ih_gambling.customer
GROUP BY 
  CustomerGroup;


/*
Question 03:
The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table. */
SELECT 
  c.*,  /* c.* means "all columns from the customer table", which we gave the alias c */
  a.CurrencyCode
FROM 
  ih_gambling.customer c
LEFT JOIN 
  ih_gambling.account a ON c.CustId = a.CustId; /* match the CustId column in both. */


/* 
Question 04:
Now I need to provide a product manager with a summary report that shows, by product and by day how much money has been bet on a particular product. Please note that the transactions are stored in the betting table and there is a product code in that table that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report. */
SELECT 
  b.BetDate,
  p.product,
  SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
  ih_gambling.betting b
JOIN 
  ih_gambling.product p 
    ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY 
  b.BetDate, p.product
ORDER BY 
  b.BetDate, p.product;

/*
Question 05:
You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarises transactions that occurred on or after 1st November and he only wants to see Sportsbook transactions. */
SELECT 
  b.BetDate,
  p.product,
  SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
  ih_gambling.betting b
JOIN 
  ih_gambling.product p 
    ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE 
  b.BetDate >= '2022-11-01'  -- ajusta si la fecha fuera distinta
  AND p.product = 'Sportsbook'
GROUP BY 
  b.BetDate, p.product
ORDER BY 
  b.BetDate;


/*
Question 06:
As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. This time, he wants the all of the products but split by the currencycode and customergroup of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December. */
SELECT 
  p.product,
  a.CurrencyCode,
  c.CustomerGroup,
  SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
  ih_gambling.betting b
JOIN 
  ih_gambling.product p 
    ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN 
  ih_gambling.account a ON b.AccountNo = a.AccountNo
JOIN 
  ih_gambling.customer c ON a.CustId = c.CustId
WHERE 
  b.BetDate > '2022-12-01'
GROUP BY 
  p.product, a.CurrencyCode, c.CustomerGroup
ORDER BY 
  p.product, a.CurrencyCode, c.CustomerGroup;


/*
Question 07:
Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players Title, First Name and Last Name and a summary of their bet amount for the complete period of November. */
SELECT 
  c.Title,
  c.FirstName,
  c.LastName,
  COALESCE(SUM(b.Bet_Amt), 0) AS TotalNovemberBet
FROM 
  ih_gambling.customer c
LEFT JOIN 
  ih_gambling.account a ON c.CustId = a.CustId
LEFT JOIN 
  ih_gambling.betting b ON a.AccountNo = b.AccountNo 
      AND b.BetDate BETWEEN '2022-11-01' AND '2022-11-30'
GROUP BY 
  c.CustId, c.Title, c.FirstName, c.LastName;



/*
Question 08:
Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas. */

/* a) Número de productos distintos jugados por cada jugador */
SELECT 
  c.CustId,
  COUNT(DISTINCT p.product) AS NumProductsPlayed
FROM 
  ih_gambling.customer c
JOIN 
  ih_gambling.account a ON c.CustId = a.CustId
JOIN 
  ih_gambling.betting b ON a.AccountNo = b.AccountNo
JOIN 
  ih_gambling.product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY 
  c.CustId;

/* b) Jugadores que jugaron tanto Sportsbook como Vegas */
SELECT 
  c.CustId
FROM 
  ih_gambling.customer c
JOIN 
  ih_gambling.account a ON c.CustId = a.CustId
JOIN 
  ih_gambling.betting b ON a.AccountNo = b.AccountNo
JOIN 
  ih_gambling.product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE 
  p.product IN ('Sportsbook', 'Vegas')
GROUP BY 
  c.CustId
HAVING 
  COUNT(DISTINCT p.product) = 2;


/*
Question 09:
Now our CRM team want to look at players who only play one product, please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products. */
SELECT 
  c.CustId,
  SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS Sportsbook_Bets,
  SUM(CASE WHEN p.product = 'Vegas' THEN b.Bet_Amt ELSE 0 END) AS Vegas_Bets
FROM 
  ih_gambling.customer c
JOIN 
  ih_gambling.account a ON c.CustId = a.CustId
JOIN 
  ih_gambling.betting b ON a.AccountNo = b.AccountNo
JOIN 
  ih_gambling.product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY 
  c.CustId
HAVING 
  Vegas_Bets = 0 AND Sportsbook_Bets > 0;


/*
Question 10:
The last question requires us to calculate and determine a player’s favourite product. This can be determined by the most money staked.
Free form analysis: the extra mile in this project is doing an EDA to point out interesting avenues of exploration for this dataset. Where are the large pools of money? What are profitable periods? Can we segment our customers? Present a few insights that you were able to glean during your manipulation of the data. */

/* Favorite product per client */
WITH BetTotals AS (
  SELECT 
    c.CustId,
    p.product,
    SUM(b.Bet_Amt) AS TotalBet
  FROM 
    ih_gambling.customer c
  JOIN 
    ih_gambling.account a ON c.CustId = a.CustId
  JOIN 
    ih_gambling.betting b ON a.AccountNo = b.AccountNo
  JOIN 
    ih_gambling.product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
  GROUP BY 
    c.CustId, p.product
),
RankedBets AS (
  SELECT 
    *,
    RANK() OVER (PARTITION BY CustId ORDER BY TotalBet DESC) AS rnk
  FROM 
    BetTotals
)
SELECT 
  CustId,
  product AS FavouriteProduct,
  TotalBet
FROM 
  RankedBets
WHERE 
  rnk = 1;
