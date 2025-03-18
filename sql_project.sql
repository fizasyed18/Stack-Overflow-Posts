-- Find all posts with a view_count greater than 100.

select *
from posts
where view_count > 100;

-- Display comments made in 2005, sorted by creation_date.

select *
from comments
where year(creation_date) = 2005
order by creation_date;

-- Calculate the average score of posts grouped by post_type_id.

select post_type_id, avg(score) as average_score
from posts_answers
group by post_type_id;

-- Join the users table with badges to find the total badges earned by each user.

select b.user_id, u.display_name, count(b.name) as total_badges
from badges b
join users u on b.user_id = u.id
group by b.user_id, u.display_name
order by total_badges desc;

-- Fetch the titles of posts, their comments, and the users who made those comments.

select u.id, u.display_name, p.title, c.text
from users u
join comments c on u.id = c.user_id
join posts p on c.post_id = p.id
order by u.id;

-- Join the users, badges, and comments tables to find the users who have earned badges and made comments.

select u.id, u.display_name,
		count(distinct b.id) as total_badges, count(distinct c.id) as total_comments
from users u
join badges b on u.id = b.user_id
join comments c on u.id = c.user_id
group by u.id, u. display_name
order by total_badges desc, total_comments desc;

-- Find the user with the highest reputation. 

select *
from users
where reputation = (select max(reputation)
					from users);

-- Retrieve posts with the highest score in each post_type_id. 

select id, title, post_type_id, score
from posts
where (post_type_id, score) in (select post_type_id, max(score)
								from posts
								group by post_type_id);

-- Rank posts based on their score within each year.

select id, title, creation_date, score, view_count,
		rank() over(partition by year(creation_date) order by score) as ranking
from posts;

-- Calculate the running total of badges earned by users.

select user_id, name, date,
		count(*) over(partition by user_id order by id) as running_total_badges
from badges;

-- Create a CTE to calculate the average score of posts by each user and use it to:
    -- List users with an average score above 50.
    -- Rank users based on their average post score.

-- 1. List users with an average score above 50.

with t as (
select id, avg(score) as average_score
from posts_answers
group by id
),
highscore as (
select id, average_score
from t
where average_score > 50
)
select u.id, u.display_name, reputation, hs.average_score
from highscore hs
join users u on u.id = hs.id;

-- 2. Rank users based on their average post score. 

with t as (
select id, avg(score) as average_score
from posts_answers
group by id
),
highscore as (
select id, average_score
from t
where average_score > 50
)
select u.id, u.display_name, reputation, hs.average_score, rank() over(order by average_score desc) as ranking
from highscore hs
join users u on u.id = hs.id;

-- Which users have contributed the most in terms of comments, edits, and votes? 

select u.id, u.display_name,
		count(distinct c.id) as total_comments,
        count(distinct ph.id) as total_edits,
        count(distinct v.id) as total_votes,
        (count(distinct c.id) + count(distinct ph.id) + count(distinct v.id)) as top_contributors
from comments c
join users u on c.user_id = u.id
join post_history ph on c.user_id = ph.user_id
join votes v on c.post_id = v.post_id
group by u.id;

-- What types of badges are most commonly earned, and which users are the top earners? 

-- 	Most Earned Badges

select name, count(id) as badges_count
from badges
group by name
order by badges_count desc;

-- 	Users with most Badges

select u.id, u.display_name, count(b.id) as total_badges
from users u
join badges b on u.id = b.user_id 
group by u.id
order by total_badges desc;