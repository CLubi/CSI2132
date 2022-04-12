# To connect to your class DB, use the following command in your R console:
# con <- dbConnect(RPostgres::Postgres(), host='web0.eecs.uottawa.ca', port='15432', dbname='<uottawa email prefix>', user='<uottawa email prefix>',password='<uottawa email password>')

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DBI)
library(odbc)
library(shiny)
library(shinyjs)
library(shinyTime)



# UI
ui <- dashboardPage(
    dashboardHeader(title = "Dental Clinic"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Authentification",tabName = "aut", icon = icon("trophy",lib = 'font-awesome')),
            
            # Client Sidebar - make sure accomodate for all "responsibilities"
            menuItemOutput("home"), # upcoming appointments
            menuItemOutput("aptC"), # all their past appointments, book new appointments
            menuItemOutput("recC") # View all record: incoices, insurance claims
            ,
            #Admin/Manager Sidebar
            menuItemOutput("aptA"), #to schedule and view,search appoints. So they need the option to edit that table in DB
            menuItemOutput("recA"), #To view,search and edit past appoints/invoices/insurance claims
            menuItemOutput("patA"), # to look up a patient and return everything on that patient
            menuItemOutput("empA"), # to look up a employee and return everything on that employee
            menuItemOutput("sqlA"), # Admin has the option to write their own sql queries.

            #Dentist/hygenist Sidebar
            menuItemOutput("aptD"), #to view ,search(not edit) appoints.
            menuItemOutput("patD"), # to view, search (not edit) patient table and patient records

            #Receptionist Sidebar
            menuItemOutput("aptR"), #to schedule and view,search appoints. So they need the option to edit that table in DB
            menuItemOutput("recR"), #To view,search and edit past appoints/invoices/insurance claims
            menuItemOutput("patR") # to view,search and edit patient table
            
        )
    ),
    dashboardBody(
        tabItems(
            tabItem("aut",
                    fluidPage(
                        h1("Authentification"),
                        textInput(inputId = 'userName', label = 'User Name: ', value = "", width = NULL, placeholder = NULL),
                        passwordInput(inputId = 'password', label = 'Password: ', value = "", width = NULL, placeholder = NULL),
                        selectInput(inputId = 'type',
                                    label = 'Login as :',
                                    choices = c('Client','Employee'),
                                    selected = 'Client',
                                    multiple = FALSE
                                    ),
                        textOutput("invalidLogin"),
                        actionButton("loginAction","Login",icon = icon("sign-in-alt",lib = 'font-awesome'))
                    )
            ),
            
            ##Client Sidebar
            tabItem('home',
                    fluidPage(
                      h1("Home")
                    )
            ),
            tabItem('aptC',
                    fluidPage(
                      h1("Appointments"),
                      DT::dataTableOutput('tableAPTC'),
                      h1("Book Appointment"),
                      div(class = NA, style="display:inline-block",
                        selectInput(inputId = 'apptPatientInput',
                                    label = 'Patient',
                                    "Patient Names",
                                    selected = 'Patient',
                                    multiple = FALSE )),
                      div(class = NA, style="display:inline-block",
                        selectInput(inputId = 'apptTypeInput',
                                    label = 'Appointment Type',
                                    choices=c("Cleaning","Whitening", "Fillings", "Extraction", "Root Canal", "Dentures"),
                                    selected = 'Procedure',
                                    multiple = FALSE )),
                      div(class = NA, style="display:inline-block",
                        selectInput(inputId = 'apptToothInput',
                                    label = 'Tooth',
                                    choices=c("All","Canine","Incisor", "Premolar", "1st Premolar", "2nd Premolar", "Molar","2nd Molar", "3rd Molar"),
                                    selected = 'Alls',
                                    multiple = TRUE )),
                      div(class = NA, style="display:inline-block",
                          selectInput(inputId = 'apptBranchInput',
                                      label = 'Location',
                                      choices=c("Ottawa", "Toronto"),
                                      selected = 'Ottawa',
                                      multiple = FALSE, width="200px" )),  
                      div(class = NA, style="display:inline-block",
                          selectInput(inputId = 'apptEmployeeInput',
                                      label = 'Dentist / Hygienist',
                                      choices= NULL,
                                      selected = "",
                                      multiple = FALSE, width="200px" )),
                      div(class = NA, style="",
                          dateInput(inputId = 'apptDateInput',
                                      label = 'Date',
                                      width = '200px',
                                      daysofweekdisabled = c(0,6) )),
                      div(class = NA, style="display:inline-block, margin-bottom:50px",
                          timeInput(inputId="apptTimeInput", 
                                    label="Time (24hr clock)", 
                                    value = strptime("09:00:00", "%T"), 
                                    seconds = FALSE,
                                    minute.steps = 60)),
                      textOutput("invalidBooking"),
                      actionButton("bookAction","Book",icon = icon("calendar-plus",lib = 'font-awesome'))
                    )
            ),
            tabItem('recC',
                    fluidPage(
                      h1("Records")
                    )
            )
            ,

            #Admin/Manager Sidebar
            tabItem('aptA',
                    fluidPage(
                      h1("Appointments"),
                      DT::dataTableOutput('tableAPTA')
                    )
            ),
            tabItem('recA',
                    fluidPage(
                      h1("Records"),
                      DT::dataTableOutput('tableRECA')
                    )
            ),
            tabItem('patA',
                    fluidPage(
                      h1("Patients"),
                      DT::dataTableOutput('tablePATA')
                    )
            ),
            tabItem('empA',
                    fluidPage(
                      h1("Records"),
                      DT::dataTableOutput('tableEMPA')
                    )
            ),
            tabItem('sqlA',
                    fluidPage(
                      h1("SQL"),
                      h4("Statements that will return something. Example: Select statements"),
                      textAreaInput(inputId = 'sql', label = 'SQL: ', value = "", width = '100%',height = '50px', placeholder = NULL),
                      actionButton("sqlGo","Go",icon = icon("sync-alt",lib = 'font-awesome')),
                      DT::dataTableOutput('SQLA'),
                      h4("Statements that will not return something. Examples: Alter, Delete, Drop, Insert statements"),
                      textAreaInput(inputId = 'sql1', label = 'SQL: ', value = "", width = '100%',height = '50px', placeholder = NULL),
                      actionButton("sqlGo1","Go",icon = icon("sync-alt",lib = 'font-awesome'))

                    )
            )
            ,

            # Dentist Hygenist sidebar items
            tabItem('aptD',
                    fluidPage(
                      h1("Appointments"),
                      DT::dataTableOutput('tableAPTD')
                    )
            ),
            tabItem('patD',
                    fluidPage(
                      h1("Patients"),
                      DT::dataTableOutput('tablePATD')
                    )
            )
            ,

            # Receptionist Sidebar items
            tabItem('aptR',
                    fluidPage(
                      h1("Appointments")
                    )
            ),
            tabItem('recR',
                    fluidPage(
                      h1("Records")
                    )
            ),
            tabItem('patR',
                    fluidPage(
                      h1("Patients")
                    )
            )
            
        )
        
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  #return query of users
  queryLogin = 'Select a.id as user_id,a.firstname,a.lastname, a.password, a.employee_id, b.role_id,c.role_name,d.patient_id
              	from users as a
              	Full join employee as b
              	on a.employee_id = b.id
              	Full join roles as c
              	on b.role_id = c.id
              	Full join patient_user as d
              	on a.id = d.user_id
              	order by a.id'
  users = dbGetQuery(con,queryLogin)
  users$user_id <- as.character(users$user_id)
  users$password <- as.character(users$password)
  
  rv <- reactiveValues()
  rv <- reactiveValues(Authenticated=FALSE)

    
  #Observing the click of the login button
  observeEvent(input$loginAction,{
    #Not null not string user name and password
    if( is.null(input$userName) |input$userName == '' | is.null(input$password) | input$password == '' ){
        output$invalidLogin <- renderText({ 'Invalid Login. Specify both a user name and password.' })
        rv$Authenticated = FALSE
    }
  
    # User name is not valid or password is incorrect
    else if( !(input$userName %in% users$user_id) | 
        input$password != unique(users[which(users$user_id == input$userName),which(colnames(users) == 'password')])[1]
        ){
        output$invalidLogin <- renderText({ 'Invalid Login' })
        rv$Authenticated = FALSE
    } 
    
    # else the user has been authenticated but we need to check if they have the ability to login as the specified type.
    else if((input$userName %in% users$user_id) & input$password == unique(users[which(users$user_id == input$userName),which(colnames(users) == 'password')]) ){
      #if there does not exist an employee_id associated with the inputed user_id
      if(input$type == 'Employee' & is.na(unique(users[which(users$user_id == input$userName),which(colnames(users) == 'employee_id')])[1]) ){
        output$invalidLogin <- renderText({ 'Invalid login type' })
        rv$Authenticated = FALSE
      }# if there does not exist a patient_id associated with the user_id
      else if(input$type == 'Client' & is.na(unique(users[which(users$user_id == input$userName),which(colnames(users) == 'patient_id')])[1]) ){
        output$invalidLogin <- renderText({ 'Invalid login type' })
        rv$Authenticated = FALSE
      }
      else{
        rv$Authenticated = TRUE
        output$invalidLogin <- renderText({ 'Successful authentification' })
      }
    }
  })

  
  #Observing the click of the login button
  observeEvent(input$loginAction,{
    #If authenticated then show the various tabs

    #If authenticated as a client then show the client tabs.
    if (rv$Authenticated == TRUE & input$type == 'Client') {

      output$home <- renderMenu({
          menuItem("Home", tabName = 'home', icon = icon("house-user", lib = 'font-awesome'))
      })

      output$aptC <- renderMenu({
          menuItem("Appointments",tabName = "aptC", icon = icon("calendar-check",lib = 'font-awesome'))
      })
      
      u_id = strtoi(input$userName, base=0L)
      queryAPTC = paste('SELECT (P.firstname, P.lastname) AS "patient_name", A."appt_type", B."city" AS "branch", T."slot_date" AS "date", T."start_time" AS "time", (E.firstname, E.lastname) AS "employee_name", A."room", A."status", A."invoice_id" FROM appointment as A, patient as P, employee as E, time_slot as T, branch as B WHERE A.patient_id = P.id AND A.patient_id IN (SELECT patient_id FROM patient_user WHERE user_id = ',u_id,') AND A.employee_id = E.id AND A.timeslot_id = T.id AND E.branch_id = B.id order by patient_id asc',collapse=NULL)
      tableAPTC = dbGetQuery(con,queryAPTC)
      output$tableAPTC <- DT::renderDataTable(tableAPTC,filter = 'top')
      
      apptFormPatientsQ = paste("SELECT (P.firstname, P.lastname) AS \"Patients\" FROM patient as P, patient_user as R WHERE (R.patient_id = P.id) AND (R.user_id = ",u_id,")")
      apptFormPatientsT = dbGetQuery(con,apptFormPatientsQ)
      observe({
        updateSelectInput(inputId = 'apptPatientInput', choices=apptFormPatientsT )
      })
      
      observeEvent(input$apptBranchInput, {
        employeeQuery = paste("SELECT (E.firstname, E.lastname) as \"employee_name\" FROM employee as E Full Join branch as B on E.branch_id = B.id WHERE ((E.role_id = 2) OR (E.role_id = 3)) AND B.city = \'", input$apptBranchInput,"\'", sep="", collapse=NULL)
        choices = dbGetQuery(con,employeeQuery)
        updateSelectInput(session, inputId = "apptEmployeeInput", choices = choices)
      })
      
      output$recC <- renderMenu({
        menuItem("Records",tabName = "recC", icon = icon("file-medical",lib = 'font-awesome'))
      })

    }
    #If authenticated as an employee then
    else if(rv$Authenticated == TRUE & input$type == 'Employee'){

      #find employee role_id
      role_id = unique(users[which(users$user_id == input$userName),which(colnames(users) == 'role_id')])[1]
      employee_id = unique(users[which(users$user_id == input$userName),which(colnames(users) == 'employee_id')])[1]

      #if role_id is 1 then the user is a branch manager so output the branch manager tabs
      if(role_id == 1){

        #output the appointment as Admin tab
        output$aptA <- renderMenu({
          menuItem("Appointments",tabName = "aptA", icon = icon("calendar-check",lib = 'font-awesome'))
        })
        
        queryAPTA = 'SELECT * FROM appointment order by id desc'
        tableAPTA = dbGetQuery(con,queryAPTA)
        output$tableAPTA <- DT::renderDataTable(tableAPTA,filter = 'top')
        

        #output the records as Admin tab
        output$recA <- renderMenu({
          menuItem("Records",tabName = "recA", icon = icon("file-medical",lib = 'font-awesome'))
        })
        
        queryRECA = 'SELECT * FROM records order by id desc'
        tableRECA = dbGetQuery(con,queryRECA)
        output$tableRECA <- DT::renderDataTable(tableRECA,filter = 'top')

        #output the patient as an admin tab
        output$patA <- renderMenu({
          menuItem("Patients",tabName = "patA", icon = icon("hospital-user",lib = 'font-awesome'))
        })
        queryPATA = 'SELECT * FROM patient order by id asc'
        tablePATA = dbGetQuery(con,queryPATA)
        output$tablePATA <- DT::renderDataTable(tablePATA,filter = 'top')

        #output the employee as Admin tab
        output$empA <- renderMenu({
          menuItem("Employee",tabName = "empA", icon = icon("user-nurse",lib = 'font-awesome'))
        })
        queryEMPA = 'SELECT * FROM employee order by id asc'
        tableEMPA = dbGetQuery(con,queryEMPA)
        output$tableEMPA <- DT::renderDataTable(tableEMPA,filter = 'top')

        #output the sql
        output$sqlA <- renderMenu({
          menuItem("SQL",tabName = "sqlA", icon = icon("code",lib = 'font-awesome'))
        })
        
      }

      #if role_id is 2 or 3 then  then the user is a dentist or hygenist so output the hygienist/dentist tabs
      if(role_id == 2 | role_id == 3){

        #output appointment as a dentist/hygienist tab
        output$aptD <- renderMenu({
          menuItem("Appointments",tabName = "aptD", icon = icon("calendar-check",lib = 'font-awesome'))
        })
        
        queryAPTD = paste('SELECT a.id as Appointment_ID, a.status,c.slot_date as Date, c.start_time, c.end_time, a.appt_type, a.room, a.patient_id, b.firstname,b.lastname, a.employee_id,a.invoice_id
                            FROM appointment as a, patient as b, time_slot as c
                            where employee_id =', employee_id, 
                            'And a.patient_id = b.id
                            And a.timeslot_id = c.id')
        
        tableAPTD = dbGetQuery(con,queryAPTD)
        output$tableAPTD <- DT::renderDataTable(tableAPTD,filter = 'top')

        #output patient as dentist/hygienist tab
        output$patD <- renderMenu({
          menuItem("Patients",tabName = "patD", icon = icon("hospital-user",lib = 'font-awesome'))
        })
        
        queryPATD = paste('Select * from patient Where id in (Select distinct patient_id from appointment Where employee_id =',employee_id,')')
        tablePATD = dbGetQuery(con,queryPATD)
        output$tablePATD = DT::renderDataTable(tablePATD, filter = 'top')

      }

      #if role_id is 4 then the user is a receptionist so output the receptionist tabs
      if(role_id == 4){

        #output appointment as a receptionist
        output$aptR <- renderMenu({
          menuItem("Appointments",tabName = "aptR", icon = icon("calendar-check",lib = 'font-awesome'))
        })

        #output the records as a receptionist tab
        output$recR <- renderMenu({
          menuItem("Records",tabName = "recR", icon = icon("file-medical",lib = 'font-awesome'))
        })

        #output patient as receptionist tab
        output$patR <- renderMenu({
          menuItem("Patients",tabName = "patR", icon = icon("hospital-user",lib = 'font-awesome'))
        })

      }


    }

  })
  
  #Admind SQL Statements
  observeEvent(input$sqlGo,{
    tableSQLA = dbGetQuery(con,input$sql)
    output$SQLA <- DT::renderDataTable(tableSQLA,filter = 'top')
  })
  observeEvent(input$sqlGo1,{
    #send the statement
    dbSendStatement(con,input$sql1)
    
    #Rerendering all tables so that the changes can be shown in the app
    ##Appointments
    queryAPTA = 'SELECT * FROM appointment order by id desc'
    tableAPTA = dbGetQuery(con,queryAPTA)
    output$tableAPTA <- DT::renderDataTable(tableAPTA,filter = 'top')
    ##Records
    queryRECA = 'SELECT * FROM records order by id desc'
    tableRECA = dbGetQuery(con,queryRECA)
    output$tableRECA <- DT::renderDataTable(tableRECA,filter = 'top')
    ##Patient
    queryPATA = 'SELECT * FROM patient order by id asc'
    tablePATA = dbGetQuery(con,queryPATA)
    output$tablePATA <- DT::renderDataTable(tablePATA,filter = 'top')
    ##Employee
    queryEMPA = 'SELECT * FROM employee order by id asc'
    tableEMPA = dbGetQuery(con,queryEMPA)
    output$tableEMPA <- DT::renderDataTable(tableEMPA,filter = 'top')
  })
  
  vb <- reactiveValues()
  vb <- reactiveValues(Valid=FALSE)
  
  observeEvent(input$bookAction, {
    
    employeeFirstName = strsplit(input$apptEmployeeInput, "[,()]+")[[1]][2]
    employeeLastName = strsplit(input$apptEmployeeInput, "[,()]+")[[1]][3]
    apptTime = strtoi(strftime(input$apptTimeInput, "%T"))
    
    employeeApptTimesQuery = paste("SELECT T.start_time, T.slot_date FROM time_slot as T Right Join appointment as A on T.id = A.timeslot_id Left Join employee as E on E.id = A.employee_id WHERE E.firstname = \'", employeeFirstName, "\' and E.lastname = \'",employeeLastName, "\'", sep="",collapse=NULL)
    employeeApptTimesTable = dbGetQuery(con, employeeApptTimesQuery)
    print(employeeApptTimesTable)
    
    print(apptTime %in% employeeApptTimesTable & input$apptDateInput == unique(employeeApptTimesTable[which(employeeApptTimesTable$start_time == apptTime),which(colnames(employeeApptTimesTable) == 'slot_date')]))
        
    if( is.null(input$apptToothInput)){
      output$invalidBooking <- renderText({ 'Booking cannot be completed without tooth information.' })
      vb$Valid = FALSE
    }
    else if ( 9 > strtoi(strftime(input$apptTimeInput, "%H"), base=0L) | strtoi(strftime(input$apptTimeInput, "%H"), base=0L) > 16){
      output$invalidBooking <- renderText({ 'Booking time must be between 09h and 16h' })
      vb$Valid = FALSE
    } #else if (apptTime %in% employeeApptTimesTable & input$apptDateInput == unique(employeeApptTimesTable[which(employeeApptTimesTable$start_time == apptTime),which(colnames(employeeApptTimesTable) == 'slot_date')]  )){
      #print("hello")
    #}
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
