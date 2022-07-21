

-- Find the titles of all movies directed by Steven Spielberg.

SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';


-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

SELECT year
FROM Movie
WHERE mID IN (
	SELECT mID
	FROM Rating 
	WHERE stars = 4 OR stars = 5
)
ORDER BY year;


-- Find the titles of all movies that have no ratings.

SELECT title
FROM Movie
WHERE mID NOT IN (
  SELECT mID
  FROM Rating
);


-- Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.

SELECT name
FROM Reviewer
WHERE rID IN (
	SELECT rID
	FROM Rating
	WHERE ratingDate IS NULL
);


-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.

SELECT name, title, stars, ratingDate
FROM Movie, Reviewer, Rating
WHERE Rating.rID = Reviewer.rID AND Rating.mID = Movie.mID
ORDER BY name, title, stars;


-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
SELECT name, title
FROM Movie, Reviewer, (
	SELECT Rating.rID, Rating.mID, MINS, MIND, Rating.stars, Rating.ratingDate
	FROM Rating, (
		SELECT rID, mID, MIN(stars) AS MINS, MIN(ratingDate) AS MIND
		FROM Rating
		GROUP BY rID, mID
		HAVING COUNT(*) >= 2
	) AS Q1
	WHERE Q1.rID = Rating.rID AND Q1.mID = Rating.mID 
	AND MINS = Rating.stars 
	AND MIND = Rating.ratingDate
) AS Q2
WHERE Movie.mID = Q2.mID AND Reviewer.rID = Q2.rID;


-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.

SELECT title, Q1.MAXS
FROM Movie, (
	SELECT mID, MAX(stars) AS MAXS
	FROM Rating
	GROUP BY mID
) AS Q1
WHERE Movie.mID = Q1.mID
ORDER BY title;


-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.

SELECT title, rating_spread
FROM Movie, (
	SELECT mID, MAX(stars) - MIN(stars) AS rating_spread
	FROM Rating
	GROUP BY mID
) AS Q1
WHERE Movie.mID = Q1.mID
ORDER BY rating_spread DESC, title;


-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)

SELECT AVG(AV1.AVGM) - AVG(AV2.AVGM)
FROM (
	SELECT AVGM
	FROM Movie, (
		SELECT mID, AVG(stars) AS AVGM
		FROM Rating
		GROUP BY mID
	) AS Q1
	WHERE Movie.mID = Q1.mID AND year < 1980
) AS AV1,
(
	SELECT AVGM
	FROM Movie, (
		SELECT mID, AVG(stars) AS AVGM
		FROM Rating
		GROUP BY mID
	) AS Q1
	WHERE Movie.mID = Q1.mID AND year > 1980
) AS AV2