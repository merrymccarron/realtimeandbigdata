select bills.lcl_id, count(bills.lcl_id) as count, total_compensation
from bills_lobbyists bills
left join lob_financials lob on bills.lcl_id = lob.lcl_id
group by bills.lcl_id, total_compensation
order by count asc;

LOAD DATA INPATH 'billsHive/bills_lobbyists.csv' INTO TABLE bills_lobbyist_internal;

create table bills_lobbyists_internal (lcl_id string, bill_norm string, bill_period string, lobbyist_year string)
row format delimited fields terminated by ","
;
LOAD DATA INPATH 'bills_lobbyists.csv' INTO table bills_lobbyists_internal;

--creates the table that gets a count of the number of bills lobbyists
--report activity on per submission
CREATE TABLE bills_count_lob 
row format delimited fields terminated by ','
STORED AS RCFile
AS
select lcl_id, count(*) as count
FROM bills_lobbyists_internal
GROUP BY lcl_id
order by count asc;

-- !!!!! important and works !!!
-- gets the amount spent per bill for each lobbyist report in lob_financials
SELECT bills.lcl_id, total_compensation, count, total_compensation/count as per_bill_fund, fin.lobbyist_name
FROM bills_count_lob bills
LEFT JOIN lob_financials fin on (bills.lcl_id = fin.lcl_id);

select count(distinct lcl_id) from lob_financials where bill_numbers <> '' ;


create table lob_financials_internal (lcl_id string, client_name string, lobbyist_name string, total_compensation int)
row format delimited fields terminated by ',';

LOAD DATA INPATH 'billsHive/lobfinancials/lob_financials.csv' INTO table lob_financials_internal;

create external table lob_financials (lcl_id string, client_name string, lobbyist_name string, total_compensation int)
row format delimited fields terminated by ','
location '/user/cloudera/billsHive/lobfinancials';

-- creates a table with per bill funding for joining to the bills_lobbyists table
CREATE TABLE bills_count_comp 
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT bills.lcl_id, total_compensation, count, total_compensation/count as per_bill_fund
FROM bills_count_lob bills
LEFT JOIN lob_financials_internal fin on (bills.lcl_id = fin.lcl_id);

--this generates the idea behind this whole exercise: amt spent per bill
select lower(bill_norm), sum(per_bill_fund) as total_spent
from bills_lobbyists_internal bills 
left join bills_count_comp comp ON bills.lcl_id = comp.lcl_id
group by bill_norm
limit 20;

--creates a table of all bills that have been lobbied on with the total spent on them
CREATE TABLE total_spent_bills
row format delimited fields terminated by ','
STORED AS RCFile
AS
select lower(bill_norm), bill_period, sum(per_bill_fund) as total_spent
from bills_lobbyists_internal bills 
left join bills_count_comp comp ON bills.lcl_id = comp.lcl_id
group by bill_norm, bill_period;