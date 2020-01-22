create trigger ReservationCapacityOverflow
    on DayReservations
    after insert, update
    as
    begin
        if update(NumberOfStudentTickets) or update(NumberOfNormalTickets)
        begin
            declare @DayID int
            set @DayID =  (select DayID from inserted)
            if((select sum(NumberOfNormalTickets) + sum(NumberOfStudentTickets)
                from DayReservations
                where DayID = @DayID) > (select Capacity from Days where DayID = @DayID))
            begin
                rollback
                raiserror('Not enough places, changes aborted', 1, 1)
            end
        end
    end

create trigger DayCapacityInsufficiency
    on Days
    after update
    as
    begin
        declare @DayID int
        set @DayID =  (select DayID from inserted)
        if((select sum(NumberOfNormalTickets) + sum(NumberOfStudentTickets)
                from DayReservations
                where DayID = @DayID) > (select Capacity from inserted))
        begin
            rollback
            raiserror('New Capacity is less than current participants number, changes aborted', 1, 1)
        end
    end