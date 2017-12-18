# Course Project 1; plot3 code
library(lubridate)

## Download file, unzip, and read in as CSV
# Don't bother doing this again if data has already been read in
if(!exists("powerData_filtered"))
{
  dataSetURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
  if (!file.exists("./data"))
      {dir.create("./data")};
  if (!file.exists("./data/household_power_consumption.zip")) 
      {download.file(dataSetURL,destfile="./data/household_power_consumption.zip")};
  if (!file.exists("./data/household_power_consumption.txt")) 
      {unzip("./data/household_power_consumption.zip",exdir="./data")};
  # Coerce column formats to character for date and time, and numeric for others. Specify "?" as NA value
  powerData <- read.csv("./data/household_power_consumption.txt", 
                        colClasses = c("character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"),
                        sep=";",
                        header=TRUE,
                        stringsAsFactors=FALSE,
                        na.strings=c("?"),
                        row.names = NULL)

  ## Convert Date column to "Date" class and filter for the dates we are interested in, ie 2007-02-01 and 2007-02-02.
  ## Using a pipeline and then convert to a "tibble" and storing result in powerData_filtered
  powerData_filtered <- tbl_df(
    {
      powerData %>% 
      mutate(Date=as.Date(Date,format="%d/%m/%Y"),) %>% 
      filter(Date=="2007-02-01" | Date=="2007-02-02")
    }
  )
  ## Get rid of the huge data frame
  rm(powerData)
}

# Add a DateTime_str column which is Date and Time column concatenated
# Add a DateTime column which is in date-time class so that it can be used numerically in X axis
# Don't bother doing this again if it already exists
if(!exists("powerData_plot2"))
{
    powerData_plot2 <- 
    {
        powerData_filtered %>% 
        filter(!is.na(Global_active_power)) %>% 
        mutate(DateTime_str=strftime(paste(Date,Time),format="%d/%m/%Y %H:%M:%S"),DateTime=dmy_hms(DateTime_str))
    }
}

# Open PNG device
png(file="plot4.png",width = 480, height = 480, units = "px")

# Plot 4 graphs, starting with upper left, then lowerleft, upper right, and lower right
par(mfcol=c(2,2))


# Top left plot, same as plot 2, slight difference in Y axis label
with(powerData_plot2, 
     {
       plot(DateTime,Global_active_power,type="n",ylab="Global Active Power",xlab="");
       lines(DateTime,Global_active_power);
     })

# Bottom left, same as plot 3, no box around legend
with(powerData_plot2, 
     {
       plot(DateTime,Sub_metering_1,type="n",ylab="Energy sub metering",xlab="");
       lines(DateTime,Sub_metering_1,col="black");
       lines(DateTime,Sub_metering_2,col="red");
       lines(DateTime,Sub_metering_3,col="blue");
       legend("topright",
              legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
              col=c("black","red","blue"),
              lty=1,bty="n");
       
     })

# Top right plot is line graph of Voltage as a function of DateTime.
with(powerData_plot2, plot(DateTime,Voltage,type="l",ylab="Voltage",xlab="datetime"))

# Bottom right plot is line graph of Global_reactive_power as a function of DateTime.
with(powerData_plot2, plot(DateTime,Global_reactive_power,type="l",ylab="Global_reactive_power",xlab="datetime"))

# Close PNG device
dev.off()
