library(shiny)
library(DBI)
library(shinyjs)
library(RPostgres)
library(DT)
library(data.table)
library(lubridate)
library(shinyalert)

#con <- dbConnect(RPostgres::Postgres(), host='web0.eecs.uottawa.ca', port='15432', dbname='clubi035', user='clubi035',password=pas)


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
                      DTOutput('tableAPTA')
                    )
            ),
            tabItem('recA',
                    fluidPage(
                      hr(),
                      h1("Records"),
                      column(6,offset = 6,
                             HTML('<div class="btn-group" role="group" aria-label="Basic example" style = "padding:10px">'),
                             ### tags$head() This is to change the color of "Add a new row" button
                             tags$head(tags$style(".butt2{background-color:#231651;} .butt2{color: #e6ebef;}")),
                             div(style="display:inline-block;width:30%;text-align: center;",actionButton(inputId = "RECA_Add_row",label = "Add", class="butt2") ),
                             #tags$head(tags$style(".butt4{background-color:#4d1566;} .butt4{color: #e6ebef;}")),
                             #div(style="display:inline-block;width:30%;text-align: center;",actionButton(inputId = "RECA_Mod_row",label = "Edit", class="butt4") ),
                             tags$head(tags$style(".butt3{background-color:#590b25;} .butt3{color: #e6ebef;}")),
                             div(style="display:inline-block;width:30%;text-align: center;",actionButton(inputId = "RECA_Del_row",label = "Delete", class="butt3") ),
                             HTML('</div>') ),
                      DT::dataTableOutput('tableRECA'),
                      tags$script("$(document).on('click', '#tableRECA button', function () {
                   Shiny.onInputChange('lastClickId',this.id);
                   Shiny.onInputChange('lastClick', Math.random()) });"),
                      actionButton(inputId = "Updated_RECA",label = "Save")
                    )
            ),
            tabItem('patA',
                    fluidPage(
                      h1("Patients"),
                      DT::dataTableOutput('tablePATA'),
                      
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
                      h4("Statements that will return something. Example: Select * from reviews "),
                      textAreaInput(inputId = 'sql', label = 'SQL: ', value = "", width = '100%',height = '50px', placeholder = NULL),
                      actionButton("sqlGo","Go",icon = icon("sync-alt",lib = 'font-awesome')),
                      DT::dataTableOutput('SQLA'),
                      h4("Statements that will not return something. Example: update patient set dob = '2000-01-01' where id = 5"),
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
  
  rv <- reactiveValues(tableRECA = NULL)
  rv <- reactiveValues(qr_RECA = c())

    
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
        output$tableAPTA <- renderDT(tableAPTA,editable = 'all')
        

        #output the records as Admin tab
        output$recA <- renderMenu({
          menuItem("Records",tabName = "recA", icon = icon("file-medical",lib = 'font-awesome'))
        })
        
        queryRECA = 'SELECT * FROM records order by id desc'
        rv$tableRECA = dbGetQuery(con,queryRECA)
        output$tableRECA <- DT::renderDataTable(rv$tableRECA,filter = 'top')

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
  
# Admind table edit priviledges
## Records tab
  observeEvent(input$RECA_Add_row, {
    ### This is the pop up board for input a new row in RECA table
    showModal(modalDialog(title = "Add a new row",
                          numericInput(paste0("RECA_id", input$RECA_Add_row), "ID:",0),  
                          numericInput(paste0("RECA_employee_id", input$RECA_Add_row), "Employee ID:",0),
                          actionButton("RECA_go", "Add item"),
                          easyClose = TRUE, footer = NULL ))
    
  })
  ### Add a new row to RECA table  
  observeEvent(input$RECA_go, {
    new_row=data.frame(
      id=input[[paste0("RECA_id", input$RECA_Add_row)]],
      employee_id=input[[paste0("RECA_employee_id", input$RECA_Add_row)]]
      
    )
    rv$qr_RECA = c(rv$qr_RECA,
      paste('insert into records (id, employee_id) values (',input[[paste0("RECA_id", input$RECA_Add_row)]],',',input[[paste0("RECA_employee_id", input$RECA_Add_row)]],')'
            )
    )
    
    removeModal()
  })
  
  ### delete selected rows part
  ### this is warning messge for deleting
  observeEvent(input$RECA_Del_row,{
    showModal(
      if(length(input$tableRECA_rows_selected)>=1 ){
        modalDialog(
          title = "Warning",
          paste("Are you sure delete",length(input$tableRECA_rows_selected),"rows?" ),
          footer = tagList(
            modalButton("Cancel"),
            actionButton("RECA_ok", "Yes")
          ), easyClose = TRUE)
      }else{
        modalDialog(
          title = "Warning",
          paste("Please select the row(s) that you want to delete!" ),easyClose = TRUE
        )
      }
      
    )
  })
  
  ### If user say OK, then delete the selected rows
  observeEvent(input$RECA_ok, {
    
    for (i in 1:length(input$tableRECA_rows_selected)) {
      dbSendStatement(con,paste('Delete from records where id = ',rv$tableRECA$id[input$tableRECA_rows_selected[i]]))
    }
    
    queryRECA = 'SELECT * FROM records order by id desc'
    rv$tableRECA = dbGetQuery(con,queryRECA)
    output$tableRECA <- DT::renderDataTable(rv$tableRECA,filter = 'top')
    removeModal()
    shinyalert(title = "Deleted!", type = "success")
  })
  
  observeEvent(input$Updated_RECA,{
    for (i in 1:length(rv$qr_RECA)) {
      dbSendStatement(con,rv$qr_RECA[i])
    }
    queryRECA = 'SELECT * FROM records order by id desc'
    rv$tableRECA = dbGetQuery(con,queryRECA)
    output$tableRECA <- DT::renderDataTable(rv$tableRECA,filter = 'top')
    
    rv$qr_RECA = c()
    shinyalert(title = "Saved!", type = "success")
    
  })
  
  
  
  
## Admin SQL tab
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
    rv$tableRECA = dbGetQuery(con,queryRECA)
    output$tableRECA <- DT::renderDataTable(rv$tableRECA,filter = 'top')
    ##Patient
    queryPATA = 'SELECT * FROM patient order by id asc'
    tablePATA = dbGetQuery(con,queryPATA)
    output$tablePATA <- DT::renderDataTable(tablePATA,filter = 'top')
    ##Employee
    queryEMPA = 'SELECT * FROM employee order by id asc'
    tableEMPA = dbGetQuery(con,queryEMPA)
    output$tableEMPA <- DT::renderDataTable(tableEMPA,filter = 'top')
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
