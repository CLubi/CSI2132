#con <- dbConnect(RPostgres::Postgres(), host='web0.eecs.uottawa.ca', port='15432', dbname='clubi035', user='clubi035',password=pas)

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DBI)
library(odbc)
library(shiny)
library(shinyjs)

ui <- dashboardPage(
    dashboardHeader(title = "Dental clinic"),
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
                        actionButton("loginAction","Login",icon = icon("sync-alt",lib = 'font-awesome'))
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
                      h1("Appointments")
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
                      dataTableOutput('temp')
                    )
            ),
            tabItem('recA',
                    fluidPage(
                      h1("Records")
                    )
            ),
            tabItem('patA',
                    fluidPage(
                      h1("Patients")
                    )
            ),
            tabItem('empA',
                    fluidPage(
                      h1("Records")
                    )
            ),
            tabItem('sqlA',
                    fluidPage(
                      h1("SQL"),
                      textInput(inputId = 'sql', label = 'SQL: ', value = "", width = NULL, placeholder = NULL),
                      actionButton("sqlGo","Go",icon = icon("sync-alt",lib = 'font-awesome')),
                      dataTableOutput('sqlResults')

                    )
            )
            ,

            # Dentist Hygenist sidebar items
            tabItem('aptD',
                    fluidPage(
                      h1("Appointments")
                    )
            ),
            tabItem('patD',
                    fluidPage(
                      h1("Patients")
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
server <- function(input, output) {

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
      
      output$recC <- renderMenu({
        menuItem("Records",tabName = "recC", icon = icon("file-medical",lib = 'font-awesome'))
      })

    }
    #If authenticated as an employee then
    else if(rv$Authenticated == TRUE & input$type == 'Employee'){

      #find employee role_id
      role_id = unique(users[which(users$user_id == input$userName),which(colnames(users) == 'role_id')])

      #if role_id is 1 then the user is a branch manager so output the branch manager tabs
      if(role_id == 1){

        #output the appointment as Admin tab
        output$aptA <- renderMenu({
          menuItem("Appointments",tabName = "aptA", icon = icon("calendar-check",lib = 'font-awesome'))
        })

        #output the records as Admin tab
        output$recA <- renderMenu({
          menuItem("Records",tabName = "recA", icon = icon("file-medical",lib = 'font-awesome'))
        })

        #output the patient as an admin tab
        output$patA <- renderMenu({
          menuItem("Patients",tabName = "patA", icon = icon("hospital-user",lib = 'font-awesome'))
        })

        #output the employee as Admin tab
        output$empA <- renderMenu({
          menuItem("Employee",tabName = "empA", icon = icon("user-nurse",lib = 'font-awesome'))
        })

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

        #output patient as dentist/hygienist tab
        output$patD <- renderMenu({
          menuItem("Patients",tabName = "patD", icon = icon("hospital-user",lib = 'font-awesome'))
        })

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
  
}

# Run the application 
shinyApp(ui = ui, server = server)
