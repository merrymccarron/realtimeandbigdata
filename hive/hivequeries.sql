-- hdfs commands
hadoop fs -mkdir billsHive
hadoop fs -mkdir billsHive/lobfinancials
hadoop fs -mkdir billsHive/tfidf
hadoop fs -mkdir billsHive/wordstobills
hadoop fs -mkdir billsHive/billslobbyists

hadoop fs -put tfidf.txt billsHive/tfidf
hadoop fs -put wordsToBills.txt billsHive/wordstobill
hadoop fs -put lob_financials.csv billsHive/lobfinancials
hadoop fs -put bills_lobbyists.csv billsHive/billslobbyists

-- hive queries
-- create tables from external data (exsited in the Oracle database).
CREATE EXTERNAL TABLE lob_financials (lcl_id string, client_name string, lobbyist_name string, total_compensation int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/user/cloudera/billsHive/lobfinancials';

-- bills_lobbyisys is one of our deliverables, as part of out CUSP capstone project
CREATE EXTERNAL TABLE bills_lobbyists (lcl_id string, bill_norm string, bill_period string, lobbyist_year string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/user/cloudera/billsHive/billslobbyists';

-- create tables from our 2 MapReduce final outputs
CREATE EXTERNAL TABLE tfidf (word string, tfidf float)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/billsHive/tfidf';

CREATE EXTERNAL TABLE words_bills (word string, bill string, year string)
row format delimited fields terminated by '\t'
location '/user/cloudera/billsHive/wordstobills';

--create the table that gets a count of the number of bills per lobbyist
--report activity ON per submission
CREATE TABLE bills_count_lob 
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT 
  lcl_id, 
  count(*) AS count
FROM bills_lobbyists
GROUP BY lcl_id
ORDER BY count ASC;

-- create a table with per bill funding for joining to the bills_lobbyists table
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
LEFT JOIN lob_financials fin ON (bills.lcl_id = fin.lcl_id);

--create a table of all bills that have been lobbied ON with the total spent ON them
CREATE TABLE total_spent_bills
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS RCFile
AS
SELECT 
  lower(regexp_replace(bill_norm, '"', '')) AS bill,
  regexp_replace(bill_period, '"', '')AS year,
  sum(per_bill_fund) AS total_spent
FROM bills_lobbyists bills 
LEFT JOIN bills_count_comp comp ON (bills.lcl_id = comp.lcl_id)
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

--aggregate table with both bills cound and tfidf score per word
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

--aggregate table with word and total spent on all bills including this word
CREATE TABLE spend_per_word
row format delimited fields terminated by ','
STORED AS RCFile
AS
SELECT 
  words.word, 
  round(sum(spent.total_spent),2) AS total_spent_word
FROM words_bills words
LEFT JOIN total_spent_bills spent ON (words.bill = spent.bill and words.year = spent.year)
GROUP BY words.word
;

--final master table includes for each words: 
--	1. number of bills it appeared in
--	2. total money (in USD) spent on lobbying activity
--	3. avg money spent per bill (in USD)
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

--save table into a local file to feed the visualization script
INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/realtimeandbigdata/outputs/hiveout' 
row format delimited fields terminated by ','
select * from master_word_metrics;

CREATE TABLE high_tfidf
row format delimited fields terminated by ','
STORED as RCFile
as
select *
from master_word_metrics
where tfidf > 15
and total_spent IS NOT NULL
and total_spent > 0;

INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/realtimeandbigdata/outputs/hiveout/high_tfidf' 
row format delimited fields terminated by ','
select * from high_tfidf
