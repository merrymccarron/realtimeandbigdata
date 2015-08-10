CREATE EXTERNAL TABLE lob_financials (lcl_id string, client_name string, lobbyist_name string, total_compensation int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/user/cloudera/billsHive/lobfinancials';

CREATE TABLE bills_lobbyists_internal (lcl_id string, bill_norm string, bill_period string, lobbyist_year string)
row format delimited fields terminated by ","
;
LOAD DATA INPATH 'bills_lobbyists.csv' INTO table bills_lobbyists_internal;

CREATE EXTERNAL TABLE tfidf (word string, tfidf float)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/billsHive/tfidf';

CREATE EXTERNAL TABLE words_bills (word string, bill string, year string)
row format delimited fields terminated by '\t'
location '/user/cloudera/billsHive/wordstobills';

--creates the table that gets a count of the number of bills lobbyists
--report activity ON per submission
CREATE TABLE bills_count_lob 
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT lcl_id, count(*) AS count
FROM bills_lobbyists_internal
GROUP BY lcl_id
ORDER BY count ASC;

-- !!!!! important and works !!!
-- gets the amount spent per bill for each lobbyist report in lob_financials
SELECT bills.lcl_id, total_compensation, count, total_compensation/count AS per_bill_fund, fin.lobbyist_name
FROM bills_count_lob bills
LEFT JOIN lob_financials fin ON (bills.lcl_id = fin.lcl_id);

SELECT count(distinct lcl_id) FROM lob_financials where bill_numbers <> '' ;


--this generates the idea behind this whole exercise: amt spent per bill
SELECT lower(bill_norm), bill_period, sum(per_bill_fund) AS total_spent
FROM bills_lobbyists_internal bills 
LEFT JOIN bills_count_comp comp ON bills.lcl_id = comp.lcl_id
GROUP BY bill_norm, bill_period
limit 20;

-- creates a table with per bill funding for joining to the bills_lobbyists table
CREATE TABLE bills_count_comp 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS RCFile
AS
SELECT 
  bills.lcl_id, 
  total_compensation, 
  count, 
  total_compensation/count AS per_bill_fund
FROM bills_count_lob bills
LEFT JOIN lob_financials_internal fin ON (bills.lcl_id = fin.lcl_id);



--creates a table of all bills that have been lobbied ON with the total spent ON them
CREATE TABLE total_spent_bills
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS RCFile
AS
SELECT 
  lower(regexp_replace(bill_norm, '"', '')) AS bill,
  regexp_replace(bill_period, '"', '')AS year,
  sum(per_bill_fund) AS total_spent,
  avg(per_bill_fund) AS avg_spent_bill
FROM bills_lobbyists_internal bills 
LEFT JOIN bills_count_comp comp ON bills.lcl_id = comp.lcl_id
GROUP BY bill_norm, bill_period;

--count number of bills for word



CREATE TABLE words_bills_count 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS RCFile
AS
SELECT 
  word, 
  count(*) num_of_bills
FROM words_bills
GROUP BY word
;

--aggregate table with both bills cound and tfidf score per word.
CREATE TABLE words_bills_count_tfidf
ROW FORMAT DELIMITED FIELDS TERMINATED BY','
STORED AS RCFile
AS
SELECT 
  tfidf.word, 
  num_of_bills, 
  tfidf
FROM tfidf
LEFT JOIN words_bills_count ON (tfidf.word = words_bills_count.word)
;

CREATE TABLE spend_per_word
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT 
  words.word, 
  round(sum(spent.total_spent),2) AS total_spent_word, 
FROM words_bills words
LEFT JOIN total_spent_bills spent ON (words.bill = spent.bill and words.year = spent.year)
GROUP BY words.word
;

CREATE TABLE master_word_metrics
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS RCFile
AS
SELECT 
  tf.word, 
  num_of_bills, 
  tf.tfidf, 
  spend.total_spent_word AS total_spent, 
  round(spend.total_spent_word/num_of_bills,2) AS avg_spent
FROM words_bills_count_tfidf tf
LEFT JOIN spend_per_word spend ON (tf.word = spend.word)
;

INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/realtimeandbigdata/outputs/hiveout' 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT * FROM master_word_metrics;