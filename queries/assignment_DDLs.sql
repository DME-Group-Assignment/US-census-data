--------------------------------------------------------------------------------------------------
-- Data Quality check																		--
--------------------------------------------------------------------------------------------------

-- check for null values
select * from acs2015_county ac
where TotalPop is null or men is null or women is null or hispanic is null or white is null or black is null or native is null
or asian is null or pacific is null or citizen is null or income is null or IncomeErr is null or IncomePerCap is null or poverty is null or 
ChildPoverty is null or Professional is null or Service is null or office is null or Construction is null or Production is null or drive is null or 
Carpool is null or Transit is null or walk is null or OtherTransp is null or WorkAtHome is null or MeanCommute is null or Employed is null or
PrivateWork is null or PublicWork is null or SelfEmployed is null or FamilyWork is null or Unemployment is null; -- no null values

select * from acs2017_county ac
where TotalPop is null or men is null or women is null or hispanic is null or white is null or black is null or native is null
or asian is null or pacific is null or VotingAgeCitizen is null or income is null or IncomeErr is null or IncomePerCap is null or poverty is null or 
ChildPoverty is null or Professional is null or Service is null or office is null or Construction is null or Production is null or drive is null or 
Carpool is null or Transit is null or walk is null or OtherTransp is null or WorkAtHome is null or MeanCommute is null or Employed is null or
PrivateWork is null or PublicWork is null or SelfEmployed is null or FamilyWork is null or Unemployment is null; -- no null values

-- check for empty strings
select * from acs2015_county ac
where TotalPop = '' or men = '' or women = '' or hispanic = '' or white = '' or black = '' or native = ''
or asian = '' or pacific = '' or citizen = '' or income = '' or IncomeErr = '' or IncomePerCap = '' or poverty = '' or 
ChildPoverty = '' or Professional = '' or Service = '' or office = '' or Construction = '' or Production = '' or drive = '' or 
Carpool = '' or Transit = '' or walk = '' or OtherTransp = '' or WorkAtHome = '' or MeanCommute = '' or Employed = '' or
PrivateWork = '' or PublicWork = '' or SelfEmployed = '' or FamilyWork = '' or Unemployment = '';
-- censusid 15005 is missing Childpoverty
-- censusid 48301 is missing income, incomeerr

select * from acs2017_county ac
where TotalPop = '' or men = '' or women = '' or hispanic = '' or white = '' or black = '' or native = ''
or asian = '' or pacific = '' or VotingAgeCitizen = '' or income = '' or IncomeErr = '' or IncomePerCap = '' or poverty = '' or 
ChildPoverty = '' or Professional = '' or Service = '' or office = '' or Construction = '' or Production = '' or drive = '' or 
Carpool = '' or Transit = '' or walk = '' or OtherTransp = '' or WorkAtHome = '' or MeanCommute = '' or Employed = '' or
PrivateWork = '' or PublicWork = '' or SelfEmployed = '' or FamilyWork = '' or Unemployment = '';
-- censusid 15005 is missing Childpovert

-- update empty strings into null values
Update acs2015_county set ChildPoverty = NULL where CensusId = 15005;
Update acs2017_county set ChildPoverty = NULL where CountyId = 15005;
Update acs2015_county set Income = NULL, IncomeErr = NULL where CensusId = 48301;

-- fix county name issue in 2017 census
update acs2017_county set county = trim(replace(replace(replace(county, 'County', ''), 'Parish', ''), 'Municipio', ''));

--------------------------------------------------------------------------------------------------
-- Table creation																		--
--------------------------------------------------------------------------------------------------

-- DDLs
drop table state_dim;
create table state_dim (
	StateId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	State TEXT
);

drop table county_dim ;
create table county_dim (
	CountyId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	County TEXT
);

drop table black_composition_dim; 
create table black_composition_dim (
	BcId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	black_composition TEXT
);

drop table white_composition_dim ;
create table white_composition_dim (
	WcId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	white_composition TEXT
);

drop table asian_composition_dim ;
create table asian_composition_dim (
	AcId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	asian_composition TEXT
);

drop table hispanic_composition_dim ;
create table hispanic_composition_dim (
	HcId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	hispanic_composition TEXT
);

drop table commute_dim ;
create table commute_dim (
	CommuteId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	commute_specification TEXT
);

drop table income_dim ;
create table income_dim (
	incomeId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	income_specification TEXT
);

drop table date_dim ;
create table date_dim (
	DateId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	year TEXT
);

-- populate state_dim
insert into state_dim (State)
select distinct State from acs2015_county ac;

-- populate county_dim
insert into county_dim (County)
select distinct county from acs2015_county ac;

-- populate black_composition_dim
insert into black_composition_dim (black_composition)
values ('Minority'), ('Plurality'), ('Majority');

-- populate white_composition_dim
insert into white_composition_dim (white_composition)
values ('Minority'), ('Plurality'), ('Majority');

-- populate asian_composition_dim
insert into asian_composition_dim (asian_composition)
values ('Minority'), ('Plurality'), ('Majority');

-- populate hispanic_composition_dim
insert into hispanic_composition_dim (hispanic_composition)
values ('Minority'), ('Plurality'), ('Majority');

-- populate commute_dim
insert into commute_dim (commute_specification)
values ('Low Commute Time'), ('Normal Commute Time'), ('High Commute Time');

-- populate income_dim
insert into income_dim (income_specification)
values ('Low Income'), ('Medium Income'), ('High Income');

-- populate date_dim
insert into date_dim (year)
values ('2015'), ('2017');

-- create and populate fact table
drop table census_facts;
CREATE TABLE census_facts (
	CensusId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	DateId INTEGER NOT NULL,
	StateId INTEGER NOT NULL,
	CountyId INTEGER NOT NULL,
	BcId INTEGER NOT NULL,
	WcId INTEGER NOT NULL,
	HcId INTEGER NOT NULL,
	AcId INTEGER NOT NULL,
	CommuteId INTEGER NOT NULL,
	IncomeId INTEGER NOT NULL,
	Hispanic REAL,
	White REAL,
	Black REAL,
	Asian REAL,
	Income REAL,
	IncomeErr REAL,
	IncomePerCap INTEGER,
	IncomePerCapErr INTEGER,
	Professional REAL,
	Service REAL,
	Office REAL,
	Construction REAL,
	Production REAL,
	MeanCommute REAL,
	FOREIGN KEY (DateId)
       REFERENCES date_dim (DateId),
    FOREIGN KEY (StateId)
       REFERENCES state_dim (StateId),
    FOREIGN KEY (CountyId)
       REFERENCES county_dim (CountyId),
    FOREIGN KEY (BcId)
       REFERENCES black_composition_dim (BcId), 
    FOREIGN KEY (WcId)
       REFERENCES white_composition_dim (WcId), 
    FOREIGN KEY (AcId)
       REFERENCES asian_composition_dim (AcId), 
    FOREIGN KEY (HcId)
       REFERENCES hispanic_composition_dim (HcId), 
    FOREIGN KEY (CommuteId)
       REFERENCES commute_dim (CommuteId),
    FOREIGN KEY (IncomeId)
       REFERENCES income_dim (IncomeId)
);

insert into census_facts (DateId, StateId, CountyId, BcId, WcId, HcId, AcId, CommuteId, IncomeId,
							Hispanic, White, Black, Asian,
							Income, IncomeErr, IncomePerCap, IncomePerCapErr, Professional,
							Service, Office, Construction, Production, MeanCommute)
SELECT 1 as DateId, s.StateId, c.CountyId,
case 
	when Black >= 50 then 3
	when Black < 50 and (Black > Hispanic and Black > White and Black > Native and Black > Pacific and Black > Asian) then 2
	when Black between 40 and 50 and (White >= 50 or Hispanic >= 50 or Asian >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end BcId,
case 
	when White >= 50 then 3
	when White < 50 and (White > Hispanic and White > Black and White > Native and White > Pacific and White > Asian) then 2
	when White between 40 and 50 and (Black >= 50 or Hispanic >= 50 or Asian >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end WcId,
case 
	when Hispanic >= 50 then 3
	when Hispanic < 50 and (Hispanic > White and Hispanic > Black and Hispanic > Native and Hispanic > Pacific and Hispanic > Asian) then 2
	when Hispanic between 40 and 50 and (Black >= 50 or White >= 50 or Asian >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end HcId,
case 
	when Asian >= 50 then 3
	when Asian < 50 and (Asian > White and Asian > Black and Asian > Native and Asian > Pacific and Asian > Hispanic) then 2
	when Asian between 40 and 50 and (Black >= 50 or White >= 50 or Hispanic >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end AcId,
case 
   	when meanCommute > (select avg(meanCommute) + stdev(MeanCommute) from acs2015_county group by state ) then 3
	when meanCommute < (select avg(meanCommute) + stdev(MeanCommute) from acs2015_county group by state ) 
			and MeanCommute > (select avg(meanCommute) - stdev(MeanCommute) from acs2015_county group by state ) then 2
	else 1 end commute_id,
case 
   	when Income > (select avg(Income) + stdev(Income) from acs2015_county group by state ) then 3
	when Income < (select avg(Income) + stdev(Income) from acs2015_county group by state ) 
			and Income > (select avg(Income) - stdev(Income) from acs2015_county group by state ) then 2
	else 1 end income_id,
Hispanic, White,
Black, Asian,  
Income, IncomeErr, 
IncomePerCap, IncomePerCapErr, 
Professional, Service, 
Office, Construction,
Production, MeanCommute
FROM acs2015_county t
inner join state_dim s on s.state = t.state
inner join county_dim c on c.county = t.County
UNION
SELECT 2 as Dateid, s.StateId, c.CountyId,
case 
	when Black >= 50 then 3
	when Black < 50 and (Black > Hispanic and Black > White and Black > Native and Black > Pacific and Black > Asian) then 2
	when Black between 40 and 50 and (White >= 50 or Hispanic >= 50 or Asian >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end BcId,
case 
	when White >= 50 then 3
	when White < 50 and (White > Hispanic and White > Black and White > Native and White > Pacific and White > Asian) then 2
	when White between 40 and 50 and (Black >= 50 or Hispanic >= 50 or Asian >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end WcId,
case 
	when Hispanic >= 50 then 3
	when Hispanic < 50 and (Hispanic > White and Hispanic > Black and Hispanic > Native and Hispanic > Pacific and Hispanic > Asian) then 2
	when Hispanic between 40 and 50 and (Black >= 50 or White >= 50 or Asian >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end HcId,
case 
	when Asian >= 50 then 3
	when Asian < 50 and (Asian > White and Asian > Black and Asian > Native and Asian > Pacific and Asian > Hispanic) then 2
	when Asian between 40 and 50 and (Black >= 50 or White >= 50 or Hispanic >= 50 or Native >= 50 or Pacific >= 50) then 2
	else 1 end AcId,
case 
   	when meanCommute > (select avg(meanCommute) + stdev(MeanCommute) from acs2017_county group by state ) then 3
	when meanCommute < (select avg(meanCommute) + stdev(MeanCommute) from acs2017_county group by state ) 
			and MeanCommute > (select avg(meanCommute) - stdev(MeanCommute) from acs2017_county group by state ) then 2
	else 1 end commute_id,
case 
   	when Income > (select avg(Income) + stdev(Income) from acs2017_county group by state ) then 3
	when Income < (select avg(Income) + stdev(Income) from acs2017_county group by state ) 
			and Income > (select avg(Income) - stdev(Income) from acs2017_county group by state ) then 2
	else 1 end income_id,
Hispanic, White,
Black, Asian,  
Income, IncomeErr, 
IncomePerCap, IncomePerCapErr, 
Professional, Service, 
Office, Construction,
Production, MeanCommute
FROM acs2017_county t2
inner join state_dim s on s.state = t2.state
inner join county_dim c on c.county = t2.County;

-- test query from main facts table
select * from census_facts cf;

-- trigger prevent update
drop trigger PreventUpdateCensusFacts;
CREATE TRIGGER PreventUpdateCensusFacts
       BEFORE UPDATE ON census_facts
BEGIN 
  SELECT CASE 
  		WHEN new.hispanic is not null or
  			 new.white is not null or
  			 new.black is not null or
  			 new.asian is not null or
  			 new.income is not null or
  			 new.meancommute is not null
  		then
  		RAISE(ABORT,'You cannot update race, income or commute attributes.') END;
END;

-- Demonstrate that the trigger does not allow to update specific columns
update census_facts 
set white = 100
where white < 50;