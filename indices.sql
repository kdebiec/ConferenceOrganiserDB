create nonclustered index Persons_Clients_idx
on Persons(ClientID desc)

create nonclustered index Email_Persons_idx
on Persons(Email desc)

create nonclustered index Companies_Clients_idx
on Companies(ClientID desc)

create nonclustered index Reservations_Clients_idx
on Reservations(ClientID desc)

create nonclustered index Payments_idx
on Payments(ReservationID desc)

create nonclustered index Reservation_DayReservation_idx
on DayReservations(ReservationID desc)

create nonclustered index Reservation_Day_idx
on DayReservations(DayID desc)

create nonclustered index Discounts_idx
on Discounts(ConferenceID desc)

create nonclustered index Days_idx
on Days(ConferenceID desc)

create nonclustered index Places_Workshops_idx
on Workshops(PlaceID desc)

create nonclustered index Days_Workshops_idx
on Workshops(DayID desc)

create nonclustered index WorkshopReservations_Workshop_idx
on WorkshopReservations(WorkshopID desc)

create nonclustered index WorkshopReservations_DayReservation_idx
on WorkshopReservations(DayReservationID desc)