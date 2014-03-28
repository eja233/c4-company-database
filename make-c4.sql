-- make-c4: creates a database for the Creepy Crawly Critter Crushers (C4)
-- company (a fake company used as an example). Includes information
-- about C4's customers, employees, service plans, and the visits C4 has
-- made to customers.

DROP TABLE IF EXISTS referred_by;
DROP TABLE IF EXISTS sent_employee;
DROP TABLE IF EXISTS visited;
DROP TABLE IF EXISTS has_plan;
DROP TABLE IF EXISTS initial;
DROP TABLE IF EXISTS follow_up;
DROP TABLE IF EXISTS visit;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS service_plan;
DROP TABLE IF EXISTS customer;

-- customer table: stores basic contact information for customers, including
-- an automatically generated customer id. ad_value is 1 if the customer
-- wants periodic advertisements from C4, and 0 otherwise. Date is the date 
-- when C4 was first contacted for service. 
CREATE TABLE customer (
    customer_id     INTEGER      PRIMARY KEY     AUTO_INCREMENT,
    name            VARCHAR(60)  NOT NULL,
    company         VARCHAR(60),
    street          VARCHAR(60)  NOT NULL,
    city            VARCHAR(40)  NOT NULL,
    state           VARCHAR(20)  NOT NULL,
    zip_code        CHAR(9),
    phone_no        CHAR(10)     NOT NULL        UNIQUE,
    email           VARCHAR(50)  NOT NULL        UNIQUE,
    ad_value        BOOLEAN      NOT NULL,
    start_date      DATE         NOT NULL
);

-- service_plan: gives information on the different types of service plans.
-- These include the Annual Plan, Quarterly Plan, Extended Plan,
-- and the One-Time Service Call (equivalent to no plan). 
CREATE TABLE service_plan (
    plan_name     VARCHAR(25)     PRIMARY KEY,
    price         NUMERIC(4,2)    NOT NULL
);

-- employee: stores contact and administrative information for employees.
-- employee_id is an automatically generated id for each employee. 
-- start_date is the day the employee started working at the company, and
-- specialty is jobs the employee is especially good at (can be NULL).
CREATE TABLE employee (
    employee_id   INTEGER        PRIMARY KEY    AUTO_INCREMENT,
    name          VARCHAR(60)    NOT NULL,
    ssn           CHAR(9)        NOT NULL       UNIQUE,
    street        VARCHAR(60)    NOT NULL,
    city          VARCHAR(40)    NOT NULL,
    state         VARCHAR(20)    NOT NULL,
    zip_code      CHAR(9),
    phone_no      CHAR(10)       NOT NULL,
    start_date    DATE           NOT NULL,
    wage          NUMERIC(2,2)   NOT NULL,
    specialty     VARCHAR(200)    
);

-- visit: gives information about each time C4 visited a customer, including
-- a unique visit_id for each visit. reason is the reason for the visit,
-- treatment_val is 1 if a treatment was required and 0 if it wasn't,
-- pest_type is the type of pest found, pest_location is the location in the 
-- house where the pest was found, and method is the treatment used to
-- get rid of the pest. follow_up_date is the earliest date for a follow-up.
-- It can be null if no follow-up is needed. 
CREATE TABLE visit (
    visit_id       INTEGER       PRIMARY KEY    AUTO_INCREMENT,
    date           DATE          NOT NULL,
    time           TIME          NOT NULL,
    reason         VARCHAR(400)  NOT NULL,
    treatment_val  BOOLEAN       NOT NULL,
    pest_type      VARCHAR(100),
    pest_location  VARCHAR(100),
    method         VARCHAR(400),
    follow_up_date DATE
);

-- follow_up: stores information for visits that are follow ups. Includes
-- the visit_id of the follow-up visit and the visit_id of the initial 
-- visit that led to the follow up.
CREATE TABLE follow_up(
    visit_id           INTEGER     PRIMARY KEY,
    initial_visit_id   INTEGER     NOT NULL,
    FOREIGN KEY(visit_id) REFERENCES visit(visit_id),
    FOREIGN KEY(initial_visit_id) REFERENCES visit(visit_id)
);

-- initial: stores information for initial visits. Includes the plan name
-- that was in effect at the time and the price charged for the visit
-- including discounts.
CREATE TABLE initial (
    visit_id      INTEGER      PRIMARY KEY,
    plan_name     VARCHAR(25)  NOT NULL,
    price         NUMERIC(4,2) NOT NULL,
    FOREIGN KEY(visit_id) REFERENCES visit(visit_id),
    FOREIGN KEY(plan_name) REFERENCES service_plan(plan_name)
);

-- visited: gives information about which customer was involved in which visit.
CREATE TABLE visited (
    visit_id      INTEGER    PRIMARY KEY,
    customer_id   INTEGER    NOT NULL,
    FOREIGN KEY(visit_id) REFERENCES visit(visit_id),
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id)
);

-- sent_employee: gives information about which employees were sent on 
-- which visit. 
CREATE TABLE sent_employee (
    visit_id     INTEGER    NOT NULL,
    employee_id  INTEGER    NOT NULL,
    PRIMARY KEY(visit_id, employee_id),
    FOREIGN KEY(visit_id) REFERENCES visit(visit_id),
    FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
);

-- has_plan: gives information on the plan each customer has. check_up_date
-- is the date of the next checkup, which can be NULL for customers who do 
-- not have a recurring plan, and sign_up_date is the date the customer
-- signed up for the plan. Every customer must have a plan, because one
-- option for plans is the "One-Time Service Call," which is the default 
-- if customers do not sign up for a plan. 
CREATE TABLE has_plan (
    customer_id       INTEGER       PRIMARY KEY,
    plan_name         VARCHAR(25)   NOT NULL   DEFAULT 'One-Time Service Call',
    sign_up_date      DATE          NOT NULL,
    check_up_date     DATE,
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY(plan_name) REFERENCES service_plan(plan_name)
);

-- referred_by: gives details on which customer referred another customer. 
CREATE TABLE referred_by (
    customer_id     INTEGER    PRIMARY KEY,
    referrer_id     INTEGER,
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY(referrer_id) REFERENCES customer(customer_id)
);

