USE HotelChainDB
GO

DROP TABLE databaseVersion
DROP TABLE versionTable

CREATE TABLE databaseVersion(
  versionID INT PRIMARY KEY)

INSERT databaseVersion(versionID) VALUES
  (0);



CREATE TABLE versionTable(
   versionID INT PRIMARY KEY,
   runProcedure VARCHAR(50),
   undoProcedure VARCHAR(50))
   


INSERT versionTable(versionID,runProcedure,undoProcedure) VALUES
   (1,'modifyColumn','undoModifyColumn'),
   (2,'addColumn','undoAddColumn'),
   (3,'addDefaultConstraint','undoAddDefaultConstraint'),
   (4,'addPrimaryKey','undoPrimaryKey'),
   (5,'addCandidateKey','undoAddCandidateKey'),
   (6,'addForeignKey','undoAddForeignKey'),
   (7,'createTable','undoCreateTable');


DROP PROCEDURE dbo.modifyColumn;  
GO 
DROP PROCEDURE dbo.undoModifyColumn;  
GO 
DROP PROCEDURE dbo.addColumn;  
GO 
DROP PROCEDURE dbo.undoAddColumn;  
GO 
DROP PROCEDURE dbo.addDefaultConstraint;  
GO 
DROP PROCEDURE dbo.undoAddDefaultConstraint;  
GO 
DROP PROCEDURE dbo.addPrimaryKey;  
GO 
DROP PROCEDURE dbo.undoPrimaryKey;  
GO 
DROP PROCEDURE dbo.addCandidateKey;  
GO 
DROP PROCEDURE dbo.undoAddCandidateKey;  
GO 
DROP PROCEDURE dbo.addForeignKey;  
GO 
DROP PROCEDURE dbo.undoAddForeignKey;  
GO 
DROP PROCEDURE dbo.createTable;  
GO 
DROP PROCEDURE dbo.undoCreateTable;  
GO 
DROP PROCEDURE dbo.switchVersion;  
GO 
---a) modify a column / undo
CREATE PROCEDURE modifyColumn
AS 
  ALTER TABLE Visitor
  ALTER COLUMN Bugdet FLOAT
GO


CREATE PROCEDURE undoModifyColumn
AS 
  ALTER TABLE Visitor
  ALTER COLUMN Bugdet INT
GO


---b) add a column / undo
CREATE PROCEDURE addColumn
AS
   ALTER TABLE Hotel
   ADD hotelLocation VARCHAR(100);

GO


CREATE PROCEDURE undoAddColumn
AS
   ALTER TABLE Hotel
   DROP COLUMN hotelLocation

GO  

---c) add a default constraint / undo

CREATE PROCEDURE addDefaultConstraint
AS
   ALTER TABLE Works_IN
   ADD CONSTRAINT constr DEFAULT 0 FOR Salary
GO


CREATE PROCEDURE undoAddDefaultConstraint
AS
   ALTER TABLE Works_IN
   DROP CONSTRAINT constr
GO


---d)add a primary key/ undo

CREATE PROCEDURE addPrimaryKey
AS
   ALTER TABLE Anything
   ADD CONSTRAINT uniqueAddress PRIMARY KEY(ID)
GO


CREATE PROCEDURE undoPrimaryKey
AS
    ALTER TABLE Anything
	DROP CONSTRAINT uniqueAddress
GO

---e)add a candidate key / undo


CREATE PROCEDURE addCandidateKey
AS
   ALTER TABLE BookingSite
   ADD CONSTRAINT uniqueSiteName UNIQUE(SiteName)
GO


CREATE PROCEDURE undoAddCandidateKey
AS
   ALTER TABLE BookingSite
   DROP CONSTRAINT uniqueSiteName
GO

---f)add a foreign key/undo

CREATE PROCEDURE addForeignKey
AS
   ALTER TABLE Room
   ADD CONSTRAINT FK_cleaningEmployee FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID)
GO

CREATE PROCEDURE undoAddForeignKey
AS
  ALTER TABLE Room
  DROP CONSTRAINT FK_cleaningEmployee
GO


---g) create a table / undo

CREATE PROCEDURE createTable
AS
  CREATE TABLE Parking(
  ParkingID INT PRIMARY KEY,
  HotelID INT REFERENCES Hotel(HotelID),
  Capacity INT,
  TicketPricePerDay INT)
GO


CREATE PROCEDURE undoCreateTable
AS
    IF object_id('dbo.Parking') IS NOT NULL
         DROP TABLE Parking
GO


CREATE PROCEDURE switchVersion(@new_version INT) AS
BEGIN
  DECLARE @currentVersion INT
  DECLARE @run_procedure VARCHAR(50)

  SET @currentVersion = (SELECT V.versionID
                         FROM databaseVersion V
						 )
  WHILE @currentVersion < @new_version
  BEGIN
      SET @currentVersion = @currentVersion + 1
	  SET @run_procedure = (SELECT VT.runProcedure
	                        FROM versionTable VT
							WHERE @currentVersion = VT.versionID)
	  EXEC @run_procedure
	  print 'Run procedure :'
	  print @run_procedure
  END

  WHILE @currentVersion > @new_version
  BEGIN
	  SET @run_procedure = (SELECT VT.undoProcedure
	                        FROM versionTable VT
							WHERE @currentVersion = VT.versionID)
	  EXEC @run_procedure
	  SET @currentVersion = @currentVersion - 1
	  print 'Run procedure :'
	  print @run_procedure

  END
  
  UPDATE databaseVersion
  SET versionID = @currentVersion

END
GO




EXEC switchVersion 2

SELECT * FROM databaseVersion