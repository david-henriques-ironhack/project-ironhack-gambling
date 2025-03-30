/* QUESTION 1 */
SELECT Title, firstname, lastname, dateofbirth
FROM customer;

/* QUESTION 2 */
SELECT customergroup, 
		COUNT(customergroup) AS Customer_Count
FROM customer
GROUP BY customergroup;

/*In Excel we would do the pivot table and then the column would be CustomerGroup and then we have to create a 
customize calculation with a count of CustomerGroup and to use it on the values*/

/* QUESTION 3 */
SELECT customer.*, 
		account.currencycode
FROM customer
JOIN account ON 
	customer.custid = account.custid;

/*We would use the formula =XLOOKUP(@Customer.CustId, account.CustId, account.currencycode)*/

/* QUESTION 4 */
SELECT
	p.product,
    b.betdate,
    SUM(b.bet_amt) as "bet amount"
FROM
	product p
JOIN
	betting_1 b
	ON b.classid = p.classid
	AND b.categoryid = p.categoryid
GROUP BY
	p.product,
    b.betdate
ORDER BY
	p.product DESC,
    b.betdate DESC;
    
/* QUESTION 5 */
    
    SELECT
	p.product,
    b.betdate,
    SUM(b.bet_amt) as "bet amount"
FROM
	product p
JOIN
	betting_1 b
	ON b.classid = p.classid
	AND b.categoryid = p.categoryid
WHERE
	b.betdate >= "2012-11-01" AND
    p.product = "sportsbook"
GROUP BY
	p.product,
    b.betdate
ORDER BY
	p.product DESC,
    b.betdate DESC;
    
/* QUESTION 6 */

SELECT
	g.currencycode "currency code",
    c.customergroup as "customer group",
    SUM(g.bet_amt) as "bet amount"
FROM
	customer c
JOIN
(
SELECT
	a.custid,
    b.betdate,
	b.bet_amt,
    a.currencycode
FROM account a
JOIN (
SELECT
	betdate,
	accountno,
    bet_amt
FROM
	betting_1
) b ON
a.accountno = b.accountno
) as g ON
	c.custid = g.custid
WHERE
	g.betdate >= "2012-12-01"
GROUP BY
	g.currencycode,
    c.customergroup;
    
/* QUESTION 7 */

SELECT 	
	title,
    firstname as "First name",
    lastname as "Last name",
    COALESCE(SUM(g.bet_amt),0) as "Total amount"
FROM
	customer c
LEFT JOIN (
SELECT	
	a.custid,
    b.bet_amt
FROM
	account a
JOIN
	betting_1 b ON
	a.accountno = b.accountno
) as g ON
	c.custid = g.custid
GROUP BY
	title,
    firstname,
    lastname;
    
/* QUESTION 8 */

		/*Queary 1*/
SELECT
	b.accountno as players,
	COUNT(DISTINCT p.product) as "number of products"
FROM
	product p
JOIN
	betting_1 b
	ON b.classid = p.classid
	AND b.categoryid = p.categoryid
GROUP BY
	players
ORDER BY
    COUNT(DISTINCT p.product) DESC;
    
		/*Queary 2*/

SELECT
    b.accountno AS players
FROM
    product p
JOIN
    betting_1 b
    ON b.classid = p.classid
    AND b.categoryid = p.categoryid
WHERE
    p.product IN ('Vegas', 'Sportsbook')
GROUP BY
    b.accountno
HAVING
    COUNT(DISTINCT p.product) = 2;

/* QUESTION 9 */
    
SELECT
	DISTINCT b.accountno AS players
FROM
    product p
JOIN
    betting_1 b
    ON b.classid = p.classid
    AND b.categoryid = p.categoryid
WHERE
    p.product IN ('Sportsbook') AND
    bet_amt > 0
GROUP BY
    b.accountno;

/* QUESTION 10 */

WITH bets AS (
  SELECT
    b.accountno,
    p.product,
    SUM(b.bet_amt) AS bet_amount
  FROM
    product p
  JOIN
    betting_1 b
    ON b.classid = p.classid
    AND b.categoryid = p.categoryid
  GROUP BY
    b.accountno,
    p.product
),
ranked_bets AS (
  SELECT
    a.custid,
    be.product,
    be.bet_amount,
    ROW_NUMBER() OVER (PARTITION BY a.custid ORDER BY be.bet_amount DESC) AS ranking
  FROM
    account a
  JOIN
    bets be
  ON a.accountno = be.accountno
)
SELECT
  custid,
  product,
  bet_amount
FROM
  ranked_bets
WHERE
  ranking = 1
ORDER BY
  custid,
  bet_amount DESC;
  
/* Free form analysis:*/

/* Here we see what the different groups are spending, SILVER group is the one 
with the highest average expense followed by the BONZE and GOLD who has the lowest amount*/

SELECT
	c.customergroup as "group",
    AVG(g.bet_amt) as average_spent
FROM
	customer c
JOIN (
SELECT
	a.custid,
    t.bet_amt
FROM
account a
JOIN
 (
SELECT
	accountno,
    bet_amt
FROM
	betting_1
) as t ON
a.accountno = t.accountno
) as g ON
c.custid = g.custid
GROUP BY
	c.customergroup
ORDER BY
	average_spent DESC;
 
/* Here we did the same thing but sum to check amount, and we can see that GOLD is the top one*/
 
SELECT
	c.customergroup as "group",
    SUM(g.bet_amt) as total_spent
FROM
	customer c
JOIN (
SELECT
	a.custid,
    t.bet_amt
FROM
account a
JOIN
 (
SELECT
	accountno,
    bet_amt
FROM
	betting_1
) as t ON
a.accountno = t.accountno
) as g ON
c.custid = g.custid
GROUP BY
	c.customergroup
ORDER BY
	total_spent DESC;
    
/* We can see that there is one customer with a much higher expense than the other two */
    
SELECT
	accountno,
    sum(bet_amt) as total_spent
FROM
betting_1
WHERE accountno in (
SELECT
	accountno
FROM
	account
WHERE custid in (
SELECT
	custid
FROM
	customer
WHERE
	customergroup = "GOLD"))
GROUP BY
	accountno;

 /* We can see again that a particular customer has expenses way above the rest */

SELECT
	accountno,
    sum(bet_amt) as total_spent
FROM
betting_1
WHERE accountno in (
SELECT
	accountno
FROM
	account
WHERE custid in (
SELECT
	custid
FROM
	customer
WHERE
	customergroup = "SILVER"))
GROUP BY
	accountno;
    
 /* Here as well one of the customers stands out from the other two */   
    
SELECT
	accountno,
    sum(bet_amt) as total_spent
FROM
betting_1
WHERE accountno in (
SELECT
	accountno
FROM
	account
WHERE custid in (
SELECT
	custid
FROM
	customer
WHERE
	customergroup = "BRONZE"))
GROUP BY
	accountno;
    
 /* This is the highest spender of all the casino with the biggest expenses  */    
    
 SELECT
	betdate,
    accountno,
    SUM(bet_amt) as total
FROM betting_1
WHERE accountno LIKE '%01148BP%'
GROUP BY
	betdate,
    accountno
ORDER BY
	betdate asc; 
    
 /* This BRONZE customer likes to spend on the 11th of every month in the beggining of the year and
 on the 25th on the last moths of the year*/ 

	
SELECT
	betdate,
    accountno,
    SUM(bet_amt) as total
FROM betting_1
WHERE accountno LIKE '%01284UW%'
GROUP BY
	betdate,
    accountno
ORDER BY
	betdate asc;
    
    
   /* This customer likes to spend in the Sportbook category */
   
   
SELECT
	b.betdate,
    b.accountno,
    p.product,
    SUM(b.bet_amt) AS bet_amount
  FROM
    product p
  JOIN
    betting_1 b
    ON b.classid = p.classid
    AND b.categoryid = p.categoryid
WHERE b.accountno LIKE '%01284UW%'
  GROUP BY
	b.betdate,
    b.accountno,
    p.product
ORDER BY
	b.betdate;
    
    /* The highest spender likes to play in the Vegas category and some times in the Games category */
    
SELECT
	b.betdate,
    b.accountno,
    p.product,
    SUM(b.bet_amt) AS bet_amount
  FROM
    product p
  JOIN
    betting_1 b
    ON b.classid = p.classid
    AND b.categoryid = p.categoryid
WHERE b.accountno LIKE '%00357DG%'
  GROUP BY
	b.betdate,
    b.accountno,
    p.product
ORDER BY
	b.betdate
    
    
/* We can see all of our customer and the amount that the spend*/
    
SELECT
    a.accountno AS account,
    c.customergroup AS customer_group,
    COALESCE(SUM(b.bet_amt), 0) AS total_bet
FROM
    account a
JOIN
    customer c ON a.custid = c.custid
LEFT JOIN
    betting_1 b ON a.accountno = b.accountno
GROUP BY
    a.accountno,
    c.customergroup
ORDER BY
    total_bet DESC;


    
