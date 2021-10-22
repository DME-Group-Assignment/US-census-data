--------------------------------------------------------------------------------------------------
-- Answers to Question 1																		--
--------------------------------------------------------------------------------------------------

drop view black_income;
CREATE VIEW black_income AS
select black_composition, income_specification, count(*) 
from census_facts cf 
inner join black_composition_dim bcd ON bcd.BcId = cf.BcId
inner join income_dim id ON  id.incomeId = cf.incomeId
group by income_specification, black_composition;

select * from black_income;

drop view white_income;
CREATE VIEW white_income AS
select white_composition, income_specification, count(*) 
from census_facts cf 
inner join white_composition_dim wcd ON wcd.WcId = cf.WcId
inner join income_dim id ON  id.incomeId = cf.incomeId
group by income_specification, white_composition;

select * from white_income;

drop view asian_income;
CREATE VIEW asian_income AS
select asian_composition, income_specification, count(*) 
from census_facts cf 
inner join asian_composition_dim acd ON acd.AcId = cf.AcId 
inner join income_dim id ON  id.incomeId = cf.incomeId
group by asian_composition, income_specification;

select * from asian_income;

drop view hispanic_income;
CREATE VIEW hispanic_income AS
select hispanic_composition, income_specification, count(*) 
from census_facts cf 
inner join hispanic_composition_dim hcd ON hcd.HcId = cf.HcId 
inner join income_dim id ON  id.incomeId = cf.incomeId
group by hispanic_composition, income_specification;

select * from hispanic_income;

--------------------------------------------------------------------------------------------------
-- Answers to Question 2																		--
--------------------------------------------------------------------------------------------------

-- nr of observations in census based on race composition and commute time (across both years)
select bcd.black_composition, cd.commute_specification, count(*) cnt
from census_facts cf, (select count(*) as cnt from census_facts cf) cf2
inner join black_composition_dim bcd ON bcd.BcId = cf.BcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
group by bcd.black_composition, cd.commute_specification
order by cnt desc;

select wcd.white_composition, cd.commute_specification, count(*) cnt
from census_facts cf, (select count(*) as cnt from census_facts cf) cf2
inner join white_composition_dim wcd ON wcd.WcId = cf.WcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
group by wcd.white_composition, cd.commute_specification
order by cnt desc;

select hcd.hispanic_composition, cd.commute_specification, count(*) cnt
from census_facts cf, (select count(*) as cnt from census_facts cf) cf2
inner join hispanic_composition_dim hcd ON hcd.HcId = cf.HcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
group by hcd.hispanic_composition, cd.commute_specification
order by cnt desc;

select acd.asian_composition, cd.commute_specification, count(*) cnt
from census_facts cf, (select count(*) as cnt from census_facts cf) cf2
inner join asian_composition_dim acd ON acd.AcId = cf.AcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
group by acd.asian_composition, cd.commute_specification
order by cnt desc;

-- nr of observations in census based on race composition and commute time (across both years) AS PERCENTAGE of total in specific race composition
select bcd.black_composition, cd.commute_specification, round((count(*) * 1.0) / c_count.comp_count * 100,2) as freq_prcnt
from census_facts cf 
inner join black_composition_dim bcd ON bcd.BcId = cf.BcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
inner join (
			select bcd.black_composition, count(*) as comp_count
			from census_facts cf
			inner join black_composition_dim bcd on bcd.BcId = cf.BcId 
			group by bcd.black_composition 
) as c_count on c_count.black_composition = bcd.black_composition 
group by bcd.black_composition, cd.commute_specification
order by bcd.black_composition, freq_prcnt desc;

select wcd.white_composition, cd.commute_specification, round((count(*) * 1.0) / c_count.comp_count * 100,2) as freq_prcnt
from census_facts cf 
inner join white_composition_dim wcd ON wcd.WcId = cf.WcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
inner join (
			select wcd.white_composition, count(*) as comp_count
			from census_facts cf
			inner join white_composition_dim wcd on wcd.WcId = cf.WcId 
			group by wcd.white_composition 
) as c_count on c_count.white_composition = wcd.white_composition 
group by wcd.white_composition, cd.commute_specification
order by wcd.white_composition, freq_prcnt desc;

select hcd.hispanic_composition, cd.commute_specification, round((count(*) * 1.0) / c_count.comp_count * 100,2) as freq_prcnt
from census_facts cf 
inner join hispanic_composition_dim hcd ON hcd.HcId = cf.HcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
inner join (
			select hcd.hispanic_composition, count(*) as comp_count
			from census_facts cf
			inner join hispanic_composition_dim hcd on hcd.HcId = cf.HcId 
			group by hcd.hispanic_composition 
) as c_count on c_count.hispanic_composition = hcd.hispanic_composition 
group by hcd.hispanic_composition, cd.commute_specification
order by hcd.hispanic_composition, freq_prcnt desc;

select acd.asian_composition, cd.commute_specification, round((count(*) * 1.0) / c_count.comp_count * 100,2) as freq_prcnt
from census_facts cf 
inner join asian_composition_dim acd ON acd.AcId = cf.AcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
inner join (
			select acd.asian_composition, count(*) as comp_count
			from census_facts cf
			inner join asian_composition_dim acd on acd.AcId = cf.AcId 
			group by acd.asian_composition 
) as c_count on c_count.asian_composition = acd.asian_composition 
group by acd.asian_composition, cd.commute_specification
order by acd.asian_composition, freq_prcnt desc;

-- percentage of people working in hard, demanding jobs by racial composition and commute time
select 'Black ' || bcd.black_composition as race_composition, cd.commute_specification, round(avg(Construction) + avg(Production),2) as Hard_Physical_Jobs from census_facts cf 
inner join black_composition_dim bcd ON bcd.BcId = cf.BcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
where DateId = 1
group by cd.commute_specification, bcd.black_composition
union
select 'White ' || wcd.white_composition as race_compostion, cd.commute_specification, round(avg(Construction) + avg(Production),2) as Hard_Physical_Jobs from census_facts cf 
inner join white_composition_dim wcd ON wcd.WcId = cf.WcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
where DateId = 1
group by cd.commute_specification, wcd.white_composition
union
select 'Hispanic ' || hcd.hispanic_composition as race_compostion, cd.commute_specification, round(avg(Construction) + avg(Production),2) as Hard_Physical_Jobs from census_facts cf 
inner join hispanic_composition_dim hcd ON hcd.HcId = cf.HcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
where DateId = 1
group by cd.commute_specification, hcd.hispanic_composition
union
select 'Asian ' || acd.asian_composition as race_compostion, cd.commute_specification, round(avg(Construction) + avg(Production),2) as Hard_Physical_Jobs from census_facts cf 
inner join asian_composition_dim acd ON acd.AcId = cf.AcId
inner join commute_dim cd on cd.CommuteId = cf.CommuteId
where DateId = 1
group by cd.commute_specification, acd.asian_composition
order by hard_physical_jobs desc;

--------------------------------------------------------------------------------------------------
-- Answers to Question 3																		--
--------------------------------------------------------------------------------------------------

-- create income differences view to answer Q3
drop view income_differences;
create view income_differences as
select cf.StateId, cf.CountyId, cf.BcId as BcId_2015, cf.WcId as WcId_2015, cf.HcId as HcId_2015, cf.AcId as AcId_2015,
	   cf2.BcId as BcId_2017, cf2.WcId as WcId_2017, cf2.HcId as HcId_2017, cf2.AcId as AcId_2017,
	   cf2.income_2017, cf2.rnk_2017, cf.Income as income_2015,
	   rank() over(order by cf.Income desc) as rnk_2015
from census_facts cf 
inner join (
			select cf.StateId, cf.CountyId, cf.BcId, cf.WcId, cf.HcId, cf.AcId, 
			       cf.Income as income_2017, rank() over(order by cf.Income desc) as rnk_2017
			from census_facts cf 
			where cf.DateId = 2
) cf2 on cf2.StateId = cf.StateId and cf2.CountyId = cf.CountyId
where cf.DateId = 1;

-- add index on income to boost performance
drop index income_idx;
CREATE INDEX income_idx 
ON census_facts(Income);

-- shows that the index is used once for each subquery, thus
-- giving higher performance
EXPLAIN QUERY PLAN 
select bcd_2015.black_composition as bc_2015, bcd_2017.black_composition as bc_2017,
       round(avg(id.income_2015),2) as income_2015, round(avg(id.income_2017),2) as income_2017, round(avg(id.income_2017),2) - round(avg(id.income_2015),2) as income_diff,
       round(avg(id.rnk_2015),2) as rnk_2015, round(avg(id.rnk_2017),2) as rnk_2017, round(avg(id.rnk_2015),2) - round(avg(id.rnk_2017),2) as rnk_diff
from income_differences id
inner join state_dim sd on sd.StateId = id.StateId
inner join county_dim cd on cd.CountyId = id.CountyId
inner join black_composition_dim bcd_2015 on bcd_2015.BcId = id.BcId_2015
inner join black_composition_dim bcd_2017 on bcd_2017.BcId = id.BcId_2017
where id.BcId_2015 <> id.BcId_2017 and rnk_2015 <> rnk_2017 
group by bc_2015, bc_2017;

-- check race composition and income differences in 2015, 2017
select bcd_2015.black_composition as bc_2015, bcd_2017.black_composition as bc_2017,
       round(avg(id.income_2015),2) as income_2015, round(avg(id.income_2017),2) as income_2017, round(avg(id.income_2017),2) - round(avg(id.income_2015),2) as income_diff,
       round(avg(id.rnk_2015),2) as rnk_2015, round(avg(id.rnk_2017),2) as rnk_2017, round(avg(id.rnk_2015),2) - round(avg(id.rnk_2017),2) as rnk_diff
from income_differences id
inner join state_dim sd on sd.StateId = id.StateId
inner join county_dim cd on cd.CountyId = id.CountyId
inner join black_composition_dim bcd_2015 on bcd_2015.BcId = id.BcId_2015
inner join black_composition_dim bcd_2017 on bcd_2017.BcId = id.BcId_2017
where id.BcId_2015 <> id.BcId_2017 and rnk_2015 <> rnk_2017 
group by bc_2015, bc_2017;

select wcd_2015.white_composition as wc_2015, wcd_2017.white_composition as wc_2017,
       round(avg(id.income_2015),2) as income_2015, round(avg(id.income_2017),2) as income_2017, round(avg(id.income_2017),2) - round(avg(id.income_2015),2) as income_diff,
       round(avg(id.rnk_2015),2) as rnk_2015, round(avg(id.rnk_2017),2) as rnk_2017, round(avg(id.rnk_2015),2) - round(avg(id.rnk_2017),2) as rnk_diff
from income_differences id
inner join state_dim sd on sd.StateId = id.StateId
inner join county_dim cd on cd.CountyId = id.CountyId
inner join white_composition_dim wcd_2015 on wcd_2015.wcId = id.wcId_2015
inner join white_composition_dim wcd_2017 on wcd_2017.wcId = id.wcId_2017
where id.wcId_2015 <> id.wcId_2017 and rnk_2015 <> rnk_2017 
group by wc_2015, wc_2017;

select hcd_2015.hispanic_composition as hc_2015, hcd_2017.hispanic_composition as hc_2017,
       round(avg(id.income_2015),2) as income_2015, round(avg(id.income_2017),2) as income_2017, round(avg(id.income_2017),2) - round(avg(id.income_2015),2) as income_diff,
       round(avg(id.rnk_2015),2) as rnk_2015, round(avg(id.rnk_2017),2) as rnk_2017, round(avg(id.rnk_2015),2) - round(avg(id.rnk_2017),2) as rnk_diff
from income_differences id
inner join state_dim sd on sd.StateId = id.StateId
inner join county_dim cd on cd.CountyId = id.CountyId
inner join hispanic_composition_dim hcd_2015 on hcd_2015.hcId = id.hcId_2015
inner join hispanic_composition_dim hcd_2017 on hcd_2017.hcId = id.hcId_2017
where id.hcId_2015 <> id.hcId_2017 and rnk_2015 <> rnk_2017 
group by hc_2015, hc_2017;

select acd_2015.asian_composition as ac_2015, acd_2017.asian_composition as ac_2017,
       round(avg(id.income_2015),2) as income_2015, round(avg(id.income_2017),2) as income_2017, round(avg(id.income_2017),2) - round(avg(id.income_2015),2) as income_diff,
       round(avg(id.rnk_2015),2) as rnk_2015, round(avg(id.rnk_2017),2) as rnk_2017, round(avg(id.rnk_2015),2) - round(avg(id.rnk_2017),2) as rnk_diff
from income_differences id
inner join state_dim sd on sd.StateId = id.StateId
inner join county_dim cd on cd.CountyId = id.CountyId
inner join asian_composition_dim acd_2015 on acd_2015.acId = id.acId_2015
inner join asian_composition_dim acd_2017 on acd_2017.acId = id.acId_2017
where id.acId_2015 <> id.acId_2017 and rnk_2015 <> rnk_2017 
group by ac_2015, ac_2017;
