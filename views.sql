create or alter view UpcomingConferences
as
    select 'Conference ID: ' + ConferenceID as ConferenceID,
           'Conference Title: ' + Title as Title from Conferences
    where StartDate > convert(date, getdate())


create or alter view ConferenceParticipants
as
    select c.Title,
           p.FirstName + ' ' + p.LastName as name,
           p.Phone,
           p.Email
    from Conferences as c
        inner join Days as d on d.ConferenceID = c.ConferenceID
        inner join DayReservations as dr on dr.DayID = d.DayID and dr.IsCancelled = 0
        inner join DayReservationsPersons as drp on drp.DayReservationID = dr.ReservationID
        inner join Persons as p on p.PersonID = drp.PersonID


create or alter view WorkshopParticipants
as
    select w.Title,
           p.FirstName + ' ' + p.LastName as name,
           p.Phone,
           p.Email
    from Workshops as w
        inner join WorkshopReservations as wr on wr.WorkshopID = w.WorkshopID and IsCancelled = 0
        inner join WorkshopReservationsPersons as wrp on wrp.DayReservationID = wr.DayReservationID
        inner join Persons as p on p.PersonID = wrp.PersonID

create or alter view OverpaidReservations
as
    select r.ReservationID,
           c.CompanyName as ClientName,
           dbo.SumLeftToPay(r.ReservationID) as Overpaid
    from Reservations as r
        inner join Companies as c on c.ClientID = r.ClientID
    where dbo.SumLeftToPay(r.ReservationID) < 0
    union
    select r.ReservationID,
           p.FirstName + ' ' + p.LastName as ClientName,
           dbo.SumLeftToPay(r.ReservationID) as Overpaid
    from Reservations as r
        inner join Persons as p on p.ClientID = r.ClientID
    where dbo.SumLeftToPay(r.ReservationID) < 0 and r.IsCancelled = 0

create or alter view ActiveClients
as
    select c.ClientID,
           c.CompanyName,
           count(*) as CountOfReservations
    from Reservations as r
        inner join Companies as c on c.ClientID = r.ClientID
        where r.IsCancelled = 0
    group by c.ClientID, c.CompanyName
    union
    select p.PersonID,
           p.FirstName + ' ' + p.LastName,
           count(*) as CountOfReservations
    from Reservations as r
        inner join Persons as p on p.ClientID = r.ClientID
        where r.IsCancelled = 0
    group by p.PersonID, p.FirstName + ' ' + p.LastName