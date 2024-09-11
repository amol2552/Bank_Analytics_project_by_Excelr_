create database fin1;
use fin1;
show tables;

select count(*) from finance_1;

-- we have issue_d column which have data_type as text 
-- so to convert data_type of issue_d from text to date we have used below queries

describe finance_1;
SET SQL_SAFE_UPDATES = 0;
alter table finance_1 add column issue_date date;

UPDATE finance_1
SET issue_date = STR_TO_DATE(issue_d, '%Y-%m-%d');

SELECT issue_d, issue_date FROM finance_1;
ALTER TABLE finance_1 DROP COLUMN issue_d;
ALTER TABLE finance_1 CHANGE issue_date issue_d DATE;

describe finance_1;
---------------------------------------------------------

-- Kpi 1 Year wise loan amount stat

select year(issue_d) as year,
case
    when sum(loan_amnt) >= 1000000 then concat(format(sum(loan_amnt) / 1000000,2),'M')
    else sum(loan_amnt)
    end as loan_amount
from finance_1
group by year
order by year asc;

------ year wise loan Amount stat with respect to loan status---------
select year(issue_d) as year, loan_status,
case
    when sum(loan_amnt) >= 1000000 then concat(format(sum(loan_amnt) / 1000000,2),'M')
    when sum(loan_amnt) >= 1000 then concat(format(sum(loan_amnt)/1000,2),'K')
    else sum(loan_amnt)
    end as loan_amount
from finance_1
group by year,loan_status
order by year asc;

-----------------------------------------------------------------------------

----- kpi 2 Grade subgrade wise revol balence------------------

select f1.grade as Grade, f1.sub_grade as Sub_Grade,
concat(format(sum(f2.revol_bal)/1000000,2)," M") as Revol_bal
from finance_1 as f1 join
finance_2 as f2
on f1.id = f2.id
group by Grade,Sub_grade
order by Grade asc;

--------------------------------------------------------------------------------------

------- kpi 3 total payments according to verified status of customers-----
-- with All verified status ----
select distinct verification_status from finance_1;

select f1.verification_status, concat(format(sum(f2.total_pymnt)/1000000,0)," M") as Total_payment 
from finance_1 as f1 join finance_2 as f2
on f1.id = f2.id
group by f1.verification_status;
------------------------------------------------------------

------ without source verified status -----------------

select f1.verification_status, concat(format(sum(f2.total_pymnt)/1000000,2)," M") as Total_payment 
from finance_1 as f1 join finance_2 as f2
on f1.id = f2.id
where verification_status not in ("Source verified")
group by f1.verification_status;

-------------------------------------------------------------------------------------
----- kpi 4 state wise month wise loan status----

with cte as
(select addr_state, month(issue_d) as month_n,monthname(issue_d) as month, loan_status, 
count(loan_status) as loan_count from finance_1
group by addr_state, month_n,month,loan_status 
order by addr_state)
select addr_state, month, loan_count,loan_status from cte  ;

----------------------------------------------------------------------------------------
--- converting last_pymnt_d to date datatype----

alter table finance_2 add column last_pay_d date;

UPDATE finance_2
SET last_pay_d = CASE 
				WHEN last_pymnt_d IS NOT NULL AND last_pymnt_d <> ''
				THEN STR_TO_DATE(last_pymnt_d, '%d-%m-%Y')
				ELSE NULL
END;
                
alter table finance_2 drop column last_pymnt_d;
alter table finance_2 change last_pay_d last_pymnt_d date;

describe finance_2;
select last_pymnt_d from finance_2;
 
 ----------------------------------------------
 
 -- kpi 5 Home ownership Vs last payment date stats

select year(f2.last_pymnt_d) as year,f1.home_ownership,count(f2.last_pymnt_d) as count_last_paym_d 
from finance_2 as f2
join finance_1 as f1
on f1.id=f2.id 
where f2.last_pymnt_d is not null
group by year,home_ownership
order by year desc;

------- Home_ownership with last_payment_count without others and none -------

select year(f2.last_pymnt_d) as year,f1.home_ownership,count(f2.last_pymnt_d) as count_last_paym_d 
from finance_2 as f2
join finance_1 as f1
on f1.id=f2.id 
where f2.last_pymnt_d is not null and f1.home_ownership not in ("OTHER","NONE")
group by year,home_ownership
order by year desc;

----------------------------------------------------------------------
