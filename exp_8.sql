-- EXPERIMENT 8
-- Transaction Management in PostgreSQL
-- BEGIN, COMMIT, ROLLBACK, SAVEPOINT and Isolation

-- A. Create bank accounts table

CREATE TABLE bank_accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(50),
    balance NUMERIC(12, 2) CHECK (balance >= 0)
);

INSERT INTO bank_accounts
VALUES
    (101, 'Rahul', 10000.00),
    (102, 'Aman', 5000.00);

SELECT * FROM bank_accounts;

-- B. Demonstrate BEGIN and COMMIT
-- Transfer Rs. 2000 from Rahul to Aman

BEGIN;

UPDATE bank_accounts
SET balance = balance - 2000
WHERE account_id = 101;

UPDATE bank_accounts
SET balance = balance + 2000
WHERE account_id = 102;

COMMIT;

SELECT * FROM bank_accounts;

-- C. Demonstrate ROLLBACK
-- Withdraw Rs. 1000, but cancel the transaction

BEGIN;

UPDATE bank_accounts
SET balance = balance - 1000
WHERE account_id = 101;

SELECT * FROM bank_accounts;

ROLLBACK;

SELECT * FROM bank_accounts;

-- D. Demonstrate SAVEPOINT

BEGIN;

UPDATE bank_accounts
SET balance = balance - 500
WHERE account_id = 101;

SAVEPOINT sp1;

UPDATE bank_accounts
SET balance = balance - 20000
WHERE account_id = 101;

ROLLBACK TO SAVEPOINT sp1;

UPDATE bank_accounts
SET balance = balance + 500
WHERE account_id = 102;

COMMIT;

SELECT * FROM bank_accounts;

-- E. Demonstrate transaction isolation

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

SELECT * FROM bank_accounts;

COMMIT;

-- Other isolation levels:
-- READ COMMITTED
-- REPEATABLE READ
-- SERIALIZABLE

-- F. Demonstrate concurrency using TWO sessions
-- Run the Session 1 and Session 2 queries separately.

-- SESSION 1:
BEGIN;

UPDATE bank_accounts
SET balance = 9000
WHERE account_id = 101;

-- DO NOT COMMIT YET.


-- SESSION 2:
BEGIN TRANSACTION
ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM bank_accounts
WHERE account_id = 101;

COMMIT;


-- Now execute in SESSION 1:
COMMIT;


-- Run the SELECT query again in SESSION 2:
BEGIN TRANSACTION
ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM bank_accounts
WHERE account_id = 101;

COMMIT;
