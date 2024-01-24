-- 1. How many olympics games have been held?

Select Count(Distinct Games) as Total_No_of_Games_Held
From Olympics



-- 2. List down all Olympics games held so far.

Select Year, Season, City
From Olympics
Group By Year, Season, City
Order BY 1,2



-- 3. Mention the total no of nations who participated in each olympics game?

Select Games, Count(Distinct Region)
From Olympics ol
Join noc_regions noc
ON noc.noc = ol.NOC
Group By Games
Order By Games



-- 4. Which year saw the highest and lowest no of countries participating in olympics

Select Top(1) Games, Count(Distinct Region)
From Olympics ol
Join noc_regions noc
ON noc.noc = ol.NOC
Group By Games
Order By 2 -- ASC/DESC will decide the lowest or highestno. of countries participated in olympics



--5. Which nation has participated in all of the olympic games

With t1 as
(
Select Count(Distinct Games) as Total_No_of_Games_Held
From Olympics
),

t2 as
(
Select noc.Region, Count(Distinct Games) as No_of_olympics_participated
From Olympics ol
Join noc_regions noc
ON noc.noc=ol.noc
Group By noc.Region
)

Select Region as Countries_Participated_in_all_Olympic_Games
From t1,t2
Where No_of_olympics_participated = Total_No_of_Games_Held



-- 6. Identify the sport which was played in all summer olympics

With t1 as
(
Select Count(Distinct Games) as total_summer_games
From Olympics
Where Season = 'Summer'
),
-- we found the total no of summer olympics conducted


t2 as
(
Select Distinct Sport, Games
From Olympics
Where Season = 'Summer'
),

t3 as
(
Select Sport, Count(Games) as no_of_olympics_part_of
From t2
Group by Sport
)
--The table t2 & t3 gave the list of all distinct sports and how many olypmics were those games played in


Select *
from t3,t1
Where no_of_olympics_part_of = total_summer_games
--Now we filtered those sports who were played in all the summer olympics


--7. Which Sports were just played only once in the olympics.

With t1 as
(
Select Sport, Count(Distinct Games) as No_of_Olympics_where_the_sport_was_played
From Olympics
Group BY Sport
)

Select *
From t1
Where No_of_Olympics_where_the_sport_was_played =1
Order By 1




-- 8. Fetch the total no of sports played in each olympic games.

Select Games, Count(Distinct Sport) as No_of_Sports_in_each_olympics
From Olympics
Group BY Games
Order By 1



-- 9. Fetch oldest athletes to win a gold medal


with t1 as
(
Select Name, Age, Medal
From Olympics
Where Medal ='Gold'
Group By Name,Age,Medal
),

t2 as 
(
Select *, Rank() over (order by Age DESC) as Rnk
From t1
)

Select *
From t2
Where Rnk = 1




--10. Find the Ratio of male and female athletes participated in all olympic games.

With t1 as
	(
	Select Distinct Sex, Count(Sex) as Cnt
	From Olympics
	Group By Sex
	),
t2 as
	(
	Select *, row_number() Over (order by Sex DESC) as Rnk
	From t1
	),
male_cnt as
	(select cnt 
	from t2	where rnk = 1),
female_cnt as
	(select cnt 
	from t2	where rnk = 2)

Select concat('1: ', round (cast(male_cnt.cnt as float)/ cast(female_cnt.cnt as float),2)) as ratio
from male_cnt, female_cnt


--11. Fetch the top 5 athletes who have won the most gold medals.
   
with t4 as
(
Select Name, Count(Medal) as Total_Gold_Medals
From Olympics
Where Medal = 'Gold'
Group By Name 
),

t5 as
(
Select *, Dense_Rank() Over (Order By Total_Gold_Medals DESC) as rank
From t4 
)

Select * 
From t5
Where rank <=5
Order BY 3,1



--12. Fetch the top 5 athletes who have won the most medals (Gold/Silver/Bronze)

with t4 as
(
Select Name, Count(Medal) as Total_Medals
From Olympics
Where Medal <> 'NA'
Group By Name
),

t5 as
(
Select *, Dense_Rank() Over (Order By Total_Medals DESC) as rank
From t4 
)

Select * 
From t5
Where rank <=5
Order BY 3,1



-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

With t1 as
(
Select Region, Count (Medal) as Total_Medals
From Olympics ol
Join noc_regions noc
ON noc.noc =ol.noc
Where Medal <> 'NA'
Group By Region
),
t2 as
(
Select *, Rank() Over (Order By Total_Medals DESC) as Rnk
From t1
)
Select *
From t2
Where Rnk <6



--14. List down total gold, silver and bronze medals won by each country.

Select Country, Gold, Silver, Bronze
From 
(Select noc.Region as Country, medal, Count(Medal) as Total_Medals
From olympics ol
Join noc_regions noc
ON noc.NOC = ol.noc
Where Medal <> 'NA'
Group By noc.Region,medal
--Order By 1,2
) as t1
PIVOT
(
   Sum(Total_Medals)
   For medal
   IN ([Gold], [Silver],[Bronze])
)
as PivotTable
Order By Gold DESC



--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

with t1 as
(Select Games, Region as Country , Medal, Count(Medal) as Total_Medals
From olympics ol
Join noc_regions noc
ON noc.NOC = ol.noc
Where Medal <> 'NA'
Group By Region,Medal,Games
--Order By 1,2,3
)
Select Games, Country, Gold, Silver, Bronze
From t1
Pivot
(
	Sum(Total_Medals)
    For medal
    IN ([Gold], [Silver],[Bronze])
)
as PivotTable
Order By Games,Country



--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as
(Select Games, Region as Country , Medal, Count(Medal) as Total_Medals
From olympics ol
Join noc_regions noc
ON noc.NOC = ol.noc
Where Medal <> 'NA'
Group By Region,Medal,Games
--Order By 1,3,4 DESC
),

t2 as 
(Select *, Rank() over (partition by Games, Medal Order By Total_medals DESC) as Rnk
From t1
),

t3 as
(Select Games, Country, Medal, Total_Medals, CONCAT(Country,'-',Total_Medals) as Country_Medals
From t2
Where Rnk =1
),

t4 as
(
Select Games, Medal, Country_Medals
From t3
)

Select Games, Gold, Silver, Bronze
From t4
Pivot
(
	Max(Country_Medals)
    For medal
    IN ([Gold], [Silver],[Bronze])
)as PivotTable




--17. Which countries have never won gold medal but have won silver/bronze medals?


with t2 as
(
Select Country, Gold, Silver, Bronze
From 
(Select Region as Country , Medal, Count(Medal) as Total_Medals
From olympics ol
Join noc_regions noc
ON noc.NOC = ol.noc
Where Medal <> 'NA'
Group By Region, Medal
--Order By 1,2,3
) as t1
Pivot
(
	Sum(Total_Medals)
    For medal
    IN ([Gold], [Silver],[Bronze])
)as PivotTable
)

Select *
From t2
Where Gold is null AND NOT Silver is null AND NOT Bronze is null
Order By 2 DESC,3 DESC 




--18. In which Sport/event, India has won highest medals.

with t1 as
(
Select Sport, Count(Medal) as Total_medals
From Olympics ol
Join noc_regions noc
ON noc.noc = ol.noc
Where Medal <> 'NA' AND Region = 'INDIA'
Group By Sport
),
t2 as
(
Select *,rank() over (Order By total_medals DESC) as rnk
From t1
)

Select Sport, Total_Medals
From t2
Where rnk =1


--19. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

Select Region, Games,Sport, Count(Medal) as Total_medals
From Olympics ol
Join noc_regions noc
ON noc.noc = ol.noc
Where Medal <> 'NA' AND Region = 'INDIA' AND Sport='Hockey'
Group By Games,Medal, Sport,Region
Order By 2


Select *
From(
Select Region, 
SUM(case when medal = 'Gold' then 1 else 0 end) as Gold,
SUM(case when medal = 'Silver' then 1 else 0 end) as Silver,
SUM(case when medal = 'Bronze' then 1 else 0 end) as Bronze
From Olympics ol
Join noc_regions noc
ON noc.noc = ol.noc
Group By Region
)a
Where Gold=0 AND Silver <> 0 AND Bronze <> 0
Order By 2 DESC, 3 DESC, 4 DESC

Select *
From Olympics
