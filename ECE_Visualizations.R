# install.packages('forecast',dependencies = T)
# install.packages(c('tseries','expsmooth','lmtest','zoo','seasonal','haven','fma'))
# library(tseries)
# library(forecast)
# library(haven)
# library(fma)
# library(expsmooth)
# library(lmtest)
# library(zoo)
# library(seasonal)
# library(dplyr)

# Load training data
ozone_t <- read.csv('/Volumes/GoogleDrive/My Drive/Academics/Grad School/IAA COURSES/FALL1/AA502 - ANALYTICS METHODS & APPS/TIME SERIES/TIME SERIES HW/TSHW2/ozonetrain.csv')
head(ozone_t)

#Renaming ozone conc column for easier referencing
ozone_t <- rename(ozone_t,c("ozone_conc"="Daily_Max_8_hour_Ozone_Concentra"))

# Rolling up data to monthly using dplyr (to make plot easier to read)
ozone_t_monthly <- ozone_t %>%
  select(Date, ozone_conc) %>%
  mutate(Date=as.Date(Date, format= "%m/%d/%Y"),month=month(Date,label=TRUE),year=year(Date)) %>%
  group_by(month,year) %>%
  summarize(avg_ozoneconc=mean(ozone_conc))

# Creation of Time Series Data Object #
conc <- ts(ozone_t_monthly$avg_ozoneconc, start = 2014, frequency =12)

# Time Series Decomposition ...STL#
decomp_stl <- stl(conc, s.window = 7)

# Time Series Decomposition ...Classical#
decomp_class_m <-
  decompose(conc, type = "multiplicative", filter = NULL)
decomp_class_a <-
  decompose(conc, type = "additive", filter = NULL)

# Plot the individual components of the time series for STL and Classical
plot(decomp_stl)
plot(decomp_class_m)
plot(decomp_class_a)

# Plot the non-decomposed ts (grey), with trend 
# component overlay (red) using STL
plot(
  conc,
  col = "grey",
  main = "Raleigh Ozone Concentration - Trend/Cycle",
  xlab = "Month",
  ylab = "Monthly Average of Ozone Concentration (ppm)",
  lwd = 2,
  sub = "Decomposed Using STL"
)
lines(decomp_stl$time.series[, 2], col = "red", lwd = 2)

# Plot the non-decomposed ts (grey), with trend 
# component overlay (red) using Classical Multiplicative
plot(
  decomp_class_m$x,
  col = "grey",
  main = "Raleigh Ozone Concentration - Trend/Cycle",
  xlab = "Month",
  ylab = "Monthly Average of Ozone Concentration (ppm)",
  lwd = 2,
  sub = "Decomposed Using Multiplicative Classical"
)
lines(decomp_class_m$trend, col = "red", lwd = 2)

# Plot the non-decomposed ts (grey), with trend 
# component overlay (red) using Classical Additive
plot(
  decomp_class_a$x,
  col = "grey",
  main = "Raleigh Ozone Concentration - Trend/Cycle",
  xlab = "Month",
  ylab = "Monthly Average of Ozone Concentration (ppm)",
  lwd = 2,
  sub = "Decomposed Using Additive Classical"
)
lines(decomp_class_a$trend, col = "red", lwd = 2)

# Plot the non-decomposed ts (grey), with seasonal 
# component overlay (red) using STL
seas_stl=conc-decomp_stl$time.series[,1]
plot(
  conc,
  col = "grey",
  main = "Raleigh Ozone Concentration - Seasonally Adjusted",
  xlab = "Month",
  ylab = "Monthly Average of Ozone Concentration (ppm)",
  lwd = 2,
  sub = "Decomposed Using STL"
)
lines(seas_stl, col = "red", lwd = 2)

# Plot the non-decomposed ts (grey), with seasonal 
# component overlay (red) using Classical multiplicative
# seasonally_adjusted line is much lower in this graph and isn't shown
seas_class_m=decomp_class_m$x-decomp_class_m$seasonal
plot(
  decomp_class_m$x,
  col = "grey",
  main = "Raleigh Ozone Concentration - Seasonally Adjusted",
  xlab = "Month",
  ylab = "Monthly Average of Ozone Concentration",
  lwd = 2,
  sub = "Decomposed Using Multiplicative Classical"
)
lines(seas_class_m, col = "red", lwd = 2)

# Plot the non-decomposed ts (grey), with seasonal 
# component overlay (red) using Classical additive
seas_class_a=decomp_class_a$x-decomp_class_a$seasonal
plot(
  decomp_class_a$x,
  col = "grey",
  main = "Raleigh Ozone Concentration - Seasonally Adjusted",
  xlab = "Month",
  ylab = "Monthly Average of Ozone Concentration",
  lwd = 2,
  sub = "Decomposed Using Additive Classical"
)
lines(seas_class_a, col = "red", lwd = 2)

# Monthplot of Ozone_conc
monthplot(
  decomp_stl$time.series[, "seasonal"],
  main = "Raleigh Ozone Concentration - Monthly Effects",
  ylab = "Seasonal Sub Series",
  xlab = "Seasons (Months)",
  lwd = 2,
  sub = "Decomposed Using STL"
)
