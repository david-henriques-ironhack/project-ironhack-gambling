
SHOW
KEYS
FROM ih_gambling.product;

ALTER TABLE ih_gambling.account
ADD PRIMARY KEY (AccountNo (10));


ALTER TABLE ih_gambling.account
ADD FOREIGN KEY (CustId(10));


SELECT *
FROM product;


ALTER TABLE ih_gambling.customer
ADD PRIMARY KEY (CustId);

ALTER TABLE ih_gambling.product
ADD PRIMARY KEY (CLASSID(20));


ALTER TABLE ih_gambling.product
RENAME COLUMN CLASSID TO ClassId;

ALTER TABLE ih_gambling.product
RENAME COLUMN CATEGORYID TO CategoryId;

ALTER TABLE ih_gambling.product
RENAME COLUMN product TO Product;

ALTER TABLE ih_gambling.product
RENAME COLUMN sub_product TO SubProduct;

ALTER TABLE ih_gambling.product
RENAME COLUMN description TO Description;

ALTER TABLE ih_gambling.product
RENAME COLUMN bet_or_play TO BetOrPlay;


SELECT
-- AccountNo,
-- `AccountNo_[0]`,
COUNT(*)
FROM
betting
WHERE AccountNo <> `AccountNo_[0]`;

SELECT
COUNT(`MyUnknownColumn_[2]`)
FROM
betting
WHERE `MyUnknownColumn_[2]` <> '' ;

ALTER TABLE ih_gambling.betting
DROP COLUMN `MyUnknownColumn_[2]`;


SELECT
COUNT(`AccountNo_[0]`)
FROM
betting
WHERE `AccountNo_[0]` <> '' ;


SELECT *
FROM betting;


ALTER TABLE ih_gambling.betting
RENAME COLUMN `AccountNo_[0]` TO AccountNo_0;

ALTER TABLE ih_gambling.betting
RENAME COLUMN `Bet_Amt_[0]` TO Bet_Amt_0;

ALTER TABLE ih_gambling.betting
RENAME COLUMN `Product_[0]` TO Product_0;

ALTER TABLE ih_gambling.betting
RENAME COLUMN `AccountNo_[1]` TO AccountNo_1;






