--Q1. Who is the senior most employee based on job title?

Select Top(1)*
From MusicProject..employee
Order by Levels DESC


--Q2. Which countries have the most invoices?

Select billing_country, count(billing_country)
From MusicProject..invoice
Group By billing_country
order By 2 DESC


--Q3. What are the top 3 values of total invoice?

Select Top(3)*
From MusicProject..invoice
Order By total DESC


--Q4. Which city has the best customers? 
--    Return one city that has the highest sum of invoice totals

Select Top(1) billing_city, billing_country, sum(total) as Sum_of_Invoices
From MusicProject..invoice
Group by Billing_city,billing_country
Order By 3 DESC

 
--Q5. Who is the best customer?
--    Person who has spent the most money

Select c.Customer_id,c.first_name,c.last_name, Sum(i.total) as totally
From MusicProject..Customer c
Join MusicProject..Invoice i
	ON c.customer_id=i.customer_id
Group By c.customer_id,c.first_name,c.last_name
Order By totally DESC


--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--	  Return your list ordered alphabetically by email starting with A. 


Select DISTINCT email,first_name, last_name
From MusicProject..Customer
Join MusicProject..Invoice ON Customer.Customer_id=Invoice.customer_id
Join MusicProject..Invoice_line ON Invoice.Invoice_id=Invoice_line.Invoice_id
Join Track ON Invoice_line.Track_id = Track.Track_id
Join Genre ON track.Genre_id = Genre.Genre_id
Where Genre.name LIKE 'ROCK'
Order by email


--Q7. Let's invite the artists who have written the most rock music in our dataset. 
--    Write a query that returns the Artist name and total track count of the top 10 rock bands.


Select Distinct Top(10) Artist.Name, Count (track.name)
From Artist
Join Album On Artist.Artist_id=Album.Artist_ID
Join Track On Album.Album_Id=track.Album_Id
Join Genre On track.Genre_id=Genre.Genre_id
Where Genre.Name='Rock'
Group By Artist.Name
Order By 2 DESC


--Q8. Return all the track names that have a song length longer than the average song length. 
--    Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.


Select name, milliseconds
From track
Where milliseconds > ( Select Avg(milliseconds)
					  From track)
Order By milliseconds DESC


--Q9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent


Select customer.customer_id, customer.first_name, customer.last_name,Sum(track.unit_price)
From MusicProject..Customer 
Join MusicProject..Invoice ON Customer.Customer_id=Invoice.customer_id
Join MusicProject..Invoice_line ON Invoice.Invoice_id=Invoice_line.Invoice_id
Join Track ON Invoice_line.Track_id = Track.Track_id
Join Genre ON track.Genre_id = Genre.Genre_id
Join Album ON track.album_id = Album.album_id
Join Artist ON Album.Album_id = Artist.artist_id
Group By customer.customer_id, customer.first_name, customer.last_name
Order By customer.customer_id


--Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--     with the highest amount of purchases. 


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY customer.country ASC, COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	--ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


--Q11. Write a query that determines the customer that has spent the most on music for each country. 
--	   Write a query that returns the country along with the top customer and how much they spent. 

WITH Amount_spent AS

(Select first_name, last_name,customer.country, Sum(invoice.total) as Total_Amount_Spent, ROW_NUMBER() OVER (PARTITION BY Country Order By Sum(invoice.total) DESC) as Row_Number
From customer
Join invoice ON invoice.customer_id = customer.customer_id
Group By customer.country, first_name, last_name
)

Select *
From Amount_spent
Where Row_Number <2