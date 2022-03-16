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
            #Employee Sidebar
            menuItemOutput("apt"),
            menuItemOutput("inv"),
            menuItemOutput("ins"),
            menuItemOutput("pat")
        )
    ),
    dashboardBody(
        tabItems(
            tabItem("aut",
                    fluidPage(
                        h1("Authentification"),
                        textInput(inputId = 'userName', label = 'User Name: ', value = "", width = NULL, placeholder = NULL),
                        passwordInput(inputId = 'password', label = 'Password: ', value = "", width = NULL, placeholder = NULL),
                        textOutput("invalidLogin"),
                        actionButton("loginAction","Login",icon = icon("sync-alt",lib = 'font-awesome'))
                    )
            ),
            tabItem('apt',
                    fluidPage(
                        h1("Appointments"),
                        dataTableOutput('temp')
                        )
                    ),
            tabItem('inv',
                    fluidPage(
                        h1("Invoices")
                    )
            ),
            tabItem('ins',
                    fluidPage(
                        h1("Insurance Claims")
                    )
            ),
            tabItem('pat',
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


