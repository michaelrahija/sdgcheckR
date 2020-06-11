#https://shiny.rstudio.com/tutorial/written-tutorial/lesson2/

library(shiny)

ui <- fluidPage(

  sidebarLayout(
    
    sidebarPanel(width = 5,
             
      img(src='logo2.png', height = 200, width = 300),
      fileInput('file1', 'Choose xlsx file containing SDG data',
                accept = c(".xlsx")),
      h3(em("Results displayed to the right.")),
      h5(em("To see source code for sdgchecker click link below.")),
      h5(a(href = 'https://github.com/michaelrahija/sdgcheckr',"https://github.com/michaelrahija/sdgcheckr"))
    ),
    
    
    mainPanel(width = 7,
      h3(strong("1. Variable Summary")),
      p("Each row is a variable, and the table contains frequencies of valid observations, NAs, and Ns. The total is included as a check."),
      tableOutput('blankcolumns'),
      
      h3(strong("2. Column Names Check")),
      p("The table below lists the columns which do not match names in the template. Please check."),
      tableOutput('columncheck'),
      
      h3(strong("3. Required area (i.e. country, region, etc.) Check")),
      p("The table lists required areas which are not in the your file."),
      tableOutput('reqareas'),
      
      h3(strong("4. Correct area code check")),
      p("The table below shows geographic areas for which the code in the input file does not match the template."),
      tableOutput('geocodes'),
    
      h3(strong("5. Correct unit check")),
      p("The table below shows the units of measure which do not match the template."),
      tableOutput('units'),
    
      h3(strong("6. Correct nature check")),
      p("The table below shows the nature values which do not match the template."),
      tableOutput('natureT'),
      
      h3(strong("7. Check nature codes applied to Ns and NAs")),
      #p("The table below shows the nature values which do not match the template."),
      textOutput('natureNsNAs'),
      
      h3(strong("8. Duplicate record check")),
      p("The table below shows a list of duplicated records"),
      tableOutput('duplicatesT'))
  )
)