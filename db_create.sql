-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-01-17 13:08:40.757

-- tables
-- Table: Clients
CREATE TABLE Clients (
    ClientID int  NOT NULL,
    IsCompany bit  NOT NULL,
    CONSTRAINT Clients_pk PRIMARY KEY  (ClientID)
);

-- Table: Companies
CREATE TABLE Companies (
    CompanyID int  NOT NULL,
    CompanyName varchar(100)  NOT NULL,
    Email varchar(100)  NOT NULL,
    CONSTRAINT company_id PRIMARY KEY  (CompanyID)
);

-- Table: Conferences
CREATE TABLE Conferences (
    ConferenceID int  NOT NULL,
    Title varchar(100)  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    StudentDiscount decimal(3,2)  NOT NULL,
    CONSTRAINT StudentDiscount CHECK (StudentDiscount>=0 and StudentDiscount <= 100),
    CONSTRAINT Conferences_pk PRIMARY KEY  (ConferenceID)
);

-- Table: DayReservations
CREATE TABLE DayReservations (
    DayReservationID int  NOT NULL,
    ReservationID int  NOT NULL,
    DayID int  NOT NULL,
    NumberOfNormalTickets int  NOT NULL,
    NumberOfStudentTickets int  NOT NULL,
    CONSTRAINT NumberOfNormalTickets CHECK (NumberOfNormalTickets>=0),
    CONSTRAINT NumberOfStudentTickets CHECK (NumberOfStudentTickets>=0),
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
    DayID int  NOT NULL,
    ConferenceID int  NOT NULL,
    Capacity int  NOT NULL,
    Date date  NOT NULL,
    Price money  NOT NULL,
    CONSTRAINT Price CHECK (Price>=0),
    CONSTRAINT Capacity CHECK (Capacity>0),
    CONSTRAINT Days_pk PRIMARY KEY  (DayID)
);

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID int  NOT NULL,
    ConferenceID int  NOT NULL,
    Discount decimal(2,2)  NOT NULL,
    DaysBeforeConference int  NOT NULL,
    CONSTRAINT Discount CHECK (Discount>=0),
    CONSTRAINT DaysBeforeConference CHECK (DaysBeforeConference>0),
    CONSTRAINT Discounts_pk PRIMARY KEY  (DiscountID)
);

-- Table: Payments
CREATE TABLE Payments (
    PaymentID int  NOT NULL,
    ReservationID int  NOT NULL,
    Amount money  NOT NULL,
    DateOfIncome date  NOT NULL,
    CONSTRAINT Payments_pk PRIMARY KEY  (PaymentID)
);

-- Table: Persons
CREATE TABLE Persons (
    PersonID int  NOT NULL,
    FirstName varchar(50)  NOT NULL,
    LastName varchar(50)  NOT NULL,
    Email varchar(100)  NOT NULL,
    CONSTRAINT Persons_pk PRIMARY KEY  (PersonID)
);

-- Table: Phones
CREATE TABLE Phones (
    OwnerID int  NOT NULL,
    Phone varchar(15)  NOT NULL,
    CONSTRAINT owner_id PRIMARY KEY  (OwnerID)
);

-- Table: Places
CREATE TABLE Places (
    PlaceID int  NOT NULL,
    Street varchar(100)  NOT NULL,
    ZipCode varchar(20)  NOT NULL,
    City varchar(100)  NOT NULL,
    CONSTRAINT Places_pk PRIMARY KEY  (PlaceID)
);

-- Table: Reservations
CREATE TABLE Reservations (
    ReservationID int  NOT NULL,
    ClientID int  NOT NULL,
    ReservationDate date  NOT NULL,
    IsCancelled bit  NOT NULL,
    CONSTRAINT Reservations_pk PRIMARY KEY  (ReservationID)
);

-- Table: WorkshopReservations
CREATE TABLE WorkshopReservations (
    DayReservationID int  NOT NULL,
    WorkshopID int  NOT NULL,
    NumberOfTickets int  NOT NULL,
    CONSTRAINT NumberOfTickets CHECK (NumberOfTickets>0),
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
    WorkshopID int  NOT NULL,
    PlaceID int  NOT NULL,
    DayID int  NOT NULL,
    Title varchar(100)  NOT NULL,
    Description varchar(300)  NOT NULL,
    Price money  NOT NULL,
    Capacity int  NOT NULL,
    Room varchar(20)  NOT NULL,
    StartTime time  NOT NULL,
    EndTime time  NOT NULL,
    CONSTRAINT Price CHECK (Price>=0),
    CONSTRAINT Capacity CHECK (Capacity>0),
    CONSTRAINT Workshops_pk PRIMARY KEY  (WorkshopID)
);

-- foreign keys
-- Reference: Client_Company (table: Clients)
ALTER TABLE Clients ADD CONSTRAINT Client_Company
    FOREIGN KEY (ClientID)
    REFERENCES Companies (CompanyID);

-- Reference: Client_Person (table: Persons)
ALTER TABLE Persons ADD CONSTRAINT Client_Person
    FOREIGN KEY (PersonID)
    REFERENCES Clients (ClientID);

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

-- Reference: Person_Reservation_Per_Day_Person (table: DayReservationsPersons)
ALTER TABLE DayReservationsPersons ADD CONSTRAINT Person_Reservation_Per_Day_Person
    FOREIGN KEY (PersonID)
    REFERENCES Persons (PersonID);

-- Reference: Phone_Company (table: Phones)
ALTER TABLE Phones ADD CONSTRAINT Phone_Company
    FOREIGN KEY (OwnerID)
    REFERENCES Companies (CompanyID);

-- Reference: Phone_Person (table: Phones)
ALTER TABLE Phones ADD CONSTRAINT Phone_Person
    FOREIGN KEY (OwnerID)
    REFERENCES Persons (PersonID);

-- Reference: Reservation_Client (table: Reservations)
ALTER TABLE Reservations ADD CONSTRAINT Reservation_Client
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Reservation_Day (table: DayReservations)
ALTER TABLE DayReservations ADD CONSTRAINT Reservation_Day
    FOREIGN KEY (DayID)
    REFERENCES Days (DayID);

-- Reference: Workshop_Day (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshop_Day
    FOREIGN KEY (DayID)
    REFERENCES Days (DayID);

-- Reference: Workshop_Place (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshop_Place
    FOREIGN KEY (PlaceID)
    REFERENCES Places (PlaceID);

-- Reference: Workshop_Reservation_Persons_Person (table: WorkshopReservationsPersons)
ALTER TABLE WorkshopReservationsPersons ADD CONSTRAINT Workshop_Reservation_Persons_Person
    FOREIGN KEY (PersonID)
    REFERENCES Persons (PersonID);

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

