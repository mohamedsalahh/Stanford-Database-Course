

-- For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade, HS3.name, HS3.grade
FROM Likes AS L1, Likes AS L2, Highschooler AS HS1, 
Highschooler AS HS2, Highschooler AS HS3
WHERE L1.ID2 = L2.ID1 AND L1.ID1 != L2.ID2
AND L1.ID1 = HS1.ID AND L1.ID2 = HS2.ID AND L2.ID2 = HS3.ID;


-- Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.

SELECT name, grade
FROM Highschooler AS HS1
WHERE NOT EXISTS (
	SELECT *
	FROM Highschooler AS HS2, Friend
	WHERE ID2 = HS2.ID AND ID1 = HS1.ID AND HS2.grade = HS1.grade
);


-- What is the average number of friends per student? (Your result should be just one number.)

SELECT AVG(Cnt)
FROM (
	SELECT ID1, COUNT(*) AS Cnt
	FROM Friend
	GROUP BY ID1
) AS Q1;


-- Find the name and grade of the student(s) with the greatest number of friends.

SELECT name, grade
FROM (
	SELECT name, grade, Cnt, DENSE_RANK() OVER(ORDER BY CNT DESC) AS Rnk
	FROM Highschooler, (
		SELECT ID1, COUNT(*) AS Cnt
		FROM Friend
		GROUP BY ID1
	) AS Q1
	WHERE Highschooler.ID = Q1.ID1
) AS Q2
WHERE Q2.Rnk = 1;
