CREATE FUNCTION SumToPayOnReservation(
    @ReservationID int
)
RETURNS MONEY
AS
    BEGIN
        declare @ConferenceID int
        set @ConferenceID = (select top 1 ConferenceID from DayReservations as dr
                                inner join Days as d on d.DayID = dr.DayID
                            where dr.ReservationID = @ReservationID and dr.IsCancelled = 0)

        declare @Discount decimal(4, 4)

        declare @DateNow date
        set @DateNow = GETDATE()
        declare @TimeLeft int

        set @TimeLeft = datediff(dd, (select StartDate from Conferences where ConferenceID = @ConferenceID), (select ReservationDate from Reservations where ReservationID = @ReservationID))
        set @Discount = (select top 1 Discount from Discounts
                            where ConferenceID = @ConferenceID and DaysBeforeConference <= @TimeLeft
                            order by DaysBeforeConference - @TimeLeft DESC)

        declare @ToPayForDaysNormal money

        set @ToPayForDaysNormal = (select sum(d.Price * (1 - @Discount)) * NumberOfNormalTickets from DayReservations as dr
                                        inner join Days as d on d.DayID = dr.DayID
                                    where dr.ReservationID = @ReservationID and dr.IsCancelled = 0)

        declare @StudentDiscount decimal(4, 4)
        set @StudentDiscount = (select StudentDiscount from Conferences where ConferenceID = @ConferenceID)

        declare @ToPayForDaysStudent money

        set @ToPayForDaysStudent = (select sum(d.Price * (1 - @Discount - @StudentDiscount)) * NumberOfStudentTickets from DayReservations as dr
                                        inner join Days as d on d.DayID = dr.DayID
                                    where dr.ReservationID = @ReservationID and dr.IsCancelled = 0)

        declare @ToPayForWorkshops money

        set @ToPayForWorkshops = (select sum(w.Price*wr.NumberOfTickets) from DayReservations as dr
                                        inner join WorkshopReservations as wr on dr.DayReservationID = wr.DayReservationID
                                        inner join Workshops as w on wr.WorkshopID = w.WorkshopID
                                    where dr.ReservationID = @ReservationID and wr.IsCancelled = 0 and wr.IsCancelled = 0)

        return @ToPayForDaysNormal + @ToPayForDaysStudent + @ToPayForWorkshops
    END

CREATE FUNCTION SumLeftToPay(
    @ReservationID int
)
RETURNS MONEY
AS
    BEGIN
        declare @Payed money
        set @Payed = (select sum(Amount) from Payments where ReservationID = @ReservationID)

        return SumToPayOnReservation(@ReservationID) - @Payed
    END