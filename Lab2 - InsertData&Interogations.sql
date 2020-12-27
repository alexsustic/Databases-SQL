USE HotelChain
GO

DELETE 
FROM Duties

DELETE 
FROM Reservation

DELETE 
FROM Works_IN

DELETE 
FROM Employee

DELETE
FROM Promoted

DELETE 
FROM Visitor

DELETE
FROM Room

DELETE
FROM BookingSite

DELETE
FROM Hotel

DELETE
FROM Manager



INSERT Manager(ManagerID, FirstName, LastName) VALUES
(1, 'Shelby' , 'Thomas'),
(2, 'Lock', 'John'),
(3, 'Maine' , 'Anna'),
(4, 'Thorne', 'Park');



INSERT Hotel(HotelID, ManagerID, HotelName, Capacity) VALUES
(1,1,'Lustrio Inn',30),
(2,1,'Coast Hotels',50),
(3,2,'Primland',20),
(4,2,'Happy Mornings Hotel',20),
(5,3,'Paramount Hotel',70),
(6,1,'Luvaria',100),
(7,2,'Wonderland',600),
(8,3,'Sunset',150);



INSERT BookingSite(SiteID, SiteName, WebAdress) VALUES
(1, 'Booking', 'www.booking.com'),
(2, 'TripAdvisor', 'www.tripadvisor.com'),
(3, 'Trivago', 'www.trivago.com'),
(4, 'Agoda', 'www.agoda.com'),
(5, 'PerfectMatch', 'www.perfectMatch.com');


INSERT Promoted(HotelID,SiteID,HotelDescription) VALUES
(1,1, 'An amazing hotel with a beautiful view'),
(1,3, 'An amazing hotel with a beautiful view'),
(3,2, 'An enourmous hotel , exceptional for vacations and conferences'),
(2,4, 'A hotel design after the scandanavian style, exceptional for those who are looking for peaceful moments');



INSERT Visitor(VisitorID, FirstName, LastName, Bugdet) VALUES
(1,'Timis', 'Adriana', 150),
(2, 'Andrei', 'Zavorodnic', 200 ),
(3, 'Sustic', 'Alessandro', 300 ),
(4, 'Tibre', 'Diana', 250),
(5, 'Tamas', 'Timotei', 250 ),
(6, 'Rus', 'Andreea', 10000 );


INSERT Room(RoomID, Price, Number_persons, HotelID) VALUES
(1,150, 2, 1),
(2,200, 1, 3),
(3,700, 3, 1),
(4,50, 2, 4),
(5,150, 1, 5),
(6,300, 2, 2);


INSERT Reservation(RoomID, VisitorID, CheckOut) VALUES
(1,1,'2020-05-01'),
(1,2,'2020-05-01'),
(3,6,'2020-05-10'),
(4,4,'2020-05-20'),
(5,5,'2020-05-16');


INSERT Employee(EmployeeID,FirstName,LastName,Position) VALUES
(1,'Jones','Tom', 'Bartender'),
(2,'Ford','Madison', 'Server'),
(3,'Timis','Anca', 'Server'),
(4,'Flay','Booby', 'Cook'),
(5,'Child','Julia', 'Cook'),
(6,'Tudorescu','Alexandra', 'Receptionist');


INSERT Works_IN(HotelID, EmployeeID, Salary) VALUES
(1,1,2000),
(2, 1, 2500),
(1,2,1500),
(2,3,1700),
(1,4,4000),
(3,3,1800),
(4,6,2500);



INSERT Duties(EmployeeID, VisiterID, DutyDescription) VALUES
(1,1,'Prepared their drinks on their stay'),
(1,2, 'Prepared their drinks on their stay'),
(2,4, 'Served the food !'),
(3,5,'Served the food and the drinks'),
(4,1,'Prepared the food on their stay');


SELECT * FROM Manager
SELECT * From Hotel
SELECT *From BookingSite
SELECT *FROM Room
SELECT *FROM Promoted
SELECT *FROM Works_IN
SELECT *FROM Visitor
SELECT *FROM Reservation
SELECT *FROM Employee
SELECT *FROM Duties


UPDATE HOTEL 
SET ManagerID = 3, Capacity = 60
WHERE ManagerID = 2 AND Capacity < 50

UPDATE Promoted
SET HotelDescription = 'Cheap and profitable! You will not regret !'
WHERE HotelID BETWEEN 1 AND 2

UPDATE Manager
SET FirstName = 'Baggins', LastName= 'Bilbo'
WHERE ManagerID = 3

DELETE 
FROM Manager
WHERE FirstName LIKE 'T_%'

DELETE
FROM Promoted
WHERE NOT SiteID <=3 

-- a) 2 queries with the union operation; use UNION [ALL] and OR : 

--- Show me the top 10 hotel names administrated by managers such as Shelby Thomas or Lock John
SELECT TOP 10 H.HotelName
FROM Hotel H
WHERE H.ManagerID = 1 OR H.ManagerID = 2
ORDER BY H.HotelName

--- Show me top 5 hotel names administrated by managers such as Shelby Thomas or Maine Anna

SELECT TOP 5 H1.HotelName
FROM Hotel H1
WHERE H1.ManagerID = 1 
UNION ALL
SELECT H2.HotelName
FROM Hotel H2
WHERE H2.ManagerID = 3
ORDER BY H1.HotelName


-- b) 2 queries with the intersection operation; use INTERSECT and IN :


--- Show me all the hotels name administrated by Shelby Thomas, that have rooms for at least 40 persons
SELECT H1.HotelName
FROM Hotel H1
WHERE H1.ManagerID = 1 
INTERSECT
SELECT H2.HotelName
FROM Hotel H2
WHERE H2.Capacity > 40

--- Show me all the hotels which we can find on Booking site

SELECT H1.HotelName
FROM Hotel H1
WHERE H1.HotelID  IN
      (SELECT P.HotelID 
	   FROM Promoted P
	   WHERE P.SiteID = 1)

--- c) 2 queries with the difference operation; use EXCEPT and NOT IN :
 
--- Show me all the hotels administrated by Thomas Shelby , except those with a capacity smaller than 50
SELECT H1.HotelName
FROM Hotel H1
WHERE H1.ManagerID = 1
EXCEPT
SELECT H2.HotelName
FROM Hotel H2
WHERE H2.Capacity < 50



--- Show me all the visitors names , except those having a budget smaller than 300

SELECT V1.FirstName, V1.LastName
FROM Visitor V1
WHERE V1.VisitorID NOT IN
   (
     SELECT  V2.VisitorID
	 FROM Visitor V2
	 WHERE V2.Bugdet < 300
   );


--- d) 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator); one query will join at least 3 tables, 
---       while another one will join at least two many-to-many relationships;


--- inner join
--- Show me all the visitors names , that checked in , displaying also how much they paid
SELECT V.FirstName, V.LastName, R.Price
FROM Visitor V
INNER JOIN Reservation R1 ON R1.VisitorID = V.VisitorID
INNER JOIN Room R ON R.RoomID = R1.RoomID

--- left join 
--- Show me all the visitors names, and at which hotel they checked in

SELECT V.FirstName, V.LastName, H.HotelName
FROM Visitor V
LEFT JOIN Reservation R1 ON R1.VisitorID = V.VisitorID
LEFT JOIN Room R ON R.RoomID = R1.RoomID
LEFT JOIN Hotel H ON R.HotelID = H.HotelID


--- right join 
--- Show me all the canditates name for a job , and at which hotel they are currently working

SELECT E.FirstName, E.LastName, H.HotelName
FROM Hotel H
RIGHT JOIN Works_IN W ON W.HotelID =H.HotelID
RIGHT JOIN Employee E ON E.EmployeeID = W.EmployeeID

---full join (2 many to many relationships)
--- Show me the employee's details such as name ,job position and salary , and who visitor they helped and how during their stay (daily activity for each employee)

SELECT E.FirstName, E.LastName, E.Position,W.Salary, V.FirstName, V.LastName, D.DutyDescription
FROM Employee E 
FULL JOIN Works_IN W ON W.EmployeeID = E.EmployeeID
FULL JOIN Duties D ON D.EmployeeID = E.EmployeeID 
FULL JOIN Visitor V ON D.VisiterID = V.VisitorID

---e) 2 queries with the IN operator and a subquery in the WHERE clause; in at least one case, the subquery should include a subquery in its own WHERE clause

--- Show me the name of the employees, that works for visters which are checked in Lustrio Inn

SELECT E.FirstName, E.LastName
FROM Employee E
WHERE E.EmployeeID IN
    (SELECT D.EmployeeID
     FROM Duties D
	 WHERE D.VisiterID IN
	      (SELECT R.VisitorID
		   FROM Reservation R
		   WHERE R.RoomID IN
		         (SELECT R2.RoomID
			      FROM Room R2
			      WHERE R2.HotelID = 1
		          )
		  )
	 )

--- Show me the visitors' name that stay at the hotel between 2020-05-15 and 2020-05-25

SELECT V.FirstName, V.LastName
FROM Visitor V
WHERE V.VisitorID IN
    (SELECT R.VisitorID
	 FROM Reservation R
	 WHERE R.CheckOut <= '20200525' AND R.CheckOut>='20200515')


--- f) 2 queries with the EXISTS operator and a subquery in the WHERE clause

---Show me the employees' name which are servers and have a salary greater than 1600

SELECT E.FirstName, E.LastName
FROM Employee E
WHERE EXISTS
  (SELECT *
   FROM Works_IN W
   WHERE W.Salary > 1600 AND E.Position = 'Server' AND W.EmployeeID = E.EmployeeID)

---Show me details aboout the rooms which are empty (room number, capacity, price, and the hotel name )

SELECT R.RoomID , R.Number_persons, R.Price, H.HotelName
FROM Room R 
INNER JOIN Hotel H ON R.HotelID = H.HotelID
WHERE NOT EXISTS
 (
   SELECT *
   FROM Reservation R1
   WHERE R1.RoomID = R.RoomID 
 )

 --- g) 2 queries with a subquery in the FROM clause;

 --- Show me all the cooks that are currently working in this hotel chain

SELECT FirstName, LastName
FROM   
 (
   SELECT E.FirstName AS FirstName, E.LastName AS LastName
   FROM Employee E, Works_IN W 
   WHERE E.Position = 'cook'  AND W.EmployeeID = E.EmployeeID AND W.Salary > 0
 ) AS S;


 --- Show me all the rooms' number and the hotel's name from this hotel chain which have places for at least 2 persons

SELECT RoomNo, hotelName
FROM
(SELECT R.RoomID AS RoomNo, H.HotelName AS hotelName
 FROM Room R
 INNER JOIN Hotel H  ON H.HotelID = R.HotelID
 WHERE R.Number_persons >= 2) AS t;

--- h) 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 2 of the latter will also have a subquery in the HAVING clause; 
---      use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;


--- Show me how many hotels administrates each manager (except those who doesn't administrates hotels at all)

SELECT M.FirstName,COUNT(H.ManagerID) as NoHotels
FROM Manager M, Hotel H
WHERE H.ManagerID = M.ManagerID
GROUP BY M.FirstName
HAVING COUNT(H.ManagerID) > 0;




--- Show me the average price of each hotel

SELECT H.HotelName , AVG(Price) AS averagePrice
FROM Hotel H, Room R
WHERE R.HotelID = H.HotelID 
GROUP BY H.HotelName 

--- Group rooms  after capacity, and displays that one which is the most expensive(from that category) and has its price > 200

SELECT R.Number_persons, MAX(Price) AS Price
FROM Room R 
GROUP BY R.Number_persons
HAVING 200 <= (  SELECT MAX(Price)
                 FROM Room R1
				 WHERE R1.Number_persons = R.Number_persons)




--- Group employees after position, showing those best paid positions which have a minimum salary of 2000

SELECT E.Position
FROM Employee E, Works_IN W
GROUP BY E.Position
HAVING 2000 <= ( SELECT MAX(Salary) 
                 FROM Works_IN W1, Employee E1
				 WHERE E1.Position = E.Position AND E1.EmployeeID = W1.EmployeeID)




--- i) 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator); rewrite 2 of them with aggregation operators
---    , and the other 2 with IN / [NOT] IN.

--- Show me the employees, which are paid more than all the servers from this hotel chain

SELECT DISTINCT E.FirstName, E.LastName 
FROM Employee E, Works_IN W 
WHERE E.EmployeeID = W.EmployeeID AND W.Salary > ALL (SELECT W1.Salary 
                                                       FROM Employee E1, Works_IN W1
													   WHERE W1.EmployeeID = E1.EmployeeID AND E1.Position = 'Server')

--- OR (with aggregation)

SELECT DISTINCT E.FirstName, E.LastName 
FROM Employee E, Works_IN W 
WHERE E.EmployeeID = W.EmployeeID AND W.Salary >  (SELECT MAX(W1.Salary) 
                                                   FROM Employee E1, Works_IN W1
												   WHERE W1.EmployeeID = E1.EmployeeID AND E1.Position = 'Server')


--- Show me the room/ (rooms if exists) that are going to be first avaiable after guests leaves

SELECT DISTINCT R.RoomID, H.HotelName
FROM Room R, Hotel H, Reservation R1
WHERE R.HotelID = H.HotelID AND R1.RoomID = R.RoomID AND R1.CheckOut <= ALL (SELECT R2.CheckOut
                                                                            FROM Reservation R2
                                                                            ) 
--- OR (with aggregation)

SELECT DISTINCT R.RoomID, H.HotelName
FROM Room R, Hotel H, Reservation R1
WHERE R.HotelID = H.HotelID AND R1.RoomID = R.RoomID AND R1.CheckOut <=    (SELECT MIN(R2.CheckOut)
                                                                            FROM Reservation R2
                                                                            ) 


--- Show me any room which is going to be free after 2020-05-15
SELECT DISTINCT R.RoomID, H.HotelName
FROM Room R, Hotel H, Reservation R1
WHERE R.HotelID = H.HotelID AND R1.RoomID = R.RoomID AND R1.CheckOut >= ANY (SELECT R2.CheckOut
                                                                            FROM Reservation R2
																			WHERE R2.CheckOut > '20200515')

--- OR(with NOT IN)

SELECT DISTINCT R.RoomID, H.HotelName
FROM Room R, Hotel H, Reservation R1
WHERE R.HotelID = H.HotelID AND R1.RoomID = R.RoomID AND R1.CheckOut NOT IN (SELECT R2.CheckOut
                                                                             FROM Reservation R2
																			 WHERE R2.CheckOut < '20200515')



--- Show me which visitor can spend more 200$ extra for better services (among with the cost of any room from this hotel chain) 

SELECT DISTINCT V.FirstName, V.LastName
FROM Visitor V
WHERE V.Bugdet - 200 >= ANY  (SELECT R.Price
                              FROM Room R
							  ) 

--- OR(with IN)

SELECT DISTINCT V.FirstName, V.LastName
FROM Visitor V
WHERE V.VisitorID IN (    SELECT V1.VisitorID
                          FROM Visitor V1, Room R1
						  WHERE V1.Bugdet - R1.Price >= 200) 
