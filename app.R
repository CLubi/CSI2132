#con <- dbConnect(RPostgres::Postgres(), host='web0.eecs.uottawa.ca', port='15432', dbname='clubi035', user='clubi035',password=pas)

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DBI)
library(odbc)
library(shiny)
library(shinyjs)

ui <- dashboardPage(
    dashboardHeader(title = "Candev"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Authentification",tabName = "aut", icon = icon("trophy",lib = 'font-awesome')),
            
            #Receptionist Sidebar
            menuItemOutput("aptR"), #to schedule and view,search appoints. So they need the option to edit that table in DB
            menuItemOutput("recR"), #To view,search and edit past appoints/invoices/insurance claims
            menuItemOutput("patR"), # to view,search and edit patient table
            
            #Dentist/hygenist Sidebar
            menuItemOutput("aptD"), #to view ,search(not edit) appoints. So they need the option to edit that table in DB
            menuItemOutput("patD"), # to view, search (not edit) patient table and patient records
            
            
            # Client Sidebar - make sure accomodate for all "responsibilities"
            menuItemOutput("home"), # upcoming appointments
            menuItemOutput("aptC"), # all their past appointments, book new appointments
            menuItemOutput("recC"), # View all record: incoices, insurance claims
            
            #Admin/Manager Sidebar
            menuItemOutput("aptA"), #to schedule and view,search appoints. So they need the option to edit that table in DB
            menuItemOutput("recA"), #To view,search and edit past appoints/invoices/insurance claims
            menuItemOutput("patA"), # to look up a patient and return everything on that patient
            menuItemOutput("empA"), # to look up a employee and return everything on that employee
            menuItemOutput("sqlA") # Admin has the option to write their own sql queries.
            
            
            
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
                                    choices = c('Client','Employee')
                                    ),
                        textOutput("invalidLogin"),
                        actionButton("loginAction","Login",icon = icon("sync-alt",lib = 'font-awesome'))
                    )
            ),
            # Receptionist Sidebar items
            tabItem('aptR',
                    fluidPage(
                        h1("Appointments"),
                        dataTableOutput('temp')
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
            ),
            # Dentist Hygenist sidebar items
            tabItem('aptD',
                    fluidPage(
                      h1("Appointments"),
                      dataTableOutput('temp')
                    )
            ),
            tabItem('patD',
                    fluidPage(
                      h1("Patients")
                    )
            ),
            #Client Sidebar
            tabItem('home',
                    fluidPage(
                      h1("Home")
                    )
            ),
            tabItem('aptC',
                    fluidPage(
                      h1("Appointments"),
                      dataTableOutput('temp')
                    )
            ),
            tabItem('recC',
                    fluidPage(
                      h1("Records")
                    )
            ),
            # Admin/Manager Sidebar
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
        )
        
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
  #return query of users
  queryLogin = 'Select id as user_id ,password from users'
  users = dbGetQuery(con,queryLogin)
    
    
    rv <- reactiveValues()
    rv <- reactiveValues(Authenticated=FALSE)

    
    #Observing the click of the login button
    observeEvent(input$loginAction,{
        #Not null not string user name and password
        if( is.null(input$userName) | is.null(input$password) ){
            output$invalidLogin <- renderText({ 'Invalid Login' })
            rv$Authenticated = FALSE
        }
        # User name is not valid of password is incorrect
        else if( !(input$userName %in% users$user_id) | 
            input$password != toString(users[which(users$user_id == input$userName),which(colnames(users) == 'password')])
            ){
            output$invalidLogin <- renderText({ 'Invalid Login' })
            rv$Authenticated = FALSE
        } # else the user has been authenticated
        else if((input$userName %in% users$user_id) & input$password == toString(users[which(users$user_id == input$userName),which(colnames(users) == 'password')]) ){
            rv$Authenticated = TRUE
            output$invalidLogin <- renderText({ 'Successful authentification' })
        }
    })
    
    #Observing the click of the login button
    observeEvent(input$loginAction,{
        
        #If authenticated then show the various tabs
        if (rv$Authenticated == TRUE) {
            
            output$apt <- renderMenu({
                menuItem("Appointments", tabName = 'apt', icon = icon("money-bill-alt", lib = 'font-awesome'))
            })
            
            output$inv <- renderMenu({
                menuItem("Invoices",tabName = "inv", icon = icon("lightbulb",lib = 'font-awesome'))
            })
            
            output$ins <- renderMenu({
                menuItem("Insurance Claims",tabName = "ins", icon = icon("lightbulb",lib = 'font-awesome'))
            })
            
            output$pat <- renderMenu({
                menuItem("Patients",tabName = "pat", icon = icon("lightbulb",lib = 'font-awesome'))
            })
            
        }
        
    })
    
    x = dbGetQuery(con,'Select * from artwork')
    output$temp <- renderDataTable(x)
    
}

# Run the application 
shinyApp(ui = ui, server = server)
