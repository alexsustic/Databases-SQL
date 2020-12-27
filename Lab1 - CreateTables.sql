DROP TABLE Promoted
DROP TABLE BookingSite
DROP TABLE Works_IN
DROP TABLE Reservation
DROP TABLE Duties
DROP TABLE Room
DROP TABLE Employee
DROP TABLE Visitor
DROP TABLE Hotel
DROP TABLE Manager
DROP TABLE Anything


CREATE TABLE Manager
(ManagerID INT PRIMARY KEY,
FirstName VARCHAR(50),
LastName VARCHAR(50)
)
CREATE TABLE Hotel
(HotelID INT PRIMARY KEY,
 ManagerID INT REFERENCES Manager(ManagerID),
 HotelName VARCHAR(50),
 Capacity INT)


CREATE TABLE Employee
( EmployeeID INT PRIMARY KEY,
  FirstName VARCHAR(50),
  LastName VARCHAR(50),
  Position VARCHAR(50)
)

CREATE TABLE Works_IN
(
  HotelID INT REFERENCES Hotel(HotelID),
  EmployeeID INT REFERENCES Employee(EmployeeID),
  Salary INT,
  PRIMARY KEY(HotelID, EmployeeID)
)

CREATE TABLE Visitor
( VisitorID INT PRIMARY KEY,
  FirstName VARCHAR(50),
  LastName VARCHAR(50),
  Bugdet INT
)

CREATE TABLE Room
( RoomID INT PRIMARY KEY,
  EmployeeID INT,
  Price INT,
  Number_persons INT,
  HotelID INT REFERENCES Hotel(HotelID),
)

CREATE TABLE Reservation
(
  RoomID INT REFERENCES Room(RoomID),
  VisitorID INT REFERENCES Visitor(VisitorID),
  CheckOut DATE,
  PRIMARY KEY(VisitorID, RoomID)
)

CREATE TABLE Duties
(
  EmployeeID INT REFERENCES Employee(EmployeeID),
  VisiterID INT REFERENCES Visitor(VisitorID),
  DutyDescription VARCHAR(100),
  PRIMARY KEY(EmployeeID, VisiterID)
)

CREATE TABLE BookingSite
(
    SiteID INT PRIMARY KEY,
	SiteName VARCHAR(50),
	WebAdress VARCHAR(100)

)

CREATE TABLE Promoted(
  HotelID INT REFERENCES Hotel(HotelID),
  SiteID INT REFERENCES BookingSite(SiteID),
  HotelDescription VARCHAR(200)
  PRIMARY KEY(HotelID, SiteID)
)

CREATE TABLE Anything(
  ID int NOT NULL,
  Column1 VARCHAR(50),
  Column2 VARCHAR(50))