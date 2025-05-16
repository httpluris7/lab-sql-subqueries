USE sakila



-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT 
COUNT(*) AS num_copies
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';


-- List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT 
film_id,
title,
length
FROM film
WHERE length > (
SELECT AVG(length)
FROM film
);


-- Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT 
a.actor_id,
a.first_name,
a.last_name
FROM actor a
WHERE a.actor_id IN (
SELECT fa.actor_id
FROM film_actor fa
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'Alone Trip'
);


-- Identify all movies categorized as family films.

SELECT 
f.film_id,
f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';


-- Retrieve the name and email of customers from Canada using both subqueries and joins.

SELECT 
first_name,
last_name,
email
FROM customer
WHERE address_id IN (
SELECT a.address_id
FROM address a
JOIN city ci      ON a.city_id    = ci.city_id
JOIN country co   ON ci.country_id = co.country_id
WHERE co.country = 'Canada'
);


-- Determine which films were starred by the most prolific actor in the Sakila database.

-- step 1: find the actor_id with the most film appearances
WITH prolific AS (
  SELECT 
    actor_id,
    COUNT(*) AS cnt
  FROM film_actor
  GROUP BY actor_id
  ORDER BY cnt DESC
  LIMIT 1
)
-- step 2: list that actor’s films
SELECT 
  f.film_id,
  f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (SELECT actor_id FROM prolific);


-- Find the films rented by the most profitable customer in the Sakila database.


WITH top_customer AS (
  SELECT 
    customer_id,
    SUM(amount) AS total_paid
  FROM payment
  GROUP BY customer_id
  ORDER BY total_paid DESC
  LIMIT 1
)

SELECT DISTINCT
  f.film_id,
  f.title
FROM rental r
JOIN payment p   ON r.rental_id    = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f      ON i.film_id      = f.film_id
WHERE p.customer_id = (SELECT customer_id FROM top_customer);


-- Retrieve the client_id and the total_amount_spent of those clients
-- who spent more than the average of the total_amount spent by each client.

SELECT
  customer_id AS client_id,
  SUM(amount)  AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
  SELECT AVG(customer_total)
  FROM (
    SELECT SUM(amount) AS customer_total
    FROM payment
    GROUP BY customer_id
  ) AS totals
);

