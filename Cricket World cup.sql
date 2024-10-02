-- Which Team has the highest number of wins in T-20 international matches across all grounds-------

select Winner, count(*) as win_count
from match_result
group by Winner
order by win_count desc
limit 1;

-- What is the average margin of victory for each team in world cup final matches-----
select Winner, avg(Margin) as avg_margin
from wc_final_dataset
group by Winner
order by avg_margin desc; 

-- Which team has the highest win percentage over its opponents in the worldcup final matches--------
select Team1 as Team, max(WinOver) as win_percentage
from wc_final_dataset
group by Team1
order by win_percentage desc
limit 1;

-- What is the correlation between a team's average batting ranking and their win margin in worldcup finals-----

select corr('Team Avg Batting Ranking', Margin) as team1_batting_margin_corr,
corr('Team2 Avg Batting Ranking', Margin) as team2_batting_margin_corr
from wc_final_dataset;

-- How does the number of world cup appearances influence a team's chances of winning the final------
select Team1 as Team,
max(Team1_Total_WCs_participated) as total_appearances,
sum(case when Winner = Team1 then 1 else 0 end) as total_wins,
(sum(case when Winner = Team1 then 1 else 0 end)/ Max(Team1_Total_WCs_participated)) * 100 as win_percentage
from wc_final_dataset
group by Team1

union all

select Team2 as Team,
max(Team2_Total_WCs_participated) as total_appearances,
sum(case when Winner = Team2 then 1 else 0 end) as total_wins,
(sum(case when Winner = Team2 then 1 else 0 end)/ max(Team2_Total_WCs_participated)) * 100 as win_percentage
from wc_final_dataset
group by Team2
order by win_percentage desc;

-- Which player has participated in the most world Cup tournaments-----
select PlayerName, 
count(distinct year) as total_participations
from player_list
group by PlayerName
order by total_participations desc
limit 1;

-- Which ground has hosted the most World cup finals, and which team has won the most at that ground----------
select Ground, count(*) as total_finals_hosted
from wc_final_dataset
group by Ground
order by total_finals_hosted desc
limit 1;


select Ground, Winner,  
count(*) as total_wins
from wc_final_dataset
where Ground = (select Ground from wc_final_dataset
group by Ground
order by count(*) desc
limit 1)
group by Ground, Winner
order by total_wins desc
limit 1;

-- The relationship between a team's average bowling ranking and their win percentage in the world Cup Finals----------
-- Win Percentage----
select Team, Sum(total_wins)/count(*) * 100 as win_percentage
from (select Team1 as Team, count(*) as total_matches, 
sum(case when Winner = Team1 then 1 else 0 end) as total_wins
from wc_final_dataset
group by Team1

union all 
select Team2 as Team, count(*) as total_matches,
sum(case when Winner= Team2 then 1 else 0 end) as total_wins
from wc_final_dataset
group by Team2) as team_results
group by Team;

-- Average Bowling Ranking--------
select Team, 
avg(bowling_ranking) as avg_bowling_ranking
from (select Team1 as Team, Team1_Avg_Bowling_Ranking as bowling_ranking
from wc_final_dataset

union all 

select Team2 as Team, Team2_Avg_Bowling_Ranking as bowling_ranking
from wc_final_dataset) as team_bowling_rankings
group by Team;

-- Relationship between Average Bowling Ranking and win percentage-----
select wp.Team, wp.win_percentage, abr.avg_bowling_ranking
from(select Team, 
(sum(case when Winner = Team then 1 else 0 end)/count(*)) *100 as win_percentage
from(select Team1 as Team, Winner from wc_final_dataset 
union all 
select Team2 as Team, Winner from wc_final_dataset) as all_teams
group by Team) as wp
join (select Team, avg(bowling_ranking) as avg_bowling_ranking
from (select Team1 as Team, Team1_Avg_Bowling_Ranking as bowling_ranking 
from wc_final_dataset) as all_bowling_rankings
group by Team) as abr
on wp.Team = abr.Team;

-- Year in which each team played the most T-20 international matches----------

with Team_Matches_Per_Year as (select Team, year(Match_Date) as year,
count(*) as Matches_played
from(select Team1 as Team, Match_Date from match_result
union all 
select Team2 as Team, Match_Date from match_result 
) as all_teams
group by Team, year(Match_Date))

-- Getting the year with the most matches for each team -----
select tm.Team, tm.year, tm.Matches_Played
from Team_Matches_Per_Year tm
join(select Team, max(Matches_played) as Max_Matches
from Team_Matches_Per_Year
group by Team) max_matches on
tm.Team = max_matches.Team and tm.Matches_played = max_matches.Max_Matches;