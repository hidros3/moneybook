# SQL Connecting setting
install.packages("RPostgreSQL")
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "moneybookdb", host="localhost",port=5432, user="coupang")
dt<-dbGetQuery(con, "SELECT week_num, type, SUM(PRICE) FROM (SELECT *, EXTRACT(WEEK FROM date) AS week_num, EXTRACT(YEAR FROM date) AS year FROM spends ORDER BY week_num) A GROUP BY week_num, type ORDER BY week_num DESC")

# Plot simple a graph
attach(dt)
plot(week_num,sum)
title("SPENDS BY WEEK")
detach(dt)
