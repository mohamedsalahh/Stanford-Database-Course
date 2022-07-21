

-- Find the names of all reviewers who rated Gone with the Wind.

SELECT name
FROM Reviewer
WHERE rID IN (
	SELECT rID
	FROM Rating, Movie
	WHERE Rating.mID = Movie.mID AND Movie.title = 'Gone with the Wind'
);


-- For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.

SELECT Reviewer.name, Movie.title, Rating.stars
FROM Rating, Movie, Reviewer
WHERE Rating.mID = Movie.mID AND Reviewer.rID = Rating.rID
AND Reviewer.name = Movie.director;


-- Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)

SELECT name
FROM Reviewer
UNION
SELECT title
FROM Movie;


-- Find the titles of all movies not reviewed by Chris Jackson.

SELECT title
FROM Movie
WHERE mID NOT IN (
	SELECT mID
	FROM Rating, Reviewer
	WHERE Reviewer.rID = Rating.rID AND Reviewer.name = 'Chris Jackson'
);


-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.

SELECT DISTINCT RV1.name, RV2.name
FROM Rating AS R1, Rating AS R2, Reviewer AS RV1, Reviewer AS RV2
WHERE R1.mID = R2.mID AND R1.rID = RV1.rID AND R2.rID = RV2.rID
AND R1.rID != R2.rID AND RV1.name < RV2.name
ORDER BY RV1.name, RV2.name;


-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.

SELECT Reviewer.name, Movie.title, Rating.stars
FROM Rating, Reviewer, Movie
WHERE Rating.mID = Movie.mID AND Rating.rID = Reviewer.rID
AND Rating.stars = (
	SELECT MIN(stars)
	FROM Rating
);


-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.

SELECT Movie.title, avgRatings
FROM Movie, (
	SELECT mID, AVG(stars) avgRatings
	FROM Rating
	GROUP BY mID
) AS Q1
WHERE Movie.mID = Q1.mID
ORDER BY avgRatings DESC, title;


-- Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)

SELECT name
FROM Reviewer, (
	SELECT rID, COUNT(*) AS contributedCnt
	FROM Rating
	GROUP BY rID
	HAVING COUNT(*) >= 3
) AS Q1
WHERE Reviewer.rID = Q1.rID;


-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

SELECT title, director
FROM Movie
WHERE director IN (
	SELECT director
	FROM Movie
	GROUP BY director
	HAVING COUNT(*) > 1
)
ORDER BY director, title;


-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)

SELECT title , avgRating
FROM (
	SELECT title , avgRating, DENSE_RANK () OVER (ORDER BY avgRating DESC) AS rnk
	FROM Movie, (
		SELECT mID, AVG(stars) AS avgRating
		FROM Rating
		GROUP BY mID
	) AS Q1
	WHERE Movie.mID = Q1.mID
) AS Q2
WHERE rnk = 1;


-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)

SELECT title , avgRating
FROM (
	SELECT title , avgRating, DENSE_RANK () OVER (ORDER BY avgRating) AS rnk
	FROM Movie, (
		SELECT mID, AVG(stars) AS avgRating
		FROM Rating
		GROUP BY mID
	) AS Q1
	WHERE Movie.mID = Q1.mID
) AS Q2
WHERE rnk = 1;


-- For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.

SELECT director, title, MxStars
FROM (
	SELECT director, title, MxStars, DENSE_RANK() OVER(PARTITION BY director ORDER BY MxStars DESC) AS rnk
	FROM Movie, (
		SELECT mID, MAX(stars) AS MxStars
		FROM Rating
		GROUP BY mID
	) AS Q1
	WHERE Movie.mID = Q1.mID AND director IS NOT NULL
) AS Q2
WHERE Q2.rnk = 1;