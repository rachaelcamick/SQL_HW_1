USE sakila;


--Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;


--Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT CONCAT (UPPER(first_name), " ", UPPER(last_name)) AS "Actor Name" FROM actor;


--You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name LIKE "Joe%";


--Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE "%GEN%";


--Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
--ASC is the default for orderby, but adding it for readability
SELECT * FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name ASC, first_name ASC;


--Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh", "China");


----create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor ADD description BLOB AFTER last_update;


--delete the description column
ALTER TABLE actor DROP COLUMN description;


--List the last names of actors, as well as how many actors have that last name
SELECT DISTINCT last_name, COUNT(last_name) FROM actor GROUP BY last_name;


--List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
--Note: this does not work because you cannot use aggregate functions in a where clause:
--SELECT DISTINCT last_name, COUNT(last_name) FROM actor WHERE COUNT(last_name) >= 2 GROUP BY last_name;
--Need to move the aggregate function to a "having" clause
SELECT DISTINCT last_name, COUNT(last_name) FROM actor GROUP BY last_name HAVING COUNT(last_name) >= 2;


--The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
-- Find ID for actor 
SELECT * FROM actor WHERE first_name = "GROUCHO" AND last_name = "Williams";
-- The actor id is 172
UPDATE actor SET first_name = "HARPO" WHERE actor_id = 172;


--Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
--In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO" AND last_name = "WILLIAMS";


--You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address.
-- Using left outer join to ensure that no staff members are lost if no address data on file for them
-- if the column names in joined tables are unique, the name of the table does not need to be added to column name, but i added it anyways for clarity
SELECT sf.first_name, sf.last_name, CONCAT(ad.address, " ", ad.district, " ", ad.postal_code) AS full_address FROM staff AS sf LEFT OUTER JOIN address AS ad ON sf.address_id = ad.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT sf.first_name, sf.last_name, SUM(pmt.amount) AS total_amount FROM staff AS sf INNER JOIN payment AS pmt ON sf.staff_id = pmt.staff_id 
WHERE pmt.payment_date BETWEEN DATE("2005-08-01") AND DATE("2005-08-31") GROUP BY sf.staff_id;


--6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(fac.actor_id) AS number_of_actors FROM film INNER JOIN film_actor AS fac ON film.film_id = fac.film_id GROUP BY film.title;


--6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, COUNT(iy.film_id) AS copies_available FROM film INNER JOIN inventory AS iy ON film.film_id = iy.film_id WHERE film.title = "Hunchback Impossible"; 


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(py.amount) AS "Total Amount Paid" FROM customer AS cu INNER JOIN payment AS py ON cu.customer_id = py.customer_id GROUP BY py.customer_id ORDER BY cu.last_name ASC;


-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- Could do: SELECT film.title FROM film INNER JOIN `language` AS lng ON film.language_id = lng.language_id 
-- WHERE film.title LIKE "K%" OR film.title LIKE "Q%" AND lng.`name` = "English";
SELECT title FROM film WHERE language_id IN (SELECT language_id FROM `language` WHERE `name` = "English")
AND film.title LIKE "K%" OR film.title LIKE "Q%";


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN 
(SELECT actor_id FROM film_actor WHERE film_id IN
(SELECT film_id FROM film WHERE title = "Alone Trip"));
 

--7c. need the names and email addresses of all Canadian customers.
SELECT * FROM country WHERE country = "Canada" 
-- Canada's Country ID is 20
SELECT cu.first_name, cu.last_name, cu.email FROM customer AS cu INNER JOIN address AS ad ON cu.address_id = ad.address_id 
INNER JOIN city AS cty ON ad.city_id = cty.city_id 
INNER JOIN country AS cn ON cty.country_id = cn.country_id WHERE cn.country_id = 20;


--7d. Identify all movies categorized as family films
SELECT film.title, film.release_year FROM film INNER JOIN film_category AS fc ON film.film_id = fc.film_id 
INNER JOIN category AS cat ON fc.category_id = cat.category_id 
WHERE cat.`name` = "Family";


--7e. Display the most frequently rented movies in descending order.
SELECT fm.title, COUNT(rn.inventory_id) AS "Number of Times Rented" FROM film AS fm 
INNER JOIN inventory AS iv ON fm.film_id = iv.film_id
INNER JOIN rental AS rn ON iv.inventory_id = rn.inventory_id GROUP BY rn.inventory_id 
ORDER BY COUNT(rn.inventory_id) DESC;


--7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id AS "Store ID", SUM(py.amount) AS "Store Revenue" FROM store AS st 
INNER JOIN staff AS sf ON st.store_id = sf.store_id
INNER JOIN payment AS py ON sf.staff_id = py.staff_id GROUP BY st.store_id;


--7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id AS "Store ID", cty.city AS "City", cn.country AS "Country" FROM store AS st INNER JOIN address AS ad ON st.address_id = ad.address_id
INNER JOIN city AS cty ON ad.city_id = cty.city_id 
INNER JOIN country AS cn ON cty.country_id = cn.country_id;


--7h. List the top five genres in gross revenue in descending order. 
--(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
 --RIGHT and INNER joins on rental and payment tables yield same result, except the right join returns a null value that earns a revenue of 9.95
-- this is excluded because null value can't exist in rental id column of rental table bc rental id is primary id; however, foreign keys can have null
-- values which is why py.rental_id can have a null value. other than this, though, a foreign key cannot have values that differ from the primary key
-- that it is referencing
SELECT cat.`name` AS "GENRE", SUM(py.amount) AS "Revenue" FROM category AS cat 
INNER JOIN film_category AS fc ON cat.category_id = fc.category_id 
INNER JOIN inventory AS iv ON fc.film_id = iv.film_id
INNER JOIN rental AS rn ON iv.inventory_id = rn.inventory_id
RIGHT JOIN payment AS py ON rn.rental_id = py.rental_id GROUP BY cat.`name` 
ORDER BY SUM(py.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
--Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT cat.`name` AS "GENRE", SUM(py.amount) AS "Revenue" FROM category AS cat 
INNER JOIN film_category AS fc ON cat.category_id = fc.category_id 
INNER JOIN inventory AS iv ON fc.film_id = iv.film_id
INNER JOIN rental AS rn ON iv.inventory_id = rn.inventory_id
RIGHT JOIN payment AS py ON rn.rental_id = py.rental_id GROUP BY cat.`name` 
ORDER BY SUM(py.amount) DESC LIMIT 5;

--8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres; 


--8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres; 
















