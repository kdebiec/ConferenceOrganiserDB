-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-01-18 23:16:58.641

-- tables
-- Table: Clients
CREATE TABLE Clients (
    ClientID int  NOT NULL IDENTITY,
    IsCompany bit  NOT NULL,
    CONSTRAINT Clients_pk PRIMARY KEY  (ClientID)
);

-- Table: Companies
CREATE TABLE Companies (
    CompanyID int  NOT NULL IDENTITY,
    ClientID int  NOT NULL,
    CompanyName varchar(100)  NOT NULL,
    Email varchar(100)  NOT NULL,
    Phone varchar(15)  NOT NULL,
    CONSTRAINT company_id PRIMARY KEY  (CompanyID)
);

-- Table: Conferences
CREATE TABLE Conferences (
    ConferenceID int  NOT NULL IDENTITY,
    Title varchar(100)  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    StudentDiscount decimal(3,2)  NOT NULL, CHECK (StudentDiscount>=0 and StudentDiscount <= 100),
    CONSTRAINT Conferences_pk PRIMARY KEY  (ConferenceID)
);

-- Table: DayReservations
CREATE TABLE DayReservations (
    DayReservationID int  NOT NULL IDENTITY,
    ReservationID int  NOT NULL,
    DayID int  NOT NULL,
    NumberOfNormalTickets int  NOT NULL, CHECK (NumberOfNormalTickets>=0),
    NumberOfStudentTickets int  NOT NULL, CHECK (NumberOfStudentTickets>=0),
    IsCancelled bit  NOT NULL DEFAULT 0,
    CONSTRAINT DayReservations_pk PRIMARY KEY  (DayReservationID)
);

-- Table: DayReservationsPersons
CREATE TABLE DayReservationsPersons (
    PersonID int  NOT NULL,
    DayReservationID int  NOT NULL,
    IsStudent bit  NOT NULL,
    CONSTRAINT DayReservationsPersons_pk PRIMARY KEY  (PersonID,DayReservationID)
);

-- Table: Days
CREATE TABLE Days (
    DayID int  NOT NULL IDENTITY,
    ConferenceID int  NOT NULL,
    Capacity int  NOT NULL, CHECK (Capacity>0),
    Date date  NOT NULL,
    Price money  NOT NULL, CHECK (Price>=0),
    CONSTRAINT Days_pk PRIMARY KEY  (DayID)
);

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID int  NOT NULL IDENTITY,
    ConferenceID int  NOT NULL,
    Discount decimal(2,2)  NOT NULL, CHECK (Discount>=0),
    DaysBeforeConference int  NOT NULL, CHECK (DaysBeforeConference>0),
    CONSTRAINT Discounts_pk PRIMARY KEY  (DiscountID)
);

-- Table: Payments
CREATE TABLE Payments (
    PaymentID int  NOT NULL IDENTITY,
    ReservationID int  NOT NULL,
    Amount money  NOT NULL,
    DateOfIncome date  NOT NULL,
    CONSTRAINT Payments_pk PRIMARY KEY  (PaymentID)
);

-- Table: Persons
CREATE TABLE Persons (
    PersonID int  NOT NULL IDENTITY,
    ClientID int  NULL,
    FirstName varchar(50)  NOT NULL,
    LastName varchar(50)  NOT NULL,
    Email varchar(100)  NOT NULL,
    Phone varchar(15)  NOT NULL,
    CONSTRAINT Persons_pk PRIMARY KEY  (PersonID)
);

-- Table: Places
CREATE TABLE Places (
    PlaceID int  NOT NULL IDENTITY,
    Street varchar(100)  NOT NULL,
    ZipCode varchar(20)  NOT NULL,
    City varchar(100)  NOT NULL,
    CONSTRAINT Places_pk PRIMARY KEY  (PlaceID)
);

-- Table: Reservations
CREATE TABLE Reservations (
    ReservationID int  NOT NULL IDENTITY,
    ClientID int  NOT NULL,
    ReservationDate date  NOT NULL,
    IsCancelled bit  NOT NULL DEFAULT 0,
    CONSTRAINT Reservations_pk PRIMARY KEY  (ReservationID)
);

-- Table: WorkshopReservations
CREATE TABLE WorkshopReservations (
    DayReservationID int  NOT NULL,
    WorkshopID int  NOT NULL,
    NumberOfTickets int  NOT NULL, CHECK (NumberOfTickets>0),
    IsCancelled bit  NOT NULL DEFAULT 0,
    CONSTRAINT WorkshopReservations_pk PRIMARY KEY  (DayReservationID,WorkshopID)
);

-- Table: WorkshopReservationsPersons
CREATE TABLE WorkshopReservationsPersons (
    PersonID int  NOT NULL,
    DayReservationID int  NOT NULL,
    WorkshopID int  NOT NULL,
    CONSTRAINT WorkshopReservationsPersons_pk PRIMARY KEY  (PersonID,DayReservationID,WorkshopID)
);

-- Table: Workshops
CREATE TABLE Workshops (
    WorkshopID int  NOT NULL IDENTITY,
    PlaceID int  NOT NULL,
    DayID int  NOT NULL,
    Title varchar(100)  NOT NULL,
    Description varchar(300)  NOT NULL,
    Price money  NOT NULL, CHECK (Price>=0),
    Capacity int  NOT NULL, CHECK (Capacity>0),
    Room varchar(20)  NOT NULL,
    StartTime time  NOT NULL,
    EndTime time  NOT NULL,
    CONSTRAINT Workshops_pk PRIMARY KEY  (WorkshopID)
);

-- foreign keys
-- Reference: Companies_Clients (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: DayReservationsPersons_Persons (table: DayReservationsPersons)
ALTER TABLE DayReservationsPersons ADD CONSTRAINT DayReservationsPersons_Persons
    FOREIGN KEY (PersonID)
    REFERENCES Persons (PersonID);

-- Reference: Day_Conference (table: Days)
ALTER TABLE Days ADD CONSTRAINT Day_Conference
    FOREIGN KEY (ConferenceID)
    REFERENCES Conferences (ConferenceID);

-- Reference: Day_Reservation_Persons_Reservation (table: DayReservationsPersons)
ALTER TABLE DayReservationsPersons ADD CONSTRAINT Day_Reservation_Persons_Reservation
    FOREIGN KEY (DayReservationID)
    REFERENCES DayReservations (DayReservationID);

-- Reference: Day_Reservation_Reservation (table: DayReservations)
ALTER TABLE DayReservations ADD CONSTRAINT Day_Reservation_Reservation
    FOREIGN KEY (ReservationID)
    REFERENCES Reservations (ReservationID);

-- Reference: Discounts_Conference (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Discounts_Conference
    FOREIGN KEY (ConferenceID)
    REFERENCES Conferences (ConferenceID);

-- Reference: Payments_Reservation (table: Payments)
ALTER TABLE Payments ADD CONSTRAINT Payments_Reservation
    FOREIGN KEY (ReservationID)
    REFERENCES Reservations (ReservationID);

-- Reference: Persons_Clients (table: Persons)
ALTER TABLE Persons ADD CONSTRAINT Persons_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Reservation_Day (table: DayReservations)
ALTER TABLE DayReservations ADD CONSTRAINT Reservation_Day
    FOREIGN KEY (DayID)
    REFERENCES Days (DayID);

-- Reference: Reservations_Clients (table: Reservations)
ALTER TABLE Reservations ADD CONSTRAINT Reservations_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: WorkshopReservationsPersons_Persons (table: WorkshopReservationsPersons)
ALTER TABLE WorkshopReservationsPersons ADD CONSTRAINT WorkshopReservationsPersons_Persons
    FOREIGN KEY (PersonID)
    REFERENCES Persons (PersonID);

-- Reference: Workshop_Day (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshop_Day
    FOREIGN KEY (DayID)
    REFERENCES Days (DayID);

-- Reference: Workshop_Place (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshop_Place
    FOREIGN KEY (PlaceID)
    REFERENCES Places (PlaceID);

-- Reference: Workshop_Reservation_Persons_Workshop_Reservation (table: WorkshopReservationsPersons)
ALTER TABLE WorkshopReservationsPersons ADD CONSTRAINT Workshop_Reservation_Persons_Workshop_Reservation
    FOREIGN KEY (DayReservationID,WorkshopID)
    REFERENCES WorkshopReservations (DayReservationID,WorkshopID);

-- Reference: Workshop_Reservation_Reservation (table: WorkshopReservations)
ALTER TABLE WorkshopReservations ADD CONSTRAINT Workshop_Reservation_Reservation
    FOREIGN KEY (DayReservationID)
    REFERENCES DayReservations (DayReservationID);

-- Reference: Workshop_Reservation_Workshop (table: WorkshopReservations)
ALTER TABLE WorkshopReservations ADD CONSTRAINT Workshop_Reservation_Workshop
    FOREIGN KEY (WorkshopID)
    REFERENCES Workshops (WorkshopID);

-- End of file.

