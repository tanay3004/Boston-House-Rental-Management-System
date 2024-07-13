USE Housing_System;

CREATE TABLE Owner (
    owner_id int NOT NULL,
    contact_number varchar(10),
    PRIMARY KEY (owner_id)
);

CREATE TABLE Location (
    location_id int NOT NULL,
    city varchar(30),
    state varchar(30),
    zip_code varchar(10),
    PRIMARY KEY (location_id)
);

CREATE TABLE User (
    user_id int NOT NULL,
    name varchar(15),
    contact_number varchar(10),
    login_credentials varchar(15),
    PRIMARY KEY (user_id)
);

CREATE TABLE Property (
    property_id int NOT NULL,
    owner_id int,
    address varchar(30),
    size int,
    rooms int,
    amenities varchar(15),
    PRIMARY KEY (property_id),
    FOREIGN KEY (owner_id) REFERENCES Owner(owner_id)
);

CREATE TABLE Lease_Agreement (
    lease_agreement_id int NOT NULL,
    property_id int,
    T_and_C varchar(25),
    rental_period varchar(15),
    payment_schedules varchar(10),
    PRIMARY KEY (lease_agreement_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

CREATE TABLE Tenant (
    tenant_id int NOT NULL,
    lease_agreement_id int,
    contact_number varchar(20),
    tenant_history varchar(30),
    PRIMARY KEY (tenant_id),
    FOREIGN KEY (lease_agreement_id) REFERENCES Lease_Agreement(lease_agreement_id)
);

CREATE TABLE Property_Image (
    image_id int NOT NULL,
    image_URL varchar(20),
    property_id int,
    description varchar(20),
    PRIMARY KEY (image_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

CREATE TABLE Maintenance_Request (
    request_id int NOT NULL,
    lease_agreement_id int,
    request_type varchar(10),
    description varchar(20),
    status varchar(15),
    PRIMARY KEY (request_id),
    FOREIGN KEY (lease_agreement_id) REFERENCES Lease_Agreement(lease_agreement_id)
);

CREATE TABLE Review (
    review_id int NOT NULL,
    lease_agreement_id int,
    user_ratings int,
    comments varchar(20),
    PRIMARY KEY (review_id),
    FOREIGN KEY (lease_agreement_id) REFERENCES Lease_Agreement(lease_agreement_id)
);

CREATE TABLE Payment (
    payment_id int NOT NULL,
    lease_agreement_id int,
    amount Decimal(8,2),
    payment_method varchar(15),
    PRIMARY KEY (payment_id),
    FOREIGN KEY (lease_agreement_id) REFERENCES Lease_Agreement(lease_agreement_id)
);

CREATE TABLE Agent (
    agent_id int,
    lease_agreement_id int,
    contact_number varchar(10),
    services_offered varchar(15),
    PRIMARY KEY (agent_id),
    FOREIGN KEY (lease_agreement_id) REFERENCES Lease_Agreement(lease_agreement_id)
);

CREATE TABLE Contract (
    contract_id int,
    lease_agreement_id int,
    terms varchar(20),
    legal_obligations varchar(15),
    PRIMARY KEY (contract_id),
    FOREIGN KEY (lease_agreement_id) REFERENCES Lease_Agreement(lease_agreement_id)
);

SELECT count(*) FROM Contract;

/* 1 Finding the total number of maintenance requests in "Pending" status */
select count(*) as pending_requests
from maintenance_request
where status = 'Pending';

/* 2 Finding the total number of properties owned by each owner */
SELECT o.owner_id, COUNT(p.property_id) AS total_properties
FROM Owner o
JOIN Property p ON o.owner_id = p.owner_id
GROUP BY o.owner_id;

/* 3 Retrieving all properties with their owners and locations */
SELECT p.property_id, o.owner_id, o.contact_number AS owner_contact, l.city, l.state
FROM Property p
JOIN Owner o ON p.owner_id = o.owner_id
LEFT JOIN Location l ON p.property_id = l.location_id;

/* 4 Find tenants with a lease agreement for properties in a specific city */
SELECT t.tenant_id, t.contact_number, la.property_id
FROM Tenant t
JOIN Lease_Agreement la ON t.lease_agreement_id = la.lease_agreement_id
WHERE la.property_id IN (SELECT property_id FROM Location WHERE city = 'Boston');

/* 5 Finding tenants with the highest payment amount */ 
SELECT t.tenant_id, t.contact_number, MAX(p.amount) AS highest_payment
FROM Tenant t
JOIN Lease_Agreement la ON t.lease_agreement_id = la.lease_agreement_id
JOIN Payment p ON la.lease_agreement_id = p.lease_agreement_id
WHERE p.amount = (
        SELECT MAX(amount)
        FROM Payment
        WHERE lease_agreement_id = la.lease_agreement_id
    )
GROUP BY t.tenant_id, t.contact_number;

/* 6 Find properties where the size is greater than all other properties in terms of rooms */
SELECT p.property_id, p.size, p.address, p.rooms
FROM Property p
WHERE p.rooms > ALL (
    SELECT rooms
    FROM Property
    WHERE property_id <> p.property_id
);

/* 7 Find properties with no maintenance requests */
SELECT p.property_id, p.address
FROM Property p
WHERE NOT EXISTS (
    SELECT 1
    FROM Maintenance_Request mr
    WHERE mr.lease_agreement_id IN (
        SELECT la.lease_agreement_id
        FROM Lease_Agreement la
        WHERE la.property_id = p.property_id
    )
);

/* 8 Find properties with maintenance requests or reviews */
SELECT DISTINCT p.property_id, p.address
FROM Property p
WHERE p.property_id IN (
    SELECT DISTINCT la.property_id
    FROM Maintenance_Request mr
    JOIN Lease_Agreement la ON mr.lease_agreement_id = la.lease_agreement_id
    UNION
    SELECT DISTINCT la.property_id
    FROM Review r
    JOIN Lease_Agreement la ON r.lease_agreement_id = la.lease_agreement_id
);

/* 9 Calculate the average number of rooms for properties owned by each owner */
SELECT o.owner_id, o.contact_number, 
    (SELECT AVG(rooms) FROM Property WHERE owner_id = o.owner_id) AS avg_rooms
FROM Owner o;

/* 10 Retrieve properties with a size greater than the average size of properties */
SELECT p.property_id, p.address, p.size
FROM Property p
JOIN (SELECT AVG(size) AS avg_size FROM Property) AS avg_prop
ON p.size > avg_prop.avg_size;

/* 11 Retrieve the average size of properties and display it for each property */
SELECT property_id, address, size,
(SELECT AVG(size) FROM Property) AS average_property_size
FROM Property;

