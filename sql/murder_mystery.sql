-- Step 1
-- Query for finding out the Description of Murder
select * from crime_scene_report
where type='murder' and city='SQL City' and date = '20180115'


-- Step 2
--Identifying th details of witnesses based on crime scene report:
  --Witness 1: Last house in Northwestern Dr
  --Witness 2: Annabel, lives in Franklin Ave
  

-- Step 3
-- Details of Witness 1
select * from person
where address_street_name='Northwestern Dr'
order by address_number desc
limit 1


-- Step 4
-- Details of Witness 2
select * from person
where name like '%Annabel%' and address_street_name='Franklin Ave'

--Details of witness 1 :
  --Witness 1 -> Morty Schapiro, 14887
--Details of witness 2 :
  --Witness 2 -> Annabel Miller, 16371


-- Step - 5
-- Getting interview transcript of two witnesses:
select * from interview
where person_id in (14887,16371)


-- Step - 6
-- Details of murder
	--Shot with a gun
	--Killer had 'Get Fit Now' gym bag
	--Membership number started with '48Z'
	--Should be Gold Membership
	--Car plate number conrtains 'H42
	--Killer is from Gym 
	--he/she went to Gym on January 9th 2018


-- Step - 7
--Idntifying all suspects and Getting the name of killer based on above info

select p.name,p.id from get_fit_now_member gfm
inner join get_fit_now_check_in gfc 
	on gfm.id = gfc.membership_id
inner join person p
	on p.id = gfm.person_id
inner join drivers_license dl
	on dl.id = p.license_id
where gfm.id like '%48Z%' and gfm.membership_status = 'gold'
	and gfc.check_in_date=20180109
	and dl.plate_number like '%H42W%'
	
--Here is the name of killer: 'Jeremy Bowers' - 67318

--But Hold-On, the real villian is out there!
--Lets find he/her
 


-- Step - 8
--Checking the interview details of the killer for finding out the mastermind/villian

select * from interview 
where person_id = 67318


-- Step - 9
--Details of the mastermind:
 	--mastermind is a Women
	--Has lot of money
	--Height between 5'5"(65") and 5'7"(67")
	--Red hair
	--Drives Tesla Model S
	--Attended SQL Symphony Concert 3 times in Dec 2017


-- Step - 10 & 11
--Find people attending SQL Symphony Concert multiple times in Dec 2017
with cte as (
    select person_id,count(*) as frequency from facebook_event_checkin
    where date like '201712%'
    	and event_name like '%SQL Symphony%'
    group by person_id
    having frequency >= 3
  )
-- Filding the mastermind based on all the clues and above cte
select p.name,p.id from drivers_license dl
join person p
	on p.license_id = dl.id
join cte
	on cte.person_id = p.id 
where hair_color = 'red'
	and dl.gender = 'female'
	and dl.height between 65 and 67
	and dl.car_make = 'Tesla'
	and dl.car_model = 'Model S'

--Here is your main Villian
-- Miranda Priestly	- 99716
