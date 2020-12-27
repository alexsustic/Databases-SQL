
DROP TABLE HotelDepartment
DROP TABLE Supervisor
DROP TABLE Executive

--- Tc
CREATE TABLE HotelDepartment
(
  DepartmentID INT PRIMARY KEY,
  ExecutiveID INT REFERENCES Executive(ExecutiveID),
  SupervisorID INT REFERENCES Supervisor(SupervisorID)
)


--- Tb
CREATE TABLE Supervisor
(
  SupervisorID INT PRIMARY KEY,
  CNP INT,
  FullName VARCHAR(100)
)

--- Ta
CREATE TABLE Executive
(
  ExecutiveID INT PRIMARY KEY,
  IdentityCardNumber INT UNIQUE,
  IdentityCardSeries VARCHAR(50),
  FullName VARCHAR(100)
)

--- a)

---    -> clustered index scan
   SELECT ExecutiveID FROM Executive WHERE Executive.IdentityCardSeries='MM'

---    -> clustered index seek
   SELECT FullName FROM Executive WHERE Executive.ExecutiveID > 5

---    -> non-clustered index scan
   SELECT IdentityCardNumber FROM Executive 

---    -> non-clustered index seek
   SELECT ExecutiveID FROM Executive WHERE Executive.IdentityCardNumber BETWEEN 200000 AND 201000
    
---    -> key lookup
   SELECT IdentityCardSeries,FullName FROM Executive WHERE Executive.IdentityCardNumber = 201000
   

--- b)  

 SELECT * FROM Supervisor WHERE Supervisor.CNP = 501234

   --- before creating the non-clustered index : 0.0158524

   CREATE NONCLUSTERED INDEX index_tblSupervisor_CNP ON Supervisor(CNP ASC)

   --- after creating the non-clustered index :  0.0032831 (smaller than the previous result => better execution, faster)


   DROP INDEX index_tblSupervisor_CNP ON Supervisor


--- c)
  GO
  CREATE OR ALTER VIEW HotelDepartmentAndSupervisor AS
     SELECT HotelDepartment.DepartmentID, HotelDepartment.SupervisorID
	 FROM HotelDepartment INNER JOIN Supervisor on HotelDepartment.SupervisorID = Supervisor.SupervisorID
	 WHERE HotelDepartment.SupervisorID > 1000
  GO

	 SELECT * FROM HotelDepartmentAndSupervisor
  --- initial results, with no modifications : -> clustered index seek : 0.0095672
  ---                                          -> clustered index scan : 0.0058635
  

    CREATE NONCLUSTERED INDEX index_tblHotelDepartmentAndSupervisor_SupervisorID ON HotelDepartment(SupervisorID ASC)
   
  --- results after creating a new non-clustered index : ->clustered index seek: 0.0095672
  ---                                                    ->non-clustered index seek: 0.0045782 (this cost is smaller => faster)


   DROP INDEX index_tblHotelDepartmentAndSupervisor_SupervisorID ON HotelDepartment







 --- Populate tables 
 GO
 CREATE PROCEDURE populateTableExecutive AS
 BEGIN
    DECLARE @index INT
	SET @index = 1
	CREATE TABLE Regions(Region VARCHAR(50))
	INSERT INTO Regions(Region) VALUES
	('MM'), ('CJ'), ('TM'), ('VL'), ('BC'),('B'), ('BN'), ('IF'),('TL');
	while @index <= 2000
	  BEGIN
	  INSERT INTO Executive(ExecutiveID,IdentityCardNumber,IdentityCardSeries,FullName) VALUES
	  (@index, @index + 200000, (SELECT TOP 1 Region FROM Regions ORDER BY NEWID()),CONVERT(VARCHAR(255),NEWID()));
	  SET @index = @index + 1
	  END
	DROP TABLE Regions
 END

 GO



 CREATE PROCEDURE populateTableSupervisor AS
 BEGIN
    DECLARE @index INT
	SET @index = 1
	while @index <= 2000
	  BEGIN
	  INSERT INTO Supervisor(SupervisorID,CNP,FullName) VALUES
	  (@index, @index + 500000,CONVERT(VARCHAR(255),NEWID()));
	  SET @index = @index + 1
	  END
 END

 GO

 CREATE PROCEDURE populateTableHotelDepartment AS
 BEGIN
  DECLARE @index INT
  DECLARE @executiveID INT
  DECLARE @supervisorID INT
  SET @index = 1
  WHILE @index <= 1000
    BEGIN
	
	SET @executiveID = (SELECT TOP 1 ExecutiveID FROM Executive ORDER BY NEWID())
	SET @supervisorID = (SELECT TOP 1 SupervisorID FROM Supervisor ORDER BY NEWID())
	BEGIN TRY

	INSERT HotelDepartment(DepartmentID,ExecutiveID,SupervisorID) VALUES 
	 (@index,@executiveID,@supervisorID);

	END TRY
	BEGIN CATCH

	  set @index = @index - 1

	END CATCH
	SET @index = @index + 1
	END

 END

 EXEC populateTableExecutive
 EXEC populateTableSupervisor
 EXEC populateTableHotelDepartment

 SELECT * FROM HotelDepartment