CREATE PROCEDURE AddClient(
    @IsCompany bit,
    @ClientID int output
)
AS
    BEGIN
        INSERT INTO Clients
            VALUES (@IsCompany)
        SET @ClientID = @@IDENTITY
    END

CREATE PROCEDURE AddPersonAsClient(
    @FirstName varchar(50),
    @LastName varchar(50),
    @Email varchar(100),
    @Phone varchar(15),
    @PersonID int output
)
AS
    BEGIN
        SET @PersonID = (SELECT PersonID
                            FROM Persons
                            WHERE Email = @Email)

        DECLARE @ClientID int
        SET @ClientID = (SELECT ClientID
                            FROM Persons
                            WHERE PersonID = @PersonID)

        IF(@PersonID IS NULL)
        BEGIN
            EXEC addClient 0, @ClientID
            INSERT INTO Persons (ClientID, FirstName, LastName, Email, Phone)
                VALUES (@ClientID, @FirstName, @LastName, @Email, @Phone)
            SET @PersonID = @@IDENTITY
        END
        ELSE
        BEGIN
            IF(@ClientID IS NULL)
            BEGIN
                EXEC AddClient 0, @ClientID
                UPDATE Persons SET ClientID = @ClientID WHERE PersonID = @PersonID
            END
        END
    END

CREATE PROCEDURE AddPersonAsParticipant(
    @FirstName varchar(50),
    @LastName varchar(50),
    @Email varchar(100),
    @Phone varchar(15),
    @PersonID int output
)
AS
    BEGIN
        SET @PersonID = (SELECT PersonID
                            FROM Persons
                            WHERE Email = @Email)
        IF(@PersonID IS NULL)
        BEGIN
            INSERT INTO Persons (ClientID, FirstName, LastName, Email, Phone)
                VALUES (NULL, @FirstName, @LastName, @Email, @Phone)
            SET @PersonID = @@IDENTITY
        END
    END

CREATE PROCEDURE AddCompany(
    @CompanyName varchar(100),
    @Email varchar(100),
    @Phone varchar(15),
    @CompanyID int output
)
AS
    BEGIN
        SET @CompanyID = (SELECT CompanyID
                            FROM Companies
                            WHERE Email = @Email)
        IF(@CompanyID IS NULL)
        BEGIN
            DECLARE @ClientID int
            EXEC AddClient 1, @ClientID = @ClientID
            INSERT INTO Companies (ClientID, CompanyName, Email, Phone)
                VALUES (@ClientID, @CompanyName, @Email, @Phone)
            SET @CompanyID = @@IDENTITY
        END
    END

-- Adding new conference
CREATE PROCEDURE AddNewConference
    @Title varchar(100),
    @StartDate date,
    @EndDate date,
    @StudentDiscount float(2),
    @ConferenceID int output
AS
    BEGIN
        INSERT INTO Conferences (Title, StartDate, EndDate, StudentDiscount)
            VALUES (@Title, @StartDate, @EndDate, @StudentDiscount)
        SET @ConferenceID = @@IDENTITY
    END

-- Adding new place
CREATE PROCEDURE  AddNewPlace
    @Street varchar(100),
    @ZipCode varchar(20),
    @City varchar(100),
    @PlaceID int output
AS
    BEGIN
        INSERT INTO Places (Street, ZipCode, City)
            VALUES (@Street, @ZipCode, @City)
        SET @PlaceID = @@IDENTITY
    END

-- Adding discounts to conference
CREATE PROCEDURE AddNewDiscount
    @ConferenceID int,
    @Discount float(2),
    @DaysBeforeConference int,
    @DiscountID int output
AS
    BEGIN
        INSERT INTO Discounts (ConferenceID, Discount, DaysBeforeConference)
            VALUES (@ConferenceID, @Discount, @DaysBeforeConference)
        SET @DiscountID = @@IDENTITY
    END

-- Adding new conference day
CREATE PROCEDURE AddNewDay
    @ConferenceID int,
    @Capacity int,
    @Date date,
    @Price money,
    @DayID int output
AS
    BEGIN
        DECLARE @ConfStart AS date
        DECLARE @ConfEnd AS date

        SET @ConfStart  = (SELECT StartDate
                            FROM Conferences
                            WHERE ConferenceID = @ConferenceID)
        SET @ConfEnd    = (SELECT EndDate
                            FROM Conferences
                            WHERE ConferenceID = @ConferenceID)

        DECLARE @IsAlreadyDayInDB as bit
        SET @IsAlreadyDayInDB = (EXISTS(SELECT 1
                                        FROM Days
                                        WHERE ConferenceID = @ConferenceID
                                          AND Date = @Date))

        IF (@Date >= @ConfStart AND @Date <= @ConfEnd AND @IsAlreadyDayInDB = 0)
        BEGIN
            INSERT INTO Days (ConferenceID, Capacity, Date, Price)
                VALUES (@ConferenceID, @Capacity, @Date, @Price)
            SET @DayID = @@IDENTITY
        END
        ELSE
        BEGIN
            RAISERROR ('Wrong date', 16, 1)
        END
    END

-- Adding new workshop
CREATE PROCEDURE AddNewWorkshop
    @PlaceId int,
    @DayId int,
    @Title varchar(100),
    @Description varchar(300),
    @Price money,
    @Capacity int,
    @Room varchar(20),
    @StartTime time,
    @EndTime time,
    @WorkshopID int output
AS
    BEGIN
        INSERT INTO Workshops (PlaceID, DayID, Title, Description, Price, Capacity, Room, StartTime, EndTime)
            VALUES (@PlaceId, @DayId, @Title, @Description, @Price, @Capacity, @Room, @StartTime, @EndTime)
        SET @WorkshopID = @@IDENTITY
    END

-- Adding new reservation
CREATE PROCEDURE AddNewReservation
    @ClientID int,
    @ReservationDate date,
    @ReservationID int output
AS
    BEGIN
        INSERT INTO Reservations (ClientID, ReservationDate)
            VALUES (@ClientID, @ReservationDate)
        SET @ReservationID = @@IDENTITY
    END

-- Adding new payments
CREATE PROCEDURE AddNewPayment
    @ReservationID int,
    @Amount float(2),
    @DateOfIncome date,
    @PaymentID int output
AS
    BEGIN
        INSERT INTO Payments (ReservationID, Amount, DateOfIncome)
            VALUES (@ReservationID, @Amount, @DateOfIncome)
        SET @PaymentID = @@IDENTITY
    END

-- Adding day reservation
CREATE PROCEDURE AddNewDayReservation
    @ReservationID int,
    @DayID int,
    @NumberOfNormalTickets int,
    @NumberOfStudentTickets int,
    @DayReservationID int output
AS
    BEGIN
        DECLARE @DayCapacity AS int
        DECLARE @ReservedDaySlots AS int

        SET @DayCapacity        = (SELECT Capacity
                                    FROM Days
                                    WHERE DayID = @DayID)
        SET @ReservedDaySlots   = (SELECT SUM(NumberOfNormalTickets) + SUM(NumberOfStudentTickets)
                                    FROM DayReservations
                                    WHERE DayID = @DayID
                                      AND IsCancelled = 0)

        IF (@ReservedDaySlots + @NumberOfNormalTickets + @NumberOfStudentTickets <= @DayCapacity)
        BEGIN
            INSERT INTO DayReservations (ReservationID, DayID, NumberOfNormalTickets, NumberOfStudentTickets)
                VALUES (@ReservationID, @DayID, @NumberOfNormalTickets, @NumberOfStudentTickets)
            SET @DayReservationID = @@IDENTITY
        END
        ELSE
        BEGIN
            RAISERROR ('Day capacity exceeded', 16, 1)
        END
    END

-- Adding workshops reservation
CREATE PROCEDURE AddNewWorkshopReservation
    @DayReservationID int,
    @WorkshopID int,
    @NumberOfTickets int
AS
    BEGIN
        DECLARE @WorkshopCapacity AS int
        DECLARE @ReservedWorkshopSlots AS int

        SET @WorkshopCapacity       = (SELECT Capacity
                                        FROM Days
                                        WHERE DayID = @DayID)
        SET @ReservedWorkshopSlots  = (SELECT SUM(NumberOfTickets)
                                        FROM WorkshopReservations
                                        WHERE WorkshopID = @WorkshopID
                                          AND IsCancelled = 0)

        IF (@ReservedWorkshopSlots + @NumberOfTickets <= @WorkshopCapacity)
        BEGIN
            INSERT INTO WorkshopReservations (DayReservationID, WorkshopID, NumberOfTickets)
                VALUES (@DayReservationID, @WorkshopID, @NumberOfTickets)
        END
        ELSE
        BEGIN
            RAISERROR ('Workshop capacity exceeded', 16, 1)
        END
    END

-- Adding Participant to Day Reservation
CREATE PROCEDURE AddPersonToDayReservations
    @PersonID int,
    @DayReservationID int,
    @IsStudent bit
AS
    BEGIN
        IF (@IsStudent = 0)
        BEGIN
            DECLARE @NumberOfNormalTickets AS int
            DECLARE @NumberOfBookedPeople AS int

            SET @NumberOfNormalTickets = (SELECT NumberOfNormalTickets
                                            FROM DayReservations
                                            WHERE DayReservationID = @DayReservationID
                                              AND IsCancelled = 0)
            SET @NumberOfBookedPeople = (SELECT COUNT(PersonID)
                                            FROM DayReservationsPersons
                                            WHERE PersonID = @PersonID
                                              AND NOT IsStudent)

            IF (@NumberOfNormalTickets > @NumberOfBookedPeople)
            BEGIN
                INSERT INTO DayReservationsPersons (PersonID, DayReservationID, IsStudent)
                VALUES (@PersonID, @DayReservationID, @IsStudent)
            END
        END
        ELSE IF (@IsStudent = 1)
        BEGIN
            DECLARE @NumberOfStudentTickets AS int
            DECLARE @NumberOfBookedStudents AS int

            SET @NumberOfStudentTickets = (SELECT NumberOfStudentTickets
                                            FROM DayReservations
                                            WHERE DayReservationID = @DayReservationID
                                              AND IsCancelled = 0)
            SET @NumberOfBookedStudents = (SELECT COUNT(PersonID)
                                            FROM DayReservationsPersons
                                            WHERE PersonID = @PersonID
                                              AND IsStudent)

            IF (@NumberOfStudentTickets > @NumberOfBookedStudents)
            BEGIN
                INSERT INTO DayReservationsPersons (PersonID, DayReservationID, IsStudent)
                VALUES (@PersonID, @DayReservationID, @IsStudent)
            END
        END
        ELSE
        BEGIN
            RAISERROR ('Number of booked participants is already full for this day reservation', 16, 1)
        END
    END

-- Adding Participant to Workshop Reservation
CREATE PROCEDURE AddPersonToWorkshopReservations
    @PersonID int,
    @DayReservationID int,
    @WorkshopID int
AS
    BEGIN
        DECLARE @IsInDayReservation as bit
        SET @IsInDayReservation = (EXISTS(SELECT 1
                                            FROM DayReservationsPersons
                                            WHERE PersonID = @PersonID
                                              AND DayReservationID = @DayReservationID))

        DECLARE @NumberOfTickets as int
        SET @NumberOfTickets = (SELECT NumberOfTickets
                                FROM WorkshopReservations
                                WHERE DayReservationID = @DayReservationID
                                  AND WorkshopID = @WorkshopID
                                  AND IsCancelled = 0)

        DECLARE @NumberOfBookedParticipants as int
        SET @NumberOfBookedParticipants = (SELECT COUNT(PersonID)
                                            FROM WorkshopReservationsPersons
                                            WHERE PersonID = @PersonID
                                              AND WorkshopID = @WorkshopID
                                              AND DayReservationID = @DayReservationID)

        DECLARE @StartTime time
        DECLARE @EndTime time
        DECLARE @DayID int

        SET @DayID      = (SELECT DayID FROM Workshops WHERE WorkshopID = @WorkshopID)
        SET @StartTime  = (SELECT StartTime FROM Workshops WHERE WorkshopID = @WorkshopID)
        SET @EndTime    = (SELECT EndTime FROM Workshops WHERE WorkshopID = @WorkshopID)

        IF(EXISTS(SELECT * FROM WorkshopReservationsPersons AS wrp
                    INNER JOIN Workshops AS ws ON wrp.WorkshopID = ws.WorkshopID
                                          AND ws.DayID = @DayID
                                          AND ((ws.StartTime > @StartTime AND ws.StartTime < @EndTime)
                                              OR (ws.EndTime > @StartTime AND ws.EndTime < @EndTime)
                                              OR (ws.EndTime > @EndTime   AND ws.StartTime < @StartTime))
                    WHERE PersonID = @PersonID))
        BEGIN
            RAISERROR ('Participant have colliding workshop', 16, 1)
        END

        IF (@IsInDayReservation = 0 AND @NumberOfTickets > @NumberOfBookedParticipants)
        BEGIN
            INSERT INTO WorkshopReservationsPersons (PersonID, DayReservationID, WorkshopID)
            VALUES (@PersonID, @DayReservationID, @WorkshopID)
        END
        ELSE
        BEGIN
            RAISERROR ('Number of booked participants is already full ' +
                       'for this day reservation or person has time collision', 16, 1)
        END
    END

CREATE PROCEDURE ChangeDayCapacity(
    @DayID int,
    @NewCapacity int
)
AS
    BEGIN
        UPDATE Days SET Capacity = @NewCapacity WHERE DayID = @DayID
    END

CREATE PROCEDURE ChangeWorkshopCapacity(
    @WorkshopID int,
    @NewCapacity int
)
AS
    BEGIN
        UPDATE Workshops SET Capacity = @NewCapacity WHERE WorkshopID = @WorkshopID
    END

CREATE PROCEDURE ChangeDayNumberOfNormalTickets(
    @DayReservationID int,
    @NewNumberOfTickets int
)
AS
    BEGIN
        UPDATE DayReservations
            SET NumberOfNormalTickets = @NewNumberOfTickets
            WHERE DayReservationID = @DayReservationID
    END

CREATE PROCEDURE ChangeDayNumberOfStudentTickets(
    @DayReservationID int,
    @NewNumberOfTickets int
)
AS
    BEGIN
        UPDATE DayReservations
            SET NumberOfStudentTickets = @NewNumberOfTickets
            WHERE DayReservationID = @DayReservationID
    END

CREATE PROCEDURE ChangeWorkshopNumberOfTickets(
    @DayReservationID int,
    @WorkshopID int,
    @NewNumberOfTickets int
)
AS
    BEGIN
        UPDATE WorkshopReservations
            SET NumberOfTickets = @NewNumberOfTickets
            WHERE DayReservationID = @DayReservationID
              AND WorkshopID = @WorkshopID
    END

-- Change day's price
CREATE PROCEDURE ChangeDayPrice
    @DayID int,
    @Price money
AS
BEGIN
    UPDATE Days SET Price = @Price WHERE DayID = @DayID
END

-- Change workshop's price
CREATE PROCEDURE ChangeWorkshopPrice
    @WorkshopID int,
    @Price money
AS
BEGIN
    UPDATE Workshops SET Price = @Price WHERE WorkshopID = @WorkshopID
END

-- Change workshop place
CREATE PROCEDURE ChangeWorkshopPlace
    @WorkshopID int,
    @PlaceId int,
    @Room varchar(20)
AS
BEGIN
   UPDATE Workshops SET PlaceID = @PlaceId AND Room = @Room WHERE WorkshopID = @WorkshopID
END

-- Cancel reservation in general
CREATE PROCEDURE CancelReservation
    @ReservationID int
AS
BEGIN
    UPDATE Reservations SET IsCancelled = 1 WHERE ReservationID = @ReservationID
END

-- Cancel day reservation
CREATE  PROCEDURE CancelDayReservation
    @DayReservationID int
AS
BEGIN
    UPDATE DayReservations SET IsCancelled = 1 WHERE DayReservationID = @DayReservationID
END

-- Cancel workshop reservation
CREATE PROCEDURE CancelWorkshopReservation
    @DayReservationID int,
    @WorkshopID int
AS
BEGIN
    UPDATE WorkshopReservations
        SET IsCancelled = 1
        WHERE DayReservationID = @DayReservationID
          AND WorkshopID = @WorkshopID
END

-- Remove participant from workshop reservation
CREATE PROCEDURE RemovePersonFromWorkshopReservations
    @PersonID int,
    @WorkshopID int,
    @DayReservationID int
AS
BEGIN
    DELETE FROM WorkshopReservationsPersons
        WHERE PersonID = @PersonID
          AND DayReservationID = @DayReservationID
          AND WorkshopID = @WorkshopID
END

-- Remove participant from day reservation
CREATE PROCEDURE RemovePersonFromDayReservations
    @PersonID int,
    @DayReservationID int
AS
    BEGIN
        DELETE FROM WorkshopReservationsPersons
            WHERE PersonID = @PersonID
            AND DayReservationID = @DayReservationID
        DELETE FROM DayReservationsPersons
            WHERE PersonID = @PersonID
            AND DayReservationID = @DayReservationID
    END