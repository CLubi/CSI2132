library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DBI)
library(odbc)
library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
ui <- dashboardPage(
    dashboardHeader(title = "Candev"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Authentification",tabName = "aut", icon = icon("trophy",lib = 'font-awesome')),
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
                        h1("Appointments")
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
    
    #here write query to get a data frame of named 'users' of users
    user_id = c('user','employee')
    password = c('userPass','employeePass')
    users = cbind(user_id,password)
    users = as.data.frame(users)
    
    
    rv <- reactiveValues()
    rv <- reactiveValues(Authenticated=FALSE)
    
    #Observing the click of the login button
    observeEvent(input$loginAction,{
        #Not null user name and password
        if( is.null(input$userName) | is.null(input$password) ){
            output$invalidLogin <- renderText({ 'Invalid Login' })
        }
        # User name is not valid of password is incorrect
        else if( !(input$userName %in% users$user_id) | 
            input$password != toString(users[which(users$user_id == input$userName),which(colnames(users) == 'password')])
            ){
            output$invalidLogin <- renderText({ 'Invalid Login' })
        } # else the user has been authenticated
        else{
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
    
}

# Run the application 
shinyApp(ui = ui, server = server)
