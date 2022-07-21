


-- It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

DELETE FROM Highschooler
WHERE grade = 12;


-- If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.

DELETE FROM Likes
WHERE EXISTS (
	SELECT *
	FROM Friend
	WHERE EXISTS (
		SELECT *
		FROM Likes L1
		WHERE L1.ID1 = Friend.ID1 AND L1.ID2 = Friend.ID2
	)
	AND NOT EXISTS (
		SELECT *
		FROM Likes L2
		WHERE L2.ID1 = Friend.ID2 AND L2.ID2 = Friend.ID1
	)
	AND Friend.ID1 = Likes.ID1 AND Friend.ID2 = Likes.ID2
);


-- For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)

INSERT INTO Friend
SELECT DISTINCT F1.ID1, F2.ID2
FROM Friend AS F1, Friend AS F2
WHERE F1.ID2 = F2.ID1 AND F1.ID1 != F2.ID2
AND NOT EXISTS (
	SELECT *
	FROM Friend
	WHERE ID1 = F1.ID1 AND ID2 = F2.ID2
);