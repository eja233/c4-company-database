-- Sample queries for the c4 database modeling obtaining information
-- the company would potentially want to use. 

-- Get rid of previous versions of the function. 
DROP FUNCTION IF EXISTS find_discount;
DELIMITER !
-- find_discount function: takes a customer_id as input and computes
-- the discount to apply to the customer's purchase based on 
-- customer referrals in the past year. Customers receive a 5% discount
-- for every referral up to 30%. 
CREATE FUNCTION find_discount(refer_customer_id INTEGER) RETURNS INTEGER
BEGIN
    DECLARE num_referred INTEGER;
    DECLARE discount INTEGER;

    -- Find the number of customers the customer has referred in the past year.
    SELECT COUNT(customer_id) INTO num_referred
    FROM customer NATURAL JOIN referred_by
    WHERE start_date BETWEEN (CURRENT_DATE() - INTERVAL 1 YEAR) AND 
                              CURRENT_DATE()
    GROUP BY referrer_id;

    -- If the customer hasn't referred anyone, the discount is 0.
    IF num_referred = 0 THEN 
        SET discount = 0;
    
    -- If the customer has referred 6 or fewer people, then the discount
    -- is 5 times the number of people they referred. 
    ELSEIF num_referred <= 6 THEN
        SET discount = 5 * num_referred;

    -- If the customer has referred 7 or more people, their discount 
    -- maxxed out at 30. 
    ELSE 
        SET discount = 30;
    END IF;

    -- Return the discount amount.
    RETURN discount;
END !

DELIMITER ;


-- [Problem 4b]
-- Count the number of values in follow_up which have a certain
-- initial_visit_id, and select those which have at least 3 
-- values of initial_visit_id, corresponding to 3 follow-up visits. 
-- Select values from this and visit, where the number of visits is 
-- equal to this count plus 1 (for the initial visit). 
SELECT initial_visit_id, date, time, COUNT(*) + 1 AS num_visits
FROM visit JOIN follow_up ON (visit.visit_id = follow_up.initial_visit_id)
GROUP BY initial_visit_id, date, time
HAVING COUNT(*) >= 3
ORDER BY num_visits DESC;


-- [Problem 4c]
-- Find the check-up dates and follow-up dates for each customer_id and
-- join them on customer_id. Then, in four separate subqueries, select
-- the customer_ids and check-up dates for the customer_ids where
-- there is no follow-up date and the values for when
-- the follow-up date is after the check-up date,
-- and select the customer_ids and follow-up dates for the customer_ids
-- where there is no check-up date and the values for when the check-up date
-- is after the  follow-up date. Finally, select the union of these two 
-- results to get the date of the next visit for the customer_id. 
SELECT customer_id, next_visit
FROM 
    (SELECT customer_id, check_up_date AS next_visit
     FROM has_plan
     WHERE check_up_date IS NOT NULL AND customer_id NOT IN
    	(SELECT customer_id
    	FROM visited NATURAL JOIN visit
    	WHERE follow_up_date IS NOT NULL)) AS check_up_only
    UNION
    (SELECT c.customer_id, check_up_date AS next_visit
     FROM 
        (SELECT customer_id, check_up_date 
          FROM has_plan
          WHERE check_up_date IS NOT NULL) AS c
        JOIN
        (SELECT customer_id, follow_up_date
         FROM visited NATURAL JOIN visit
         WHERE follow_up_date IS NOT NULL) AS f
        ON (c.customer_id = f.customer_id)
     WHERE check_up_date < follow_up_date)
    UNION
    (SELECT customer_id, follow_up_date AS next_visit
     FROM visited NATURAL JOIN visit
     WHERE follow_up_date IS NOT NULL AND customer_id NOT IN
        (SELECT customer_id 
         FROM has_plan
         WHERE check_up_date IS NOT NULL))
    UNION
    (SELECT f.customer_id, follow_up_date AS next_visit
     FROM
        (SELECT customer_id, check_up_date 
         FROM has_plan
         WHERE check_up_date IS NOT NULL) AS c
        JOIN
        (SELECT customer_id, follow_up_date
         FROM visited NATURAL JOIN visit
         WHERE follow_up_date IS NOT NULL) AS f
        ON (c.customer_id = f.customer_id)
     WHERE follow_up_date < check_up_date)
ORDER BY customer_id ASC;


-- [Problem 4d]
-- Select the customer_ids and number of visits where the plan name 
-- is 'One-Time Service Call' and there are more than three visits
-- as a subquery. Then select the customer_id and email from this table 
-- joined with customer and has_plan, where the current plan name is 
-- 'One-Time Service Call'.
SELECT customer_id, email
FROM customer NATURAL JOIN has_plan NATURAL JOIN
    (SELECT customer_id, COUNT(*) as num_visits
     FROM visited NATURAL JOIN visit NATURAL JOIN initial 
     WHERE plan_name = 'One-Time Service Call'
     GROUP BY customer_id
     HAVING COUNT(*) >= 3) AS repeat_customers
WHERE plan_name = 'One-Time Service Call';