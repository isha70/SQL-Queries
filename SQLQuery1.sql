/*Write a query to get Profile ID, Full Name and Contact Number of the tenant who has stayed with us for the longest time period in the past*/

select profile_id, first_name + ' ' +last_name as Full_Name, phone
 from Profiles 
where   profile_id=	 
	(SELECT top 1 profile_id 
from [Tenancy History] 
order by DATEDIFF(day,move_in_date,move_out_date))

/*Write a query to get the Full name, email id, phone of tenants who are married and paying rent > 9000 using subqueries*/

Select first_name+''+last_name AS Full_name, phone, email_id
from Profiles
where profile_id IN
((Select profile_id from Profiles where marital_status = 'Y' ) UNION (
Select profile_id from [Tenancy History]
where rent >'9000'));

/*Write a query to display profile id, full name, phone, email id, city , house id, move_in_date , move_out date, rent, total number of referrals made, latest employer and the occupational category of all the tenants living in Bangalore or Pune in the time period of jan 2015 to jan 2016 sorted by their rent in descending order*/

select P.profile_id,(P.first_name+''+P.last_name) as full_name,P.phone,P.email_id,P.city,
       T.house_id,T.move_in_date,T.move_out_date,T.rent,
	   E.latest_employer,E.occupational_category,
	   count(R.ID) AS Total_referral 
from
Profiles P
inner join
[Tenancy History] T
On
P.profile_id=T.profile_id
inner join 
[Employee Status] E
On 
P.profile_id = E.profile_id
inner join
Referral R
On
P.profile_id = R.profile_id
where move_in_date >= '2015-01-01'
AND move_out_date <= '2016-01-01'
AND city IN ('Bangalore','Pune')
group by P.profile_id,(P.first_name+''+P.last_name) ,P.phone,P.email_id,P.city,T.house_id,T.move_in_date,T.move_out_date,T.rent,
	   E.latest_employer,E.occupational_category
order by rent DESC

/*Write a sql snippet to find the full_name, email_id, phone number and referral code of all the tenants who have referred more than once. Also find the total bonus amount they should receive given that the bonus gets calculated only for valid referrals.*/

select P.profile_id,P.first_name+' '+P.last_name as full_name,P.email_id,P.phone,P.referral_code
       ,sum(R.referrer_bonus_amount) as total_bonus_amount
from 
Profiles P
inner join
Referral R
On
P.profile_id=R.profile_id
group by  P.profile_id,P.first_name+' '+P.last_name,P.email_id,P.phone,P.referral_code
having count(R.profile_id)>1

/*Write a query to find the rent generated from each city and also the total of all cities*/

Select P.city , sum(rent) as Total_rent
from
[Tenancy History] T
inner join
Profiles P
On
p.profile_id=T.profile_id
group by city

/*Create a view 'vw_tenant' find profile_id,rent,move_in_date,house_type,beds_vacant,description and city of tenants who shifted on/after 30th april 2015 and are living in houses having vacant beds and its address.  */

Create View
vw_tenant
AS
Select T.profile_id,T.rent,T.move_in_date,
       H.house_type,H.beds_vacant,
	   A.* 
from 
[Tenancy History] T
inner join
Houses H
On
T.house_id=H.house_id
inner join
Addresses A
On 
T.house_id=A.house_id
where move_in_date>='2015-04-30'
AND beds_vacant>0

/*Write a code to extend the valid_till date for a month of tenants who have referred more than two times*/

Select DATEADD (MONTH,1, valid_till) as valid_till
from Referral
where profile_id IN
(Select profile_id 
from Referral
group by profile_id 
having COUNT (profile_id)>2)

/*Write a query to get Profile ID, Full Name, Contact Number of the tenants along with a new column 'Customer Segment' wherein if the tenant pays rent greater than 10000, tenant falls in Grade A segment, if rent is between 7500 to 10000, tenant falls in Grade B else in Grade C*/

Select P.profile_id,P.first_name+''+P.last_name as full_name,P.phone,
       IIF(T.rent > 10000,'Grade A',
       IIF(T.rent < 7500,'Grade C','Grade B')) as Customer_Segment
From 
Profiles P
inner join 
[Tenancy History] T
On 
P.profile_id = T.profile_id 

/*Write a query to get Fullname, Contact, City and House Details of the tenants who have not referred even once.*/

select P.profile_id,P.first_name+''+P.last_name as full_name,P.phone,P.city,
       H.*
from
Profiles P
inner join
[Tenancy History] T
On
P.profile_id=T.profile_id
inner join
Houses H
On
T.house_id=H.house_id
where P.profile_id not in (select profile_id from Referral)

/*Write a query to get the house details of the house having highest occupancy*/

Select top (1) with ties A.*, H. house_type,
            H.bhk_type,H.furnishing_type, (H.bed_count-H.beds_vacant) AS TOTAL_OCC
from
Addresses A
INNER JOIN 
Houses H
ON
A.house_id= H.house_id
ORDER BY TOTAL_OCC DESC
