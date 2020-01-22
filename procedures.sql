create procedure addClient(
    @IsCompany bit,
    @ClientID int output
)
as
    begin
        insert into Clients values (@IsCompany)
        set @ClientID = @@IDENTITY
    end

create procedure addPersonAsClient(
    @FirstName varchar(50),
    @LastName varchar(50),
    @Email varchar(100),
    @Phone varchar(15),
    @PersonID int output
)
as
    begin
        set @PersonID = (select PersonID from Persons where Email = @Email)
        declare @ClientID int
        set @ClientID = (select ClientID from Persons where PersonID = @PersonID)

        if(@PersonID is null)
        begin
            exec addClient 0, @ClientID
            insert into Persons values (@ClientID, @FirstName, @LastName, @Email, @Phone)
            set @PersonID = @@IDENTITY
        end
        else
        begin
            if(@ClientID is null)
            begin
                exec addClient 0, @ClientID
                update Persons set ClientID = @ClientID where PersonID = @PersonID
            end
        end
    end

create procedure addPersonAsParticipant(
    @FirstName varchar(50),
    @LastName varchar(50),
    @Email varchar(100),
    @Phone varchar(15),
    @PersonID int output
)
as
    begin
        set @PersonID = (select PersonID from Persons where Email = @Email)
        if(@PersonID is null)
        begin
            insert into Persons values (null, @FirstName, @LastName, @Email, @Phone)
            set @PersonID = @@IDENTITY
        end
    end

create procedure addCompany(
    @CompanyName varchar(100),
    @Email varchar(100),
    @Phone varchar(15),
    @CompanyID int output
)
as
    begin
        set @CompanyID = (select CompanyID from Companies where Email = @Email)
        if(@CompanyID is null)
        begin
            declare @ClientID int
            exec addClient 1, @ClientID = @ClientID
            insert into Companies values (@ClientID, @CompanyName, @Email, @Phone)
            set @CompanyID = @@IDENTITY
        end
    end

-- Adding new conference
CREATE PROCEDURE AddNewConference
    @Title varchar(100),
    @StartDate date,
    @EndDate date,
    @StudentDiscount decimal(3,2)
AS
BEGIN
   INSERT INTO Conferences (Title, StartDate, EndDate, StudentDiscount)
   VALUES (@Title, @StartDate, @EndDate, @StudentDiscount)
END

-- Adding new place
CREATE PROCEDURE  AddNewPlace
    @Street varchar(100),
    @ZipCode varchar(20),
    @City varchar(100)
AS
BEGIN
    INSERT INTO Places (Street, ZipCode, City)
    VALUES (@Street, @ZipCode, @City)
END

-- Adding discounts to conference
CREATE PROCEDURE AddNewDiscount
    @ConferenceID int,
    @Discount decimal(2,2),
    @DaysBeforeConference int
AS
BEGIN
    INSERT INTO Discounts (ConferenceID, Discount, DaysBeforeConference)
    VALUES (@ConferenceID, @Discount, @DaysBeforeConference)
END

-- Adding new conference day
CREATE PROCEDURE AddNewDay
    @ConferenceID int,
    @Capacity int,
    @Date date,
    @Price money
AS
BEGIN
    DECLARE @ConfStart AS date
    DECLARE @ConfEnd AS date

    SET @ConfStart = (SELECT StartDate FROM Conferences WHERE ConferenceID = @ConferenceID)
    SET @ConfEnd = (SELECT EndDate FROM Conferences WHERE ConferenceID = @ConferenceID)

    DECLARE @IsAlreadyDayInDB as bit
    SET @IsAlreadyDayInDB = (EXISTS(SELECT 1 FROM Days WHERE ConferenceID = @ConferenceID AND Date = @Date))

    IF (@Date >= @ConfStart AND @Date <= @ConfEnd AND @IsAlreadyDayInDB = 0)
    BEGIN
        INSERT INTO Days (ConferenceID, Capacity, Date, Price)
        VALUES (@ConferenceID, @Capacity, @Date, @Price)
    END
    ELSE
    BEGIN
        RAISERROR ('Wrong date', -1, -1)
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
    @EndTime time
AS
BEGIN
    INSERT INTO Workshops (PlaceID, DayID, Title, Description, Price, Capacity, Room, StartTime, EndTime)
    VALUES (@PlaceId, @DayId, @Title, @Description, @Price, @Capacity, @Room, @StartTime, @EndTime)
END

-- Adding new reservation
CREATE PROCEDURE AddNewReservation
    @ClientID int,
    @ReservationDate date
AS
BEGIN
    INSERT INTO Reservations (ClientID, ReservationDate)
    VALUES (@ClientID, @ReservationDate)
END

-- Adding new payments
CREATE PROCEDURE AddNewPayment
    @ReservationID int,
    @Amount money,
    @DateOfIncome date
AS
BEGIN
    INSERT INTO Payments (ReservationID, Amount, DateOfIncome)
    VALUES (@ReservationID, @Amount, @DateOfIncome)
END

-- Adding day reservation
CREATE PROCEDURE AddNewDayReservation
    @ReservationID int,
    @DayID int,
    @NumberOfNormalTickets int,
    @NumberOfStudentTickets int
AS
BEGIN
    DECLARE @DayCapacity AS int
    DECLARE @ReservedDaySlots AS int

    SET @DayCapacity = (SELECT Capacity FROM Days WHERE DayID = @DayID)
    SET @ReservedDaySlots = (SELECT SUM(NumberOfNormalTickets) + SUM(NumberOfStudentTickets) FROM DayReservations WHERE DayID = @DayID)

    IF (@ReservedDaySlots + @NumberOfNormalTickets + @NumberOfStudentTickets <= @DayCapacity)
    BEGIN
        INSERT INTO DayReservations (ReservationID, DayID, NumberOfNormalTickets, NumberOfStudentTickets)
        VALUES (@ReservationID, @DayID, @NumberOfNormalTickets, @NumberOfStudentTickets)
    END
    ELSE
    BEGIN
        RAISERROR ('Day capacity exceeded', -1, -1)
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

    SET @WorkshopCapacity = (SELECT Capacity FROM Days WHERE DayID = @DayID)
    SET @ReservedWorkshopSlots = (SELECT SUM(NumberOfTickets) FROM WorkshopReservations WHERE WorkshopID = @WorkshopID)

    IF (@ReservedWorkshopSlots + @NumberOfTickets <= @WorkshopCapacity)
    BEGIN
        INSERT INTO WorkshopReservations (DayReservationID, WorkshopID, NumberOfTickets)
        VALUES (@DayReservationID, @WorkshopID, @NumberOfTickets)
    END
    ELSE
    BEGIN
        RAISERROR ('Workshop capacity exceeded', -1, -1)
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

        SET @NumberOfNormalTickets = (SELECT NumberOfNormalTickets FROM DayReservations WHERE DayReservationID = @DayReservationID)
        SET @NumberOfBookedPeople = (SELECT COUNT(PersonID) FROM DayReservationsPersons WHERE PersonID = @PersonID AND NOT IsStudent)

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

        SET @NumberOfStudentTickets = (SELECT NumberOfStudentTickets FROM DayReservations WHERE DayReservationID = @DayReservationID)
        SET @NumberOfBookedStudents = (SELECT COUNT(PersonID) FROM DayReservationsPersons WHERE PersonID = @PersonID AND IsStudent)

        IF (@NumberOfStudentTickets > @NumberOfBookedStudents)
        BEGIN
            INSERT INTO DayReservationsPersons (PersonID, DayReservationID, IsStudent)
            VALUES (@PersonID, @DayReservationID, @IsStudent)
        END

    END
    ELSE
    BEGIN
        RAISERROR ('Number of booked participants is already full for this day reservation', -1, -1)
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
    SET @IsInDayReservation = (EXISTS(SELECT 1 FROM DayReservationsPersons
                                WHERE PersonID = @PersonID AND DayReservationID = @DayReservationID))

    DECLARE @NumberOfTickets as int
    SET @NumberOfTickets = (SELECT NumberOfTickets FROM WorkshopReservations
                                WHERE DayReservationID = @DayReservationID AND WorkshopID = @WorkshopID)

    DECLARE @NumberOfBookedParticipants as int
    SET @NumberOfBookedParticipants = (SELECT COUNT(PersonID) FROM WorkshopReservationsPersons
                                WHERE PersonID = @PersonID AND WorkshopID = @WorkshopID AND DayReservationID = @DayReservationID)

    -- TODO: Query if participant is not already in workshop at the same time

    IF (@IsInDayReservation = 0 AND @NumberOfTickets > @NumberOfBookedParticipants)
    BEGIN
        INSERT INTO WorkshopReservationsPersons (PersonID, DayReservationID, WorkshopID)
        VALUES (@PersonID, @DayReservationID, @WorkshopID)
    END
    ELSE
    BEGIN
        RAISERROR ('Number of booked participants is already full for this day reservation or person has time collision', -1, -1)
    END
END

-- TODO: trigger to check if all declared participants fit in day capacity
create procedure changeDayCapacity(
    @DayID int,
    @NewCapacity int
)
as
    begin
        update Days set Capacity = @NewCapacity where DayID = @DayID
    end

-- TODO: trigger to check if all declared participants fit in workshop capacity
create procedure changeWorkshopCapacity(
    @WorkshopID int,
    @NewCapacity int
)
as
    begin
        update Workshops set Capacity = @NewCapacity where WorkshopID = @WorkshopID
    end

-- TODO: trigger to check if new participants can fit
create procedure changeDayNumberOfNormalTickets(
    @DayReservationID int,
    @NewNumberOfTickets int
)
as
    begin
        update DayReservations set NumberOfNormalTickets = @NewNumberOfTickets where DayReservationID = @DayReservationID
    end

-- TODO: trigger to check if new participants can fit
create procedure changeDayNumberOfStudentTickets(
    @DayReservationID int,
    @NewNumberOfTickets int
)
as
    begin
        update DayReservations set NumberOfStudentTickets = @NewNumberOfTickets where DayReservationID = @DayReservationID
    end

-- TODO: trigger to check if new participants can fit
create procedure changeWorkshopNumberOfTickets(
    @DayReservationID int,
    @WorkshopID int,
    @NewNumberOfTickets int
)
as
    begin
        update WorkshopReservations set NumberOfTickets = @NewNumberOfTickets where DayReservationID = @DayReservationID and WorkshopID = @WorkshopID
    end