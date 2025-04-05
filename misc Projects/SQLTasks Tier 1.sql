/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT *
FROM Facilities
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

4

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < monthlymaintenance * 0.2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 );

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT
    name,
    monthlymaintenance,
    CASE
        WHEN monthlymaintenance > 100 THEN 'expensive'
        ELSE 'cheap'
    END AS cost_category
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members
);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
    f.name AS court_name,
    CONCAT(m.firstname, ' ', m.surname) AS member_name
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
JOIN Members AS m ON b.memid = m.memid
WHERE f.name LIKE 'Tennis Court%'
  AND b.memid != 0
ORDER BY member_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
    f.name AS facility_name,
    CONCAT(m.firstname, ' ', m.surname) AS member_name,
    b.slots * CASE 
        WHEN b.memid = 0 THEN f.guestcost
        ELSE f.membercost
    END AS cost
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
JOIN Members AS m ON b.memid = m.memid
WHERE DATE(b.starttime) = '2012-09-14'
  AND b.slots * CASE 
        WHEN b.memid = 0 THEN f.guestcost
        ELSE f.membercost
    END > 30
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT 
    sub.facility_name,
    sub.member_name,
    sub.cost
FROM (
    SELECT 
        f.name AS facility_name,
        CONCAT(m.firstname, ' ', m.surname) AS member_name,
        b.slots * CASE 
            WHEN b.memid = 0 THEN f.guestcost
            ELSE f.membercost
        END AS cost,
        DATE(b.starttime) AS booking_date
    FROM Bookings AS b
    JOIN Facilities AS f ON b.facid = f.facid
    JOIN Members AS m ON b.memid = m.memid
) AS sub
WHERE sub.booking_date = '2012-09-14'
  AND sub.cost > 30
ORDER BY sub.cost DESC;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Code:

SELECT 
    f.name AS facility_name,
    SUM(
        b.slots * CASE
            WHEN b.memid = 0 THEN f.guestcost
            ELSE f.membercost
        END
    ) AS total_revenue
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
GROUP BY f.facid, f.name
HAVING total_revenue < 1000
ORDER BY total_revenue;

Output:

('Table Tennis', 180)
('Snooker Table', 240)
('Pool Table', 270)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

Code:

SELECT 
    m.firstname AS member_firstname,
    m.surname AS member_surname,
    r.firstname AS recommended_by_firstname,
    r.surname AS recommended_by_surname
FROM Members AS m
LEFT JOIN Members AS r ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;

Output:

('Florence', 'Bader', 'Ponder', 'Stibbons')
('Anne', 'Baker', 'Ponder', 'Stibbons')
('Timothy', 'Baker', 'Jemima', 'Farrell')
('Tim', 'Boothe', 'Tim', 'Rownam')
('Gerald', 'Butters', 'Darren', 'Smith')
('Joan', 'Coplin', 'Timothy', 'Baker')
('Erica', 'Crumpet', 'Tracy', 'Smith')
('Nancy', 'Dare', 'Janice', 'Joplette')
('David', 'Farrell', None, None)
('Jemima', 'Farrell', None, None)
('GUEST', 'GUEST', None, None)
('Matthew', 'Genting', 'Gerald', 'Butters')
('John', 'Hunt', 'Millicent', 'Purview')
('David', 'Jones', 'Janice', 'Joplette')
('Douglas', 'Jones', 'David', 'Jones')
('Janice', 'Joplette', 'Darren', 'Smith')
('Anna', 'Mackenzie', 'Darren', 'Smith')
('Charles', 'Owen', 'Darren', 'Smith')
('David', 'Pinker', 'Jemima', 'Farrell')
('Millicent', 'Purview', 'Tracy', 'Smith')
('Tim', 'Rownam', None, None)
('Henrietta', 'Rumney', 'Matthew', 'Genting')
('Ramnaresh', 'Sarwin', 'Florence', 'Bader')
('Darren', 'Smith', None, None)
('Darren', 'Smith', None, None)
('Jack', 'Smith', 'Darren', 'Smith')
('Tracy', 'Smith', None, None)
('Ponder', 'Stibbons', 'Burton', 'Tracy')
('Burton', 'Tracy', None, None)
('Hyacinth', 'Tupperware', None, None)
('Henry', 'Worthington-Smyth', 'Tracy', 'Smith')

/* Q12: Find the facilities with their usage by member, but not guests */

Code:

SELECT 
    f.name AS facility_name,
    COUNT(*) AS total_bookings,
    SUM(b.slots) AS total_slots_used
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.facid, f.name
ORDER BY f.name;

Output:

('Badminton Court', 344, 1086)
('Massage Room 1', 421, 884)
('Massage Room 2', 27, 54)
('Pool Table', 783, 856)
('Snooker Table', 421, 860)
('Squash Court', 195, 418)
('Table Tennis', 385, 794)
('Tennis Court 1', 308, 957)
('Tennis Court 2', 276, 882)

/* Q13: Find the facilities usage by month, but not guests */

Code: (corrected for SQLite)

SELECT 
    f.name AS facility_name,
    strftime('%Y-%m', b.starttime) AS booking_month,
    COUNT(*) AS total_bookings,
    SUM(b.slots) AS total_slots_used
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name, booking_month
ORDER BY booking_month, f.name;


Output:

('Badminton Court', '2012-07', 51, 165)
('Massage Room 1', '2012-07', 77, 166)
('Massage Room 2', '2012-07', 4, 8)
('Pool Table', '2012-07', 103, 110)
('Snooker Table', '2012-07', 68, 140)
('Squash Court', '2012-07', 23, 50)
('Table Tennis', '2012-07', 48, 98)
('Tennis Court 1', '2012-07', 65, 201)
('Tennis Court 2', '2012-07', 41, 123)
('Badminton Court', '2012-08', 132, 414)
('Massage Room 1', '2012-08', 153, 316)
('Massage Room 2', '2012-08', 9, 18)
('Pool Table', '2012-08', 272, 303)
('Snooker Table', '2012-08', 154, 316)
('Squash Court', '2012-08', 85, 184)
('Table Tennis', '2012-08', 143, 296)
('Tennis Court 1', '2012-08', 111, 339)
('Tennis Court 2', '2012-08', 109, 345)
('Badminton Court', '2012-09', 161, 507)
('Massage Room 1', '2012-09', 191, 402)
('Massage Room 2', '2012-09', 14, 28)
('Pool Table', '2012-09', 408, 443)
('Snooker Table', '2012-09', 199, 404)
('Squash Court', '2012-09', 87, 184)
('Table Tennis', '2012-09', 194, 400)
('Tennis Court 1', '2012-09', 132, 417)
('Tennis Court 2', '2012-09', 126, 414)
