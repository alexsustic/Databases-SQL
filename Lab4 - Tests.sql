USE HotelChainDB
GO

--- PROCEDURES FOR INSERTING/DELETING RANDOM ENTITIES INTO/FROM TABLES

CREATE OR ALTER PROCEDURE insertIntoTableVisitor(@rows INT) AS
BEGIN
  DECLARE @index INT
  SET @index = 1
  WHILE @index <= @rows
    BEGIN
	INSERT Visitor(VisitorID,FirstName,LastName,Bugdet) VALUES 
	(@index,CONVERT(VARCHAR(20),NEWID()),CONVERT(VARCHAR(255),NEWID()),Rand()*(8000 - 150) + 150);
	SET @index = @index + 1
	END
END
GO



CREATE OR ALTER PROCEDURE deleteTableVisitor(@rows INT) AS
BEGIN
  DECLARE @index INT
  SET @index = 1
  WHILE @index <= @rows
    BEGIN
	   DELETE FROM Visitor
	   WHERE Visitor.VisitorID = @index
	SET @index = @index + 1
	END
END
GO



CREATE OR ALTER PROCEDURE insertIntoTableRoom(@rows INT) AS
BEGIN
  DECLARE @index INT
  DECLARE @hotelID INT
  SET @index = 1
  WHILE @index <= @rows
    BEGIN
	SET @hotelID = (SELECT TOP 1 HotelID FROM Hotel ORDER BY NEWID())
	INSERT INTO Room(RoomID,Price,Number_persons,HotelID) VALUES 
	(@index,(SELECT CAST(Rand()*(1000 - 20) + 20 AS INT)),(SELECT CAST (Rand()*(6 - 1) + 1 AS INT)), @hotelID);
	SET @index = @index + 1
	END
END
GO


CREATE OR ALTER PROCEDURE deleteTableRoom(@rows INT) AS
BEGIN
  DECLARE @index INT
  SET @index = 1
  WHILE @index <= @rows
    BEGIN
	   DELETE TOP(1) FROM Room
	   
	SET @index = @index + 1
	END
END
GO

CREATE OR ALTER PROCEDURE insertIntoTablePromoted(@rows INT) AS
BEGIN
  DECLARE @index INT
  DECLARE @hotelID INT
  DECLARE @siteID INT
  SET @index = 1
  WHILE @index <= @rows
    BEGIN
	
	SET @hotelID = (SELECT TOP 1 HotelID FROM Hotel ORDER BY NEWID())
	SET @siteID = (SELECT TOP 1 SiteID FROM BookingSite ORDER BY NEWID())
	BEGIN TRY

	INSERT Promoted(HotelID,SiteID,HotelDescription) VALUES 
	 (@hotelID,@siteID,CONVERT(VARCHAR(255),NEWID()));

	END TRY
	BEGIN CATCH

	  set @index = @index - 1

	END CATCH
	SET @index = @index + 1
	END
END
GO




CREATE OR ALTER PROCEDURE deleteTablePromoted(@rows INT) AS
BEGIN
  DECLARE @index INT
  SET @index = 1
  WHILE @index <= @rows
    BEGIN
	   DELETE TOP (1) FROM Promoted
	SET @index = @index + 1
	END
END
GO


--- CREATE VIEWS 

CREATE OR ALTER VIEW DisplayVisitors AS
  SELECT* FROM Visitor
GO


CREATE OR ALTER VIEW DisplayPromotedHotelsGreaterCapacity AS
  SELECT DISTINCT H.HotelName
  FROM Hotel H, Promoted P
  WHERE P.HotelID = H.HotelID AND H.Capacity > 500
GO


CREATE OR ALTER VIEW DisplayRoomsBelongingtoHotels AS
  SELECT Room.RoomID,AVG(Hotel.Capacity) AS HotelCapacity FROM Room
  FULL JOIN Hotel ON Hotel.HotelID = Room.HotelID
  GROUP BY Room.RoomID
GO


--- PROCEDURE FOR EXECUTING THE TESTS
CREATE PROCEDURE executeTests(@test VARCHAR(50)) AS
 BEGIN
   
     IF @test NOT IN (SELECT T.Name FROM Tests T)
	    BEGIN
		  RAISERROR('This test does not exists!',16,1)
		  RETURN
		END
     
	 DECLARE @testID INT
	 SET @testID = (SELECT T.TestID FROM Tests T WHERE T.Name = @test)

	-- WE SET THE CORRECT POSITION USED FOR STORING DATA ABOUT THE PERFORMED TEST
	 DECLARE @lastTestRunID INT
	 SET @lastTestRunID = (SELECT MAX(TestRunID)+1 FROM TestRuns)
	 IF @lastTestRunID IS NULL
	   BEGIN
	   SET @lastTestRunID = 1
	   END
	 
	SET IDENTITY_INSERT TestRuns ON
    INSERT INTO TestRuns (TestRunID, Description)values (@lastTestRunID, 'The time results of executing this test')
    SET IDENTITY_INSERT TestRuns OFF

	 DECLARE @startAllTests DATETIME2
	 DECLARE @endAllTests DATETIME2

	 -- WE RETAIN THE TIME WHEN WE STARTED ALL TESTS
	 SET @startAllTests = SYSDATETIME()

	 -- WE INITIALIZE THE CURSOR USED FOR PARSING (TestTables+Tables) , EXTRACTING DATA ABOUT TABLE_ID, TABLE_NAME AND THE NUMBER OF ROWS
	 DECLARE tableCursor CURSOR SCROLL FOR
	    SELECT Tables.TableID, Tables.Name, TestTables.NoOfRows
		FROM TestTables INNER JOIN Tables ON TestTables.TableID = Tables.TableID
		WHERE TestTables.TestID = @testID
		ORDER BY TestTables.Position
     
	 DECLARE @tableID INT
	 DECLARE @tableName VARCHAR(50)
	 DECLARE @nrRows INT
	 DECLARE @action VARCHAR(150)

	 OPEN tableCursor 
	 FETCH LAST FROM tableCursor 
	 INTO @tableID, @tableName,@nrRows

	 DECLARE @startTest DATETIME2
	 DECLARE @endTest DATETIME2

	 WHILE @@FETCH_STATUS = 0
	    BEGIN
		   SET @action = 'insertIntoTable' + @tableName
		   SET @startTest = SYSDATETIME()
		   EXEC @action @nrRows
		   SET @endTest = SYSDATETIME()

		   --- WE WRITE THE RESULTS OF THE TEST IN TestRunTables
		   INSERT INTO TestRunTables (TestRunID, TableID, StartAt, EndAt) VALUES
		   (@lastTestRunID, @tableID, @startTest, @endTest)

		   FETCH PRIOR FROM tableCursor
		   INTO @tableID, @tableName, @nrRows
		END

	 CLOSE tableCursor
	 
	  -- WE INITIALIZE THE CURSOR USED FOR PARSING (Views + TestViews) , EXTRACTING DATA ABOUT THE NAME OF THE VIEW AND THE VIEW'S ID
	  DECLARE viewCursor CURSOR FOR
	      SELECT V.Name, V.ViewID
		  FROM Views V INNER JOIN TestViews T ON V.ViewID = T.ViewID
		  WHERE T.TestID = @testID

	  DECLARE @viewID INT
	  DECLARE @viewName VARCHAR(50)
      
	  OPEN viewCursor 
	  FETCH viewCursor 
	  INTO @viewName, @viewID

	  WHILE @@FETCH_STATUS = 0
	    BEGIN
		SET @action = 'SELECT * FROM ' + @viewName
		SET @startTest = SYSDATETIME()
		EXEC (@action)
		SET @endTest = SYSDATETIME()

		--- WE WRITE INTO TestRunViews THE RESULTS OF THE TEST
		INSERT INTO TestRunViews(TestRunID,ViewID,StartAt,EndAt) VALUES
		(@lastTestRunID,@viewID,@startTest,@endTest)

		FETCH viewCursor
		INTO @viewName, @viewID

		END

	  CLOSE viewCursor
	  DEALLOCATE viewCursor

	  	  -- WE OPEN AGAIN THE CURSOR USED FOR PARSING (TestTables+Tables) IN ORDER TO DELETE WHAT WE'VE INSERTED
	  OPEN tableCursor 
	  FETCH tableCursor 
	  INTO @tableID, @tableName,@nrRows

	  WHILE @@FETCH_STATUS = 0
	    BEGIN
		SET @action= 'deleteTable' + @tableName
		SET @startTest = SYSDATETIME()
		EXEC @action @nrRows
		SET @endTest = SYSDATETIME()

		--- WE WRITE INTO testRunTables THE RESULTS OF THE TEST
		INSERT INTO TestRunTables(TestRunID,TableID,StartAt,EndAt) VALUES
		(@lastTestRunID,@tableID,@startTest,@endTest)

		FETCH tableCursor
		INTO @tableID, @tableName,@nrRows

		END

	  SET @endAllTests = SYSDATETIME()
      CLOSE tableCursor
	  DEALLOCATE tableCursor

	  --- WE WRITE INTO TestRuns TABLE THE FINAL RESULTS
	  UPDATE TestRuns
	  SET StartAt = @startAllTests, EndAt = @endAllTests
	  WHERE TestRunID = @lastTestRunID

 END
 GO


 --- POPULATE TEST TABELS AND CONNECT THE TESTS
 INSERT INTO Tests(Name) VALUES
  ('Test1'),
  ('Test2'),
  ('Test3');


INSERT INTO Tables(Name) VALUES
  ('Visitor'),
  ('Room'),
  ('Promoted');

INSERT INTO Views(NAME) VALUES
  ('DisplayVisitors'),
  ('DisplayPromotedHotelsGreaterCapacity'),
  ('DisplayRoomsBelongingtoHotels');
 

INSERT INTO TestTables(TestID,TableID,NoOfRows,Position) VALUES
  ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test1'),(SELECT T.TableID FROM Tables T WHERE T.Name = 'Visitor'),50,1),
  ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test2'),(SELECT T.TableID FROM Tables T WHERE T.Name = 'Promoted'),20,2),
  ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test3'),(SELECT T.TableID FROM Tables T WHERE T.Name = 'Room'),150,3),
  ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test1'),(SELECT T.TableID FROM Tables T WHERE T.Name = 'Room'),50,4);

 
INSERT INTO TestViews(TestID,ViewID) VALUES
 ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test1'),(SELECT V.ViewID FROM Views V WHERE V.Name = 'DisplayVisitors')),
 ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test2'),(SELECT V.ViewID FROM Views V WHERE V.Name = 'DisplayPromotedHotelsGreaterCapacity')),
 ((SELECT T.TestID FROM Tests T WHERE T.Name = 'Test3'),(SELECT V.ViewID FROM Views V WHERE V.Name = 'DisplayRoomsBelongingtoHotels'));

 EXEC executeTests 'Test1'
 EXEC executeTests 'Test2'
 EXEC executeTests 'Test3'
 
 SELECT * FROM TestRunTables
 SELECT * FROM TestRunViews
 SELECT * FROM TestRuns

 DROP PROCEDURE executeTests
 SELECT * FROM Manager
 DELETE FROM TestRunTables
 DELETE FROM TestRuns
 DELETE FROM TestRunViews
 
 

 