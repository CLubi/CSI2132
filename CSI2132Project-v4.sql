-- create tables
create table roles (
	id int primary key,
	role_name varchar(15) NOT NULL
);

Create table branch (
    id int primary key,
    city varchar(15) NOT NULL
);

create table employee (
	id int primary key, 
	firstname varchar(15) NOT NULL,
    lastname varchar(15) NOT NULL,
    ssn varchar(9) NOT NULL,
	street varchar(25) NOT NULL,
	postalcode varchar(6) NOT NULL,
	province varchar(2) NOT NULL,
	city varchar(15) NOT NULL,
	salary numeric(8,2) NOT NULL,
	manager_id int,
	role_id int NOT NULL,
	branch_id int NOT NULL,
    foreign key (manager_id) references employee(id),
    foreign key (role_id) references roles(id),
    foreign key (branch_id) references branch(id)
);

CREATE TABLE manager_branch (
    manager_id int,
    branch_id int,
    primary key (manager_id, branch_id),
    foreign key (manager_id) references employee(id),
    foreign key (branch_id) references branch(id)
);

Create table patient(
	id int primary key,
	firstname varchar(15) NOT NULL,
	lastname varchar(15) NOT NULL,
	ssn varchar(9) NOT NULL,
	gender char(1) NOT NULL,
	email varchar(40), 
	phonenumber varchar(10),
	dob date NOT NULL
);

CREATE TABLE users (
	id int PRIMARY KEY,
	password varchar(10) NOT NULL,
	firstname varchar(15) NOT NULL,
	lastname varchar(15) NOT NULL,
	email varchar(40) NOT NULL, 
	phonenumber varchar(10) NOT NULL,
	dob date NOT NULL,
	employee_id int,
    foreign key (employee_id) references employee(id)
);

CREATE TABLE patient_user (
    user_id int,
    patient_id int,
    primary key (user_id, patient_id),
    foreign key (user_id) references users(id),
    foreign key (patient_id) references patient(id)
);

Create table reviews (
    id int primary key,
    professionalism int NOT NULL,
    communication int NOT NULL, 
    cleanliness int NOT NULL,
    review_value int NOT NULL,
    patient_id int NOT NULL,
    branch_id int  NOT NULL,
    Foreign Key(patient_id)  references patient(id),
    Foreign Key(branch_id)  references branch(id)
);

Create table time_slot(
    id int primary key,
    start_time time NOT NULL,
    end_time time NOT NULL,
    slot_date date NOT NULL
);

Create table invoice(
    id int primary key,
    patient_cost numeric(7,2) NOT NULL,
    insurance_cost numeric(7,2),
    total_cost numeric(7,2) NOT NULL,
    discount_cost numeric(7,2),
    penalty_cost numeric(7,2)
);

Create table appointment (
    id int primary key,
    appt_type varchar(15) NOT NULL, 
    room varchar(10),
    status varchar(15),
    patient_id int NOT NULL,
    employee_id int NOT NULL,
    timeslot_id int NOT NULL,
    invoice_id int,
    foreign key(patient_id) references patient(id),
    foreign key(employee_id) references employee(id),
    foreign key(invoice_id) references invoice(id),
    foreign key(timeslot_id) references time_slot(id)
);

Create table fee_charge(
    id int primary key,
    code varchar(5) NOT NULL,
    charge numeric(7,2) NOT NULL
);

Create table appt_procedure (
    id int primary key,
    description varchar(40),
    procedure_type varchar(15),
    tooth varchar(15) NOT NULL,
    amount varchar(15),
    appt_id int NOT NULL,
    fee_id int NOT NULL,
    foreign key(appt_id) references appointment(id),
    foreign key(fee_id) references fee_charge(id)
);

Create table payment(
    id int primary key,
    payment_method varchar(15) NOT NULL,
    payment_date date NOT NULL, 
    invoice_id int NOT NULL,
    foreign key(invoice_id) references invoice(id)
);

Create table insurance_claim (
    id int primary key,
    insurance_method varchar(15),
    claim_date date NOT NULL,
    patient_id int NOT NULL,
    payment_id int NOT NULL,
    foreign key(patient_id) references patient(id),
    foreign key(payment_id) references payment(id)
);

Create table records(
    id int primary key,
    employee_id int NOT NULL,
    foreign key(employee_id) references employee(id),
    foreign key(id) references patient(id)
);

-- insert values
INSERT INTO roles (id, role_name)
VALUES (1, 'BranchManager'),
(2, 'Hygienist'),
(3, 'Dentist'),
(4, 'Receptionist');

INSERT INTO branch (id, city)
VALUES (1, 'Ottawa'),
(2, 'Toronto');

INSERT INTO employee (id, firstname, lastname, ssn, street, postalcode, province, city, salary, manager_id, role_id, branch_id)
VALUES (1, 'Steve', 'Johnson', '123456789', '123 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 100000.00, NULL, 1, 1),
(2, 'Alan', 'Lee', '123456790', '124 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 80000.00, 1, 2, 1),
(3, 'Daisy', 'Wilson', '123456791', '125 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 80000.00, 1, 2, 1),
(4, 'William', 'Jackson', '123456792', '126 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 80000.00, 1, 2, 1),
(5, 'Katie', 'Thompson', '123456793', '127 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 300000.00, 1, 3, 1),
(6, 'Ahmed', 'Hassan', '123456794', '128 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 350000.00, 1, 3, 1),
(7, 'Aisha', 'Malik', '123456795', '129 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 375000.00, 1, 3, 1),
(8, 'Mike', 'Jordan', '123456796', '130 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 75000.00, 1, 4, 1),
(9, 'Pam', 'Be', '123456797', '131 Queen Street', 'A1A1A1', 'ON', 'Ottawa', 70000.00, 1, 4, 1),
(10, 'Ron', 'James', '123456798', '1234 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 100000.0, NULL, 1, 2),
(11, 'Aalia', 'Fisher', '123456799', '1235 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 84500.90, 10, 2, 2),
(12, 'Romilly', 'Boyle', '123456800', '1236 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 85000.00, 10, 2, 2),
(13, 'Wilfred', 'Maguire', '123456801', '1237 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 325000.00, 10, 3, 2),
(14, 'Yusuf', 'Coleman', '123456802', '1238 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 400000.00, 10, 3, 2),
(15, 'Lemar', 'Conway', '123456803', '1239 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 73000.10, 10, 4, 2),
(16, 'Joao', 'Sanchez', '123456804', '1240 Dundas Street', 'Z9Z9Z9', 'ON', 'Toronto', 75000.00, 10, 4, 2);

INSERT INTO manager_branch (manager_id, branch_id)
values (1, 1),
(10, 2);

INSERT INTO patient (id, firstname, lastname, ssn, gender, email, phonenumber, dob) 
values
(1, 'John', 'Doe', 990302930, 'M', 'jhondoe@gmail.com', 1890092900, '1975-09-01'),
(2, 'Jane', 'Doe', 324424424, 'F', NULL, NULL, '2012-09-01'),
(3, 'Adam', 'Apple', 990302931, 'M', 'adam@gmail.com', 1890092901, '1974-09-01'),
(4, 'July', 'Apple', 324424425, 'F', 'july@gmail.com', 2890092901, '1995-09-01'),
(5, 'Sohail', 'Khan', 324424427, 'M', 'Sohail@gmail.com', 2890095901, '1993-08-01'),
(6, 'Bella', 'Hadid', 324244272, 'F', 'bella@gmail.com', 2890091901, '1990-04-01'),
(7, 'Kim', 'Hart', 324243272, 'F', 'kim@gmail.com', 2790091901, '1991-03-01'),
(8, 'Alice', 'King', 324246272, 'F', 'alice@gmail.com', 2090291901, '1997-03-01'),
(9, 'Imran', 'Khan', 300246272, 'M', 'imran@gmail.com', 2990291901, '1990-09-01'),
(10, 'Ali', 'Moe', 300216272, 'M', 'ali@gmail.com', 2990261901, '2000-09-01'),
(11, 'Aisha', 'Malik', '123456795', 'F', 'aishamalik@gmail.com', '1234567896', '1968-01-07'),
(12, 'Wilfred', 'Maguire', '123456801', 'M', 'wilfredmaguire@gmail.com', '1234567902', '1973-01-13'),
(13, 'David', 'Maguire', '123456805', 'M', NULL, NULL, '2010-01-13'),
(14, 'Joao', 'Sanchez', '123456804', 'M', 'joaosanchez@gmail.com', '1234567905', '1983-09-30');

INSERT INTO users (id, password, firstname, lastname, email, phonenumber, dob, employee_id) 
values 
(1, 'abcdef', 'John', 'Doe', 'jhondoe@gmail.com', 1890092900, '1975-09-01', NULL ),
(2, 'abcdef', 'Adam', 'Apple', 'adam@gmail.com', 1890092901, '1974-09-01', NULL),
(3, 'abcdef', 'July', 'Apple', 'july@gmail.com', 2890092901, '1995-09-01', NULL),
(4, 'abcdef', 'Sohail', 'Khan', 'Sohail@gmail.com', 2890095901, '1993-08-01', NULL),
(5, 'abcdef', 'Bella', 'Hadid', 'bella@gmail.com', 2890091901, '1990-04-01', NULL),
(6, 'abcdef', 'Kim', 'Hart', 'kim@gmail.com', 2790091901, '1991-03-01', NULL),
(7, 'abcdef', 'Alice', 'King', 'alice@gmail.com', 2090291901, '1997-03-01', NULL),
(8, 'abcdef', 'Imran', 'Khan', 'imran@gmail.com', 2990291901, '1990-09-01', NULL),
(9, 'abcdef', 'Ali', 'Moe', 'ali@gmail.com', 2990261901, '2000-09-01', NULL),
(10, 'abcdef', 'Steve', 'Johnson', 'stevejohnson@gmail.com', '1234567890', '1970-01-01', 1),
(11, 'abcdef', 'Alan', 'Lee', 'alanlee@gmail.com', '1234567891', '1965-01-02', 2),
(12, 'abcdef', 'Daisy', 'Wilson', 'daisywilson@gmail.com', '1234567892', '1960-01-03', 3),
(13, 'abcdef', 'William', 'Jackson', 'williamjackson@gmail.com', '1234567893', '1969-01-04', 4),
(14, 'abcdef', 'Katie', 'Thompson', 'katiethompson@gmail.com', '1234567894', '1974-01-05', 5),
(15, 'abcdef', 'Ahmed', 'Hassan', 'ahmedhassan@gmail.com', '1234567895', '1973-01-06', 6),
(16,'abcdef', 'Aisha', 'Malik', 'aishamalik@gmail.com', '1234567896', '1968-01-07', 7),
(17, 'abcdef', 'Mike', 'Jordan', 'mikejordan@gmail.com', '1234567897', '1956-01-08', 8),
(18, 'abcdef', 'Pam', 'Be', 'pambe@gmail.com', '1234567898', '1984-01-09', 9),
(19, 'abcdef', 'Ron', 'James', 'ronjames@gmail.com', '1234567899', '1970-01-10', 10),
(20, 'abcdef', 'Aalia', 'Fisher', 'aaliafisher@gmail.com', '1234567900', '1971-01-11', 11),
(21, 'abcdef', 'Romilly', 'Boyle', 'romillyboyle@gmail.com', '1234567901', '1972-01-12', 12),
(22, 'abcdef', 'Wilfred', 'Maguire', 'wilfredmaguire@gmail.com', '1234567902', '1973-01-13', 13),
(23, 'abcdef', 'Yusuf', 'Coleman', 'yusufcoleman@gmail.com', '1234567903', '1973-06-25', 14),
(24, 'abcdef', 'Lemar', 'Conway', 'lemarconway@gmail.com', '1234567904', '1963-07-19', 15),
(25, 'abcdef', 'Joao', 'Sanchez', 'joaosanchez@gmail.com', '1234567905', '1983-09-30', 16);

INSERT INTO patient_user (user_id,patient_id)
values (1, 1), 
(1,2),
(2,3),
(3,4), 
(4,5), 
(5,6), 
(6,7), 
(7,8), 
(8,9), 
(9,10),
(16, 11),
(22, 12),
(22, 13),
(25, 14);

INSERT INTO reviews (id, professionalism, communication, cleanliness, review_value, patient_id, branch_id)
VALUES (1, 5, 3, 4, 5, 5, 1),
(2, 5, 5, 5, 5, 9, 1),
(3, 3, 4, 5, 4, 1, 1),
(4, 3, 1, 1, 1, 4, 2),
(5, 5, 4, 4, 3, 3, 2);

INSERT INTO time_slot(id, start_time, end_time, slot_date)
VALUES (1, '9:00:00', '10:00:00', '2022-04-04'),
(2, '10:00:00', '11:00:00', '2022-04-04'),
(3, '11:00:00', '12:00:00', '2022-04-04'),
(4, '12:00:00', '13:00:00', '2022-04-04'),
(5, '13:00:00', '14:00:00', '2022-04-04'),
(6, '14:00:00', '15:00:00', '2022-04-04'),
(7, '15:00:00', '16:00:00', '2022-04-04'),
(8, '16:00:00', '17:00:00', '2022-04-04'),
(9, '9:00:00', '10:00:00', '2022-04-05'),
(10, '10:00:00', '11:00:00', '2022-04-05'),
(11, '11:00:00', '12:00:00', '2022-04-05'),
(12, '12:00:00', '13:00:00', '2022-04-05'),
(13, '13:00:00', '14:00:00', '2022-04-05'),
(14, '14:00:00', '15:00:00', '2022-04-05'),
(15, '15:00:00', '16:00:00', '2022-04-05'),
(16, '16:00:00', '17:00:00', '2022-04-05'),
(17, '9:00:00', '10:00:00', '2022-04-06'),
(18, '10:00:00', '11:00:00', '2022-04-06'),
(19, '11:00:00', '12:00:00', '2022-04-06'),
(20, '12:00:00', '13:00:00', '2022-04-06'),
(21, '13:00:00', '14:00:00', '2022-04-06'),
(22, '14:00:00', '15:00:00', '2022-04-06'),
(23, '15:00:00', '16:00:00', '2022-04-06'),
(24, '16:00:00', '17:00:00', '2022-04-06'),
(25, '9:00:00', '10:00:00', '2022-04-07'),
(26, '10:00:00', '11:00:00', '2022-04-07'),
(27, '11:00:00', '12:00:00', '2022-04-07'),
(28, '12:00:00', '13:00:00', '2022-04-07'),
(29, '13:00:00', '14:00:00', '2022-04-07'),
(30, '14:00:00', '15:00:00', '2022-04-07'),
(31, '15:00:00', '16:00:00', '2022-04-07'),
(32, '16:00:00', '17:00:00', '2022-04-07'),
(33, '9:00:00', '10:00:00', '2022-04-08'),
(34, '10:00:00', '11:00:00', '2022-04-08'),
(35, '11:00:00', '12:00:00', '2022-04-08'),
(36, '12:00:00', '13:00:00', '2022-04-08'),
(37, '13:00:00', '14:00:00', '2022-04-08'),
(38, '14:00:00', '15:00:00', '2022-04-08'),
(39, '15:00:00', '16:00:00', '2022-04-08'),
(40, '16:00:00', '17:00:00', '2022-04-08');

INSERT INTO invoice(id, patient_cost, insurance_cost, total_cost, discount_cost, penalty_cost)
VALUES (1, 75.00, 225.00, 300.00, 0.00, 0.00),
(2, 500.00, 1500.00, 2000.00, 0.00, 0.00),
(3, 325.00, 975.00, 1300.00, 0.00, 0.00),
(4, 14.00, 0.00, 14.00, 0.00, 14.00),
(5, 75.00, 225.00, 300.00, 0.00, 0.00),
(6, 14.00, 0.00, 14.00, 0.00, 14.00),
(7, 75.00, 225.00, 300.00, 0.00, 0.00),
(8, 325.00, 975.00, 1300.00, 0.00, 0.00),
(9, 14.00, 0.00, 14.00, 0.00, 14.00),
(10, 25.00, 75.00, 100.00, 0.00, 0.00),
(11, 75.00, 225.00, 300.00, 0.00, 0.00),
(12, 162.50, 487.50, 650.00, 0.00, 0.00),
(13, 75.00, 225.00, 300.00, 0.00, 0.00),
(14, 75.00, 225.00, 300.00, 0.00, 0.00),
(15, 25.00, 75.00, 100.00, 0.00, 0.00),
(16, 250.00, 750.00, 1000.00, 0.00, 0.00),
(17, 175.00, 525.00, 700.00, 0.00, 0.00),
(18, 87.50, 262.50, 350.00, 0.00, 0.00);

INSERT INTO appointment(id, appt_type, room, status, patient_id, employee_id, timeslot_id, invoice_id)
VALUES (1, 'Cleaning', '001', 'Completed', 1, 6, 1, 1),
(2, 'Root Canal', '002', 'Completed', 3, 7, 3, 2),
(3, 'Extraction', '001', 'Completed', 4, 6, 4, 3),
(4, 'Dentures', '003', 'Cancelled', 5, 5, 6, 4),
(5, 'Cleaning', '002', 'Completed', 6, 6, 8, 5),
(6, 'Wisdom Teeth', '001', 'Cancelled', 10, 13, 12, 6),
(7, 'Cleaning', '003', 'Completed', 13, 14, 15, 7),
(8, 'Extraction', '001', 'Completed', 9, 13, 16, 8),
(9, 'Root Canal', '001', 'No Show', 7, 7, 18, 9),
(10, 'Whitening', '002', 'Completed', 2, 6, 20, 10),
(11, 'Cleaning', '002', 'Completed', 8, 13, 21, 11),
(12, 'Extraction', '002', 'Completed', 14, 14, 24, 12),
(13, 'Cleaning', '001', 'Completed', 1, 5, 27, 13),
(14, 'Cleaning', '001', 'Completed', 3, 6, 31, 14),
(15, 'Whitening', '003', 'Completed', 6, 7, 32, 15),
(16, 'Dentures', '002', 'Completed', 9, 5, 33, 16),
(17, 'Fillings', '001', 'Completed', 8, 5, 34, 17),
(18, 'Fillings', '001', 'Completed', 4, 6, 35, 18);

INSERT INTO fee_charge(id, code, charge)
VALUES (1, '94303', 14.00),
(2, '94304', 300.00), -- cleaning
(3, '94305', 2000.00), -- root canal
(4, '94306', 1000.00), -- dentures
(5, '94307', 700.00), -- wisdom teeth
(6, '94308', 650.00), -- extraction
(7, '94309', 100.00), -- whitening
(8, '94310', 350.00), -- fillings
(9, '94311', 2000.00); -- braces

INSERT INTO appt_procedure(id, description, procedure_type, tooth, amount, appt_id, fee_id)
VALUES (1, NULL, 'Scaling', 'All', NULL, 1, 2),
(2, NULL, 'Removal', '2nd Molar', NULL, 2, 3),
(3, NULL, 'Removal', '1st Premolar', NULL, 3, 6),
(4, NULL, 'Removal', '2nd Premolar', NULL, 3, 6),
(5, NULL, NULL, 'All', NULL, 4, 1),
(6, NULL, 'Scaling', 'All', NULL, 5, 2),
(7, NULL, 'Removal', '3rd Molars', NULL, 6, 1),
(8, NULL, 'Scaling', 'All', NULL, 7, 2),
(9, NULL, 'Removal', 'Canine', NULL, 8, 6),
(10, NULL, 'Removal', 'Incisor', NULL, 8, 6),
(11, NULL, NULL, 'Incisor', NULL, 9, 1),
(12, NULL, 'Scaling', 'All', NULL, 10, 7),
(13, NULL, 'Scaling', 'All', NULL, 11, 2),
(14, NULL, 'Removal', 'Canine', NULL, 12, 6),
(15, NULL, 'Scaling', 'All', NULL, 13, 2),
(16, NULL, 'Scaling', 'All', NULL, 14, 2),
(17, NULL, 'Scaling', 'All', NULL, 15, 7),
(18, NULL, NULL, 'All', NULL, 16, 4),
(19, NULL, 'Fluoride', 'Premolar', NULL, 17, 8),
(20, NULL, 'Fluoride', 'Molar', NULL, 17, 8),
(21, NULL, 'Fluoride', 'Molar', NULL, 18, 8);

INSERT INTO payment(id, payment_method, payment_date, invoice_id)
VALUES (1, 'Cash', '2022-04-04', 1),
(2, 'Card', '2022-04-04', 2),
(3, 'Cash', '2022-04-04', 2),
(4, 'Card', '2022-04-04', 3),
(5, 'Cash', '2022-04-04', 4),
(6, 'Card', '2022-04-04', 5),
(7, 'Cash', '2022-04-05', 6),
(8, 'Cash', '2022-04-05', 7),
(9, 'Cash', '2022-04-05', 8),
(10, 'Card', '2022-04-05', 8),
(11, 'Card', '2022-04-06', 9),
(12, 'Cash', '2022-04-06', 10),
(13, 'Card', '2022-04-06', 11),
(14, 'Card', '2022-04-06', 12),
(15, 'Card', '2022-04-07', 13),
(16, 'Card', '2022-04-07', 14),
(17, 'Cash', '2022-04-07', 15),
(18, 'Card', '2022-04-08', 16),
(19, 'Card', '2022-04-08', 17),
(20, 'Cash', '2022-04-08', 17),
(21, 'Card', '2022-04-08', 18);

INSERT INTO insurance_claim(id, insurance_method, claim_date, patient_id, payment_id)
VALUES (1, NULL, '2022-04-04', 1, 1),
(2, NULL, '2022-04-04', 3, 2),
(3, NULL, '2022-04-04', 3, 3),
(4, NULL, '2022-04-04', 4, 4),
(5, NULL, '2022-04-04', 5, 5),
(6, NULL, '2022-04-04', 6, 6),
(7, NULL, '2022-04-05', 10, 7),
(8, NULL, '2022-04-05', 13, 8),
(9, NULL, '2022-04-05', 9, 9),
(10, NULL, '2022-04-05', 9, 10),
(11, NULL, '2022-04-06', 7, 11),
(12, NULL, '2022-04-06', 2, 12),
(13, NULL, '2022-04-06', 8, 13),
(14, NULL, '2022-04-06', 14, 14),
(15, NULL, '2022-04-07', 1, 15),
(16, NULL, '2022-04-07', 3, 16),
(17, NULL, '2022-04-07', 6, 17),
(18, NULL, '2022-04-08', 9, 18),
(19, NULL, '2022-04-08', 8, 19),
(20, NULL, '2022-04-08', 8, 20),
(21, NULL, '2022-04-08', 4, 21);