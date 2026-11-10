-- Create Database
create database careplus_hospital;

use careplus_hospital;

-- creating patients table
create table patients (patient_id varchar(20) primary key,
                       patient_name varchar(100),
                       age int,
                       gender varchar(10),
                       city varchar(50),
                       patient_type varchar(20),
                       preferred_time_slot varchar(20),
                       registration_date DATE
                       );
                       
-- creating doctors table
create table doctors (doctor_id varchar(10) primary key,
					  doctor_name varchar(100),
                      specialty varchar(50),
                      hire_date DATE,
                      rating decimal(3,2),
                      employment_type varchar(20),
                      is_active varchar(3)
                      );
				
-- creating rooms table
create table rooms (room_id varchar(10) primary key,
                    room_type varchar(30),
                    floor int,
                    equipment_type varchar(50),
                    capacity int,
                    last_maintenance_date DATE,
                    is_available varchar(3)
                    );
                    
-- creating appointments table
create table appointments (appointment_id varchar(20) primary key,
                           patient_id varchar(20),
                           appointment_date DATE,
                           doctor_id varchar(10),
                           service_type varchar(30),
                           priority varchar(10),
                           estimated_cost decimal(10,2),
                           booking_channel varchar(20),
                           foreign key (patient_id) references patients(patient_id),
                           foreign key (doctor_id) references doctors(doctor_id)
                           );
                           
-- creating treatments table
create table treatments(treatment_id varchar(20) primary key,
                        appointment_id varchar(20),
                        doctor_id varchar(10),
                        room_id varchar(10),
                        actual_treatment_date DATE,
                        status varchar(20),
                        treatment_attempt int,
                        treatment_duration_min int,
                        waiting_time_min int,
                        treatment_cost decimal(10,2),
                        foreign key (appointment_id) references appointments(appointment_id),
                        foreign key (doctor_id) references doctors(doctor_id),
                        foreign key (room_id) references rooms(room_id)
                        );
                        
select * from patients;
select * from doctors;
select * from rooms;
select * from appointments;
select * from treatments;

-- Sprint 1: Business Understanding and Data Understanding
-- 1.4 Analytical Thinking from the ER Diagram

-- 1. Management wants to identify patients who have booked multiple appointments. Which table and columns are needed?
-- Needed : Table --> appointments  &  Columns --> patient_id(identifies each patient) ,appointment_id(identifies each appointment).

-- 2. Operations wants to identify appointments that required more than one treatment attempt. Where is this information found?
-- The information found in : Table --> treatments & Columns --> appointment_id(identifies which appointment),treatment_attempt(indicates the number of treatment attempts).

-- 3. Patient Services wants to compare General, Corporate, and Insurance patients based on appointment activity. Which tables must be connected?
-- patients and appointments tables must be connected.alter

-- 4. Operations wants to compare service types based on treatment duration and waiting time. Which tables are required?
-- appointments and treatments tables are required.

-- 5. The team wants to identify which doctors handled treatments and examine their recorded ratings. What information is needed?
-- The treatment table identifies which doctors handled treatments and doctors table provides the recorded ratings of those doctors.

-- 6. Operations wants to understand whether different room/equipment types are used for different service types. Which tables and columns are required?
-- We need 3 tables : appointments,treatments,rooms. Columns needed: appointment_id,service_type,room_id,room_type,equipment_type.

-- 7. Management wants to compare treatment performance across cities. What information must be connected?
-- we need to connect the patients,appointments, and treatments tables. The patients table provides patient_id and city, the appointments table provides patient_id,appointment_id and service_type, and the treatments table provides appointment_id,treatment_duration_min,waiting_time_min,treatment_cost,and status.

-- 8. Operations wants to investigate whether higher-priority appointments have longer waiting times or different outcomes. What information is needed?
-- we need to connect the appointments and treatments tables. The appointments table provides appointment_id and priority, while the treatments table provides appointment_id,waiting_time_min, and status.

-- 9. Management wants to understand whether treatment outcomes differ across service types. What tables and fields should be combined?
-- we need to combine appointments and treatments tables. The appointments table provides appointment_id and service_type, while the treatments table provides appointment_id and status.

-- 10. The Patient Services team wants to connect each patient to their appointments and treatment outcomes. What relationships are required?
-- we need to connect three tables: patients,appointments and treatments.
-- patients --> appointments (One-to-Many)
-- appointments --> treatments (One-to-Many)

-- Sprint 3: Basic Analysis / Data Exploration

-- 1. What is the total number of patients?
select count(*) as Total_Patients from patients; -- 400

-- 2. What is the total number of appointments?
select count(*) as Total_Appointments from appointments; -- 3000

-- 3. What is the total number of treatment records?
select count(*) as Total_Treatments from treatments; -- 3500

-- 4. What are the different medical service types?
select distinct service_type from appointments; -- Diagnostic Test, Procedure, Consultation, Follow-up, Emergency Care.

-- 5. How many doctors are currently active?
select count(*) as No_of_Active_Doctors from doctors where is_active = 'Yes';  -- 72

-- 6. What are the different room types?
select distinct room_type from rooms; -- Consultation,Observation,Diagnostic, Minor Surgery, Procedure

-- 7. What is the total estimated appointment value?
select sum(estimated_cost) as Total_Estimated_Appointment_value from appointments;  -- 14331792.44

-- 8. What is the average treatment duration?
select avg(treatment_duration_min) as Average_Treatment_Duration from treatments;  -- 38.7151 min


-- Sprint 4: Objective-Based Analysis

-- 4.1 Understand Patient and Appointment Demand

-- ●Compare appointment volume across cities.
select city,
count(*) as total_appointments 
from appointments a join patients p 
on  a.patient_id = p.patient_id 
group by city;
-- Insight: 
-- Appointments by city: Kochi leads with 440, followed by Mumbai 393, Chennai 386 and Hyderabad 382. Pune is lowest with 334.

-- ●Compare appointments across service types and priorities.
select service_type,priority,
count(*) as total_appointments 
from appointments 
group by service_type,priority;
-- Insight: 
-- Appointments by service type: Consultation 1,183; Diagnostic Test 627; Follow-up 539; Procedure 439; Emergency Care 212. 
-- Routine is the largest priority group (2,169), followed by High (587) and Urgent (244).

-- ●Examine appointment volume over time.
select appointment_date,
count(*) as total_appointments 
from appointments 
group by appointment_date;
-- Insight: 
-- Monthly appointment volume: July is highest (276), followed by April (272); February is lowest (219).

-- ●Compare estimated appointment value across patient types.
select patient_type,
sum(estimated_cost) as estimated_cost 
from patients p join appointments a 
on p.patient_id = a.patient_id 
group by patient_type; 
-- Insight: 
-- Estimated appointment value by patient type: 
-- General 7,566,022.11 (1,594 appointments); Insurance 3,817,510.83 (791); Corporate 2,948,259.50 (615).

-- ●Examine booking channels and their contribution to demand.
select booking_channel,
count(*) as Total_appointments 
from appointments 
group by booking_channel;
-- Insight: 
-- Booking channels: App 887, Website 612, Phone 559, Walk-in 557, Referral 385. 
-- The App is the largest contributor.

-- 4.2 Understand Patient Appointment Behaviour

-- ●Compare patients by number of appointments.
select p.patient_id,
patient_name,
count(*) as Total_appointments 
from patients p join appointments a 
on p.patient_id = a.patient_id 
group by patient_id,patient_name;
-- Insight: 
-- 397 of 400 patients have more than one appointment. 
-- The maximum is 15 appointments for one patient. 
-- Top counts are P0216 (15), P0323/P0039/P0181/P0226 (14 each).

-- ●Identify patients with higher cumulative estimated appointment value.
 select p.patient_id,
 patient_name,
 sum(estimated_cost) as Cummulative_estimated_cost 
 from patients p join appointments a 
 on p.patient_id = a.patient_id 
 group by patient_id,patient_name;
 -- Insight: 
 -- Cumulative estimated value by patient: 
 -- use the query below to rank patients. 
 -- The highest-value patient ID/name is data-dependent; the query returns the exact ranking.

-- ●Compare patient activity across cities.
select p.city,
count(distinct p.patient_id) as Total_patients,
count(a.appointment_id) as Total_appointments 
from patients p join appointments a 
on p.patient_id = a.patient_id 
group by city;
-- Insight: 
-- Patient activity by city: Kochi has 57 patients and 440 appointments; Chennai 53/386; Delhi 52/366; Hyderabad,
-- Mumbai and Vijayawada each have 50 patients (382, 393 and 348 appointments respectively); Bengaluru 43/351; Pune 45/334.

-- ●Compare General, Corporate, and Insurance patients.
select patient_type,
count(*) as Total_Patients 
from patients 
group by patient_type;
-- Insight: 
-- Patient types: General 210 patients, Insurance 107, Corporate 83. 
-- By appointment activity: General 1,594; Insurance 791; Corporate 615.

-- ●Examine patient booking patterns over time.
select appointment_date,
count(distinct patient_id) as total_patients,
count(appointment_id) as total_appointments 
from appointments 
group by appointment_date;
-- Insight: 
-- Booking patterns over time: 2025 monthly appointment counts are shown by the following query. 
-- Peak month July (276); low month February (219).

-- 4.3 Evaluate Treatment Performance

-- ●Compare treatment outcomes across cities.
select p.city,
t.status,
count(t.treatment_id) as total_treatments 
from patients  p join appointments a 
on p.patient_id = a.patient_id 
join treatments t 
on t.appointment_id = t.appointment_id 
group by city,status;
-- Insight: 
-- Treatment outcomes by city: Kochi has the most treatment records (520) and 50 rescheduled records; Mumbai has 44 cancellations; 
-- Vijayawada has the highest No-Show count (38) and the lowest cancellation count (22). 
-- Compare rates as well as raw counts because city volumes differ.

-- ●Examine treatment duration and waiting time.
select avg(treatment_duration_min),
avg(waiting_time_min) 
from treatments;
-- Insight: 
-- Average waiting time is 15.62 minutes and average treatment duration is 38.72 minutes.

-- ●Compare Completed, Cancelled, No-Show, Rescheduled, and In Progress outcomes.
select status,
count(*) as Total_treatments 
from treatments 
group by status;
-- Insight: 
-- 70.4% of treatments were completed, showing a good completion rate. 
-- However, 25.7% were cancelled, rescheduled or marked as no-shows, 
-- indicating a need to improve appointment scheduling and patient attendance.

-- ●Identify areas with higher treatment activity or poorer outcomes.
select p.city,
count(t.treatment_id) as total_treatments,
t.status 
from patients p join appointments a 
on p.patient_id = a.patient_id 
join treatments t 
on t.appointment_id = a.appointment_id 
group by p.city,t.status;
-- Insight: 
-- Kochi recorded the highest treatment activity with 520 treatment records, 
-- while Vijayawada had the highest number of no-shows (38). 
-- This suggests the need to monitor workload in Kochi and improve patient attendance in Vijayawada.

-- ●Compare treatment performance over time.
select actual_treatment_date,
count(treatment_id) as Total_treatments,
avg(treatment_duration_min) as average_duration,
avg(waiting_time_min) as average_waiting_time,
avg(treatment_cost) as average_treatment_cost 
from treatments 
group by actual_treatment_date;
-- Insight: 
-- Treatment performance over time can be examined by treatment month. 
-- Dates in the file extend through 3 January 2026; the query groups actual treatment dates by month.


-- 4.4 Understand Doctor and Room Performance

-- ●Compare the number of treatments handled by doctors.
select d.doctor_id,
d.doctor_name,
count(t.treatment_id) as Total_treatments 
from doctors d join treatments t 
on d.doctor_id = t.doctor_id 
group by doctor_id,doctor_name;
-- Insight: 
-- Doctor workload: Dr. Doctor_080 (D080) handled the most treatment records (66); D019 and D051 handled 59 each. 
-- Ratings should be considered alongside workload and outcome mix, not as a standalone performance measure.

-- Compare doctor performance across treatment outcomes
select d.doctor_name,
t.status,
count(t.treatment_id) as total_treatments 
from doctors d join treatments t 
on d.doctor_id = t.doctor_id 
group by doctor_name,status;
-- Insight: Dr. Doctor_080 handled the highest number of treatments (66), 
-- while Dr. Doctor_045 recorded the highest completion rate (84.85%). 
-- However, Dr. Doctor_002 had the highest combined rate of cancellations, 
-- no-shows and rescheduling (46.88%), indicating an area for further review.

-- ●Examine treatment duration across doctors.
select d.doctor_id,
doctor_name,
avg(treatment_duration_min) as average_treatment_duration 
from doctors d join treatments t 
on d.doctor_id = t.doctor_id 
group by doctor_id,doctor_name;
-- Insight: 
-- Dr. Doctor_079 recorded the highest average treatment duration (49.63 minutes), 
-- while Dr. Doctor_066 recorded the lowest (29.40 minutes). 
-- This indicates differences in treatment duration across doctors, which may require further investigation.

-- ●Compare room usage across room types and equipment types.
select room_type,
equipment_type,
count(treatment_id) as total_treatments 
from rooms r join treatments t 
on r.room_id = t.room_id 
group by room_type,equipment_type;
-- Insight: 
-- Observation rooms had the highest usage (902 treatments), followed by Consultation rooms (856), 
-- while Procedure rooms had the lowest (460). 
-- Endoscopy equipment was used most frequently (822 treatments), 
-- indicating higher demand for these room and equipment resources.

-- ●Evaluate treatment performance across rooms.
select r.room_id,
r.room_type, 
count(treatment_id) as Total_treatments,
avg(treatment_duration_min) as average_duration,
avg(waiting_time_min) as average_waiting_time,
avg(treatment_cost) as average_treatment_cost 
from treatments t join rooms r 
on r.room_id = t.room_id 
group by room_id,room_type;
-- Insight: 
-- Observation rooms had the highest treatment activity (902 records), 
-- while Procedure rooms had the longest average treatment duration (41.60 minutes). 
-- Minor Surgery rooms recorded the highest average waiting time (16.03 minutes), 
-- indicating opportunities to improve room efficiency and patient flow.

-- 4.5 Identify Treatment and Appointment Problems

-- ●Identify appointments requiring multiple treatment attempts.
select appointment_id, 
max(treatment_attempt) as total_attempts 
from treatments  
group by appointment_id 
having total_attempts > 1;
-- Insight: 
-- Multiple attempts: 500 appointments have a second attempt; 2,500 have only one attempt. 
-- Mean waiting time by maximum attempt number: one-attempt appointments 15.48 minutes; 
-- two-attempt appointments 15.96 minutes.

-- ●Find common problem statuses and patterns.
select status, 
count(treatment_id) as Total_treatments,
avg(treatment_attempt) as avg_attempts,
avg(treatment_duration_min) as average_duration,
avg(waiting_time_min) as average_waiting_time 
from treatments 
group by status;
-- Insight: 
-- Common problem statuses: Rescheduled 366, Cancelled 283 and No-Show 251. 
-- Review these categories by service, city, doctor and time period to identify operational patterns.

-- ●Compare waiting time for appointments with multiple attempts.
select appointment_id, 
max(treatment_attempt) as total_attempts,
avg(waiting_time_min) as average_waiting_time 
from treatments  
group by appointment_id 
having total_attempts > 1;
-- Insight: 
-- Appointments with multiple treatment attempts had a slightly higher average waiting time (15.96 minutes) 
-- compared to single-attempt appointments (15.48 minutes). 
-- This indicates that repeated treatment attempts are associated with a small increase in waiting time.

-- ●Identify cities or service types with more cancellations, no-shows, or rescheduling.
select p.city,
t.status,
count(t.treatment_id) as total_count 
from patients p join appointments a 
on p.patient_id = a.patient_id 
join treatments t 
on a.appointment_id = t.appointment_id 
where t.status in ('Cancelled','No-Show','Rescheduled') 
group by p.city,t.status;
-- Insight: 
-- Cities/service types with more problems: 
-- by raw count, Kochi has the most cancellations (46) and reschedules (50); 
-- Vijayawada has the most No-Shows (38). 
-- By service type, Consultation has the highest cancellation (113), 
-- No-Show (107) and reschedule (132) counts, but it also has the largest volume. 
-- Use percentages for fair comparisons.

-- ●Investigate whether priority level is associated with waiting time or treatment outcomes.
SELECT
    a.priority,
    COUNT(t.treatment_id) AS total_treatments,
    ROUND(AVG(t.waiting_time_min), 2) AS avg_waiting_time,
    SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN t.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN t.status = 'No Show' THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN t.status = 'Rescheduled' THEN 1 ELSE 0 END) AS rescheduled
FROM appointments a
JOIN treatments t
ON a.appointment_id = t.appointment_id
GROUP BY a.priority
ORDER BY avg_waiting_time DESC;
-- Insight: 
-- Priority vs waiting time/outcomes: 
-- average waits are High 15.47 min, Routine 15.62 min and Urgent 15.97 min.
-- Completed rates are very similar (High 70.70%, Routine 70.26%, Urgent 70.89%). 
-- Cancelled rates are also similar (about 8%); therefore this dataset shows only small differences, 
-- not a strong visible association.


-- Final conclusions and practical recommendations: 

-- Consultation is the dominant service by appointment and treatment volume. 
-- Ensure sufficient consultation capacity and review its high absolute number of cancellations, 
-- no-shows and reschedules.

-- Kochi has the largest appointment and treatment volumes. 
-- Review staffing and room capacity there; compare outcome percentages before concluding it performs worse.

-- July and April are the busiest appointment months in 2025. 
-- Plan staffing and room availability around demand peaks.

-- The App is the leading booking channel. 
-- Continue monitoring its demand and conversion to completed visits.

-- Average waits are close across priority categories. 
-- Urgent appointments have a slightly higher average wait; review urgent-case workflows, 
-- but do not infer causation from this descriptive analysis.

-- The 500 second-attempt appointments should be examined separately 
-- because repeat attempts increase treatment-row counts and may affect averages.

-- Use outcome rates, sample sizes and case mix together when comparing cities, services, doctors and rooms. 
-- Counts alone can be misleading.