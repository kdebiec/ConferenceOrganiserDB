CREATE TRIGGER DayReservationCapacityOverflow
    ON DayReservations
    AFTER insert, update
    AS
    BEGIN
        IF update(NumberOfStudentTickets) OR update(NumberOfNormalTickets)
        BEGIN
            DECLARE @DayID int
            SET @DayID = (SELECT DayID FROM inserted)
            IF((SELECT sum(NumberOfNormalTickets) + sum(NumberOfStudentTickets)
                FROM DayReservations
                WHERE DayID = @DayID
                  AND IsCancelled = 0) > (SELECT Capacity FROM Days WHERE DayID = @DayID))
            BEGIN
                ROLLBACK
                RAISERROR ('Not enough places, changes aborted', 1, 1)
            END
        END
    END

CREATE TRIGGER DayCapacityInsufficiency
    ON Days
    AFTER update
    AS
    BEGIN
        DECLARE @DayID int
        SET @DayID =  (SELECT DayID FROM inserted)
        IF((SELECT sum(NumberOfNormalTickets) + sum(NumberOfStudentTickets)
                FROM DayReservations
                WHERE DayID = @DayID
                  AND IsCancelled = 0) > (SELECT Capacity FROM inserted))
        BEGIN
            ROLLBACK
            RAISERROR ('New Capacity is less than current ' +
                       'participants number, changes aborted', 1, 1)
        END
    END

CREATE TRIGGER WorkshopReservationsCapacityOverflow
    ON WorkshopReservations
    AFTER insert, update
    AS
    BEGIN
        IF(NumberOfTickets)
        BEGIN
            DECLARE @WorkshopID int
            SET @WorkshopID = (SELECT WorkshopID FROM inserted)
            IF((SELECT sum(NumberOfTickets)
                FROM WorkshopReservations
                WHERE WorkshopID = @WorkshopID
                  AND IsCancelled = 0) > (SELECT Capacity
                                            FROM Workshops
                                            WHERE Workshops.WorkshopID = @WorkshopID))
            BEGIN
                ROLLBACK
                RAISERROR ('Not enough places, changes aborted', 1, 1)
            END
        END
    END

CREATE TRIGGER WorkshopsCapacityInsufficiency
    ON Workshops
    AFTER update
    AS
    BEGIN
        DECLARE @WorkshopID int
        SET @WorkshopID = (SELECT WorkshopID FROM inserted)
        IF((SELECT sum(NumberOfTickets)
            FROM WorkshopReservations
            WHERE WorkshopReservations.WorkshopID = @WorkshopID
              AND IsCancelled = 0) > (SELECT Capacity FROM inserted))
        BEGIN
            ROLLBACK
            RAISERROR ('New Capacity is less than current ' +
                       'participants number, changes aborted', 1, 1)
        END
    END

CREATE TRIGGER ReservationCancellation
    ON Reservations
    AFTER update
    AS
    BEGIN
        DECLARE @ReservationID AS int
        SET @ReservationID = (SELECT ReservationID FROM inserted)
        UPDATE DayReservations
            SET IsCancelled = (SELECT IsCancelled FROM inserted)
            WHERE ReservationID = @ReservationID
    END

CREATE TRIGGER DayReservationCancellation
    ON DayReservations
    AFTER update
    AS
    BEGIN
        DECLARE @DayReservationID AS int
        SET @DayReservationID = (SELECT DayReservationID FROM inserted)
        UPDATE WorkshopReservations
            SET IsCancelled = (SELECT IsCancelled FROM inserted)
            WHERE DayReservationID = @DayReservationID
    END

CREATE TRIGGER PlaceCollision
    ON Workshops
    AFTER insert, update
    AS
    BEGIN
        DECLARE @PlaceID AS int
        DECLARE @Room AS varchar(20)
        SET @PlaceID = (SELECT PlaceID FROM inserted)
        SET @Room = (SELECT Room FROM inserted)

        DECLARE @PlaceOccupied AS int
        SET @PlaceOccupied = (SELECT count(WorkshopID)
                                FROM Workshops
                                WHERE PlaceID = @PlaceID
                                  AND Room = @Room)
        IF (@PlaceOccupied = 2)
        BEGIN
            ROLLBACK
            RAISERROR ('Place is already occupied, change aborted', 1, 1)
        END
    END
