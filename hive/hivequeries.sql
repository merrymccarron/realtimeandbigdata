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
select lower(bill_norm), bill_period, sum(per_bill_fund) as total_spent
from bills_lobbyists_internal bills 
left join bills_count_comp comp ON bills.lcl_id = comp.lcl_id
group by bill_norm, bill_period
limit 20;

--creates a table of all bills that have been lobbied on with the total spent on them
CREATE TABLE total_spent_bills
row format delimited fields terminated by ','
STORED AS RCFile
AS
select 
  lower(regexp_replace(bill_norm, '"', '')) as bill,
  regexp_replace(bill_period, '"', '')as year,
  sum(per_bill_fund) as total_spent,
  avg(per_bill_fund) as avg_spent_bill
from bills_lobbyists_internal bills 
left join bills_count_comp comp ON bills.lcl_id = comp.lcl_id
group by bill_norm, bill_period;

--count number of bills for word
create external table words_bills (word string, bill string, year string)
row format delimited fields terminated by '\t'
location '/user/cloudera/billsHive/wordstobills';

CREATE TABLE words_bills_count 
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT word, count(*) num_of_bills
FROM words_bills
GROUP BY word
;

create external table tfidf (word string, tfidf float)
row format delimited fields terminated by '\t'
location '/user/cloudera/billsHive/tfidf';

--aggregate table with both bills cound and tfidf score per word.
CREATE TABLE words_bills_count_tfidf
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT tfidf.word, num_of_bills, tfidf
FROM tfidf
LEFT JOIN words_bills_count on (tfidf.word = words_bills_count.word)
;


CREATE TABLE spend_per_word
row format delimited fields terminated by ','
STORED as RCFile
AS
select 
  words.word, 
  round(sum(spent.total_spent),2) as total_spent_word, 
  round(avg(spent.avg_spent_bill),2) as avg_spent_word
from words_bills words
left join total_spent_bills spent on (words.bill = spent.bill and words.year = spent.year)
group by words.word
;

CREATE TABLE master_word_metrics
row format delimited fields terminated by ','
STORED as RCFile
AS
select tf.word, num_of_bills, tf.tfidf, spend.total_spent_word, spend.avg_spent_word
from words_bills_count_tfidf tf
left join spend_per_word spend on (tf.word = spend.word)
;

INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/realtimeandbigdata/outputs/hiveout' 
row format delimited fields terminated by ','
SElect * from master_word_metrics;