# CSI2132 Project
A lightweight R Shiny app for managing dental clinic databases (DCMS).

## Installation Instructions
### 1. Download and install R
Go to https://cloud.r-project.org/ and download the appropriate version of R for your system. Our project was written on R version 4.1.2, but other recent versions should work fine.

Install R according to website and installer instructions.

### 2. Download and install RStudio IDE
Download the R Studio IDE from https://www.rstudio.com/products/rstudio/download/. The basic free version will work fine.

### 3. Clone this repo onto your local machine
Any way you like!

### 4. Open [app.R](./app.R) in the RStudio IDE

### 5. Install packages
Several packages are necessary to run this project correctly. RStudio _should_ prompt you to install them, but if that doesn't happen you can still install them from the packages tab in the IDE using CRAN. 

You will need the following packages: `shiny`, `DBI`, `shinyJS`, `shinyTime`, `RPostgres`, `DT`, `data.table`, `lubridate`, `shinyalert`, and `sjmisc`.

You can find more information on how to install packages in RStudio [here](http://derekogle.com/IFAR/supplements/installations/InstallPackagesRStudio.html).

### 6. Set up your PostgreSQL database
You'll want to set up a fresh, empty PostgreSQL database for this project. If you don't know how to do that or don't already have PostgreSQL set up, you can find out how [here](https://www.postgresqltutorial.com/postgresql-getting-started/install-postgresql/).

Make sure you install **pgAdmin4** while installing PostgreSQL.

### 7. Install DCMS schema
The database schema for this app is contained in the [CSI2132Project-v4](./CSI2132Project-v4.txt) file.

Open pgAdmin4 into your PostgreSQL server, and open the query tool on your database. In the top banner you'll find the "Open File" button:

![image](https://user-images.githubusercontent.com/55165027/163302115-29c617fd-e63c-4c24-a54c-29f8a755e8d2.png)

Click that, and select CSI2132Project-v4.txt from the locally-cloned repo. Then, back in pgAdmin4, click the "Execute" button to run the query and apply the schema.

![image](https://user-images.githubusercontent.com/55165027/163302241-f204c14c-100e-4a6a-96f0-633ce5d48c1c.png)

Doing this will also inject some dummy data into your DB.

### 8. Connect to your database
Use the following command in your RStudio terminal:

`library(DBI)`

Then, set up your connection using:

`con <- dbConnect(RPostgres::Postgres(), host='<hostname>', port='<portno>', dbname='<dbname>', user='<dbusername>',password='<dbpw>')`

You'll know this has worked if the command returns nothing.

### 9. Launch the app
Launch the app using the 'Run App' button in RStudio! You can find login information for users in the database schema file.
