SELECT week_num, type, SUM(PRICE) FROM 
   (SELECT *, 
   EXTRACT(WEEK FROM date) AS week_num, 
   EXTRACT(YEAR FROM date) AS year
   FROM spends
   ORDER BY week_num
   ) A
GROUP BY week_num, type
ORDER BY week_num DESC