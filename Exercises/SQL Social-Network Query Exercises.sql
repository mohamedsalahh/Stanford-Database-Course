

-- Find the names of all students who are friends with someone named Gabriel.

SELECT name
FROM Highschooler
WHERE ID IN (
	SELECT ID1
	FROM Friend
	WHERE ID2 IN (
		SELECT ID
		FROM Highschooler
		WHERE name = 'Gabriel'
	)
);


-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade
FROM Likes, Highschooler AS HS1, Highschooler AS HS2
WHERE Likes.ID1 = HS1.ID AND Likes.ID2 = HS2.ID
AND HS1.grade - HS2.grade >= 2;


-- For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade
FROM Likes, Highschooler AS HS1, Highschooler AS HS2
WHERE Likes.ID1 = HS1.ID AND Likes.ID2 = HS2.ID AND HS1.name < HS2.name
AND EXISTS (
	SELECT *
	FROM Likes AS L
	WHERE Likes.ID1 = L.ID2 AND Likes.ID2 = L.ID1
)
ORDER BY HS1.name, HS2.name;


-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.

SELECT name, grade
FROM Highschooler
WHERE ID NOT IN (
	SELECT ID1
	FROM Likes
	UNION
	SELECT ID2
	FROM Likes
);


-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade
FROM Likes, Highschooler AS HS1, Highschooler AS HS2
WHERE Likes.ID1 = HS1.ID AND Likes.ID2 = HS2.ID
AND Likes.ID2 NOT IN (
	SELECT ID1
	FROM Likes
);


-- Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.

SELECT DISTINCT name, grade
FROM Highschooler HS1
WHERE NOT EXISTS (
	SELECT *
	FROM Friend, Highschooler AS HS2
	WHERE Friend.ID2 = HS2.ID AND Friend.ID1 = HS1.ID AND HS1.grade != HS2.grade
)
ORDER BY HS1.grade, HS1.name;


-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.

SELECT DISTINCT HS1.name, HS1.grade, HS2.name, HS2.grade, HS3.name, HS3.grade
FROM Likes, Highschooler AS HS1, Highschooler AS HS2, Highschooler AS HS3, Friend AS F1, Friend AS F2
WHERE Likes.ID1 = HS1.ID AND Likes.ID2 = HS2.ID
AND Likes.ID2 NOT IN (
	SELECT Friend.ID2
	FROM Friend
	WHERE Friend.ID1 = HS1.ID
)
AND F1.ID1 = HS1.ID AND F2.ID1 = HS2.ID AND F1.ID2 = F2.ID2 
AND F1.ID2 = HS3.ID;


-- Find the difference between the number of students in the school and the number of different first names.

SELECT COUNT(*) - COUNT(DISTINCT name)
FROM Highschooler;


-- Find the name and grade of all students who are liked by more than one other student.

SELECT name, grade
FROM Highschooler
WHERE ID IN (
	SELECT ID2
	FROM Likes
	GROUP BY ID2
	HAVING COUNT(*) > 1
);