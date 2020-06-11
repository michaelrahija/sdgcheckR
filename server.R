 # server application to run checks on SDG files


function(input, output){
  
  
  #Variable Summary
  output$blankcolumns <- renderTable({
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    
    result.cols <- data.frame(ColumnName = NA,
                              NAs = NA,
                              Ns = NA,
                              Obs = NA,
                              Total= NA)
    
    #for each column, count frequency type
    for(i in 1:ncol(x)){
      
      ColumnName <- colnames(x[i])
      NAs <- sum(is.na(x[i]))
      Ns <- sum(x[i] == "N", na.rm = T)
      Obs <- sum((!is.na(x[i]) & x[i] != "N"))
      Total = NAs + Ns + Obs
      
      temp <- data.frame(ColumnName,
                         NAs,
                         Ns,
                         Obs,
                         Total)
      
      result.cols <- rbind(result.cols,
                           temp)
    }
    
    result.cols[-1,]
    
  })
  
  #Correct column name check
  output$columncheck <- renderTable({

    inFile <- input$file1
    
    if (is.null(inFile)) return(NULL)
  
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    #First test column names
    col.test <- sum(colnames(x) %in% colnames(template)) == length(template)
    
    if(col.test){
  
        return("All columns are correct.")
      
    } else {
        incorrect.columns <- x[,!(colnames(x) %in% colnames(template))]
        data.frame(ColumnNameswithErrors = colnames(incorrect.columns))
    }
  })
  
  #Required area (i.e. country, region, etc.) check
  output$reqareas <- renderTable({
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)

    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)

    #check if input file has correct area name
    if("Reference_Area_Code_M49" %in% colnames(x)){
      colnames(x)[colnames(x) == "Reference_Area_Code_M49"] <- "GeoAreaCode"
      
    } else if (!("GeoAreaCode") %in% colnames(x)) {
      
      stop("Cannot find column with geographic code. You must name the column correctly.")
    }
    
    #check if input file has correct area name
    if("Reference_Area_Name" %in% colnames(x)){
      colnames(x)[colnames(x) == "Reference_Area_Name"] <- "GeoAreaName"
      
    } else if (!("GeoAreaName") %in% colnames(x)) {
      stop("Cannot find column with geographic name. You must name the column correctly.")
    }
    
    
    #Identify required areas which are not in file
    req.codes <- geo[geo$required == "R",]
    codes.in.x <- unique(x$GeoAreaCode)
    
    RequiredButMissing<- req.codes[!(req.codes$code %in% codes.in.x), "Name"]
    
    result <- data.frame(`Missing Areas` = RequiredButMissing)
    
    if(nrow(result) == 0){
      
      data.frame(`Missing Areas` = "All required areas are contained in file.")
      
    } else {
      result
    }
    
  })
  
  

  #Check that geo codes are correct
  output$geocodes <- renderTable({

    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    #check if input file has correct area name
    if("Reference_Area_Code_M49" %in% colnames(x)){
      colnames(x)[colnames(x) == "Reference_Area_Code_M49"] <- "GeoAreaCode"
      
    } else if (!("GeoAreaCode") %in% colnames(x)) {
      
      stop("Cannot find column with geographic code. You must name the column correctly.")
    }
    
    #check if input file has correct area name
    if("Reference_Area_Name" %in% colnames(x)){
      colnames(x)[colnames(x) == "Reference_Area_Name"] <- "GeoAreaName"
      
    } else if (!("GeoAreaName") %in% colnames(x)) {
      stop("Cannot find column with geographic name. You must name the column correctly.")
    }
    
    
    #create unique lists
    x.codes <- x[, c('GeoAreaName', "GeoAreaCode")]
    
    x.codes <- unique(x.codes)
    
    notFound <- x.codes[!(x.codes$GeoAreaCode %in% unique(geo$code)),]
    notFound$GeoAreaCode <- as.character(notFound$GeoAreaCode)
    
    if(nrow(notFound) == 0){
      
      data.frame(`Codes` = "All required areas are contained in file.")
      
    } else {
      notFound
    }
    
    
  })
  
  #Check that units of measure are correct
  output$units <- renderTable({
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    x.units <- unique(x$Units)
    
    notFound <- x.units[!(x.units %in% unique(units$Code))]
    
    if(length((notFound)) == 0){
      
      data.frame(`Codes` = "All units are correct.")
      
    } else {
      data.frame(codes = notFound)
    }
    
  })
  
  #Check nature
  output$natureT <- renderTable({
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    x.nature <- unique(x$Nature)
    
    notFound <- x.nature[!(x.nature %in% unique(nature$Code))]
    
    if(length((notFound)) == 0){
      
      data.frame(`Codes` = "All nature are correct.")
      
    } else {
      data.frame(codes = notFound)
    }
    
    
  })
  
  #Check nature codes applied correctly to Ns, and NAs
  output$natureNsNAs <- renderText({
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    if(!("Value" %in% colnames(x))) {
      "Cannot find Value column. Check column names!"
    } else {
    
        #First test to see if Values = N, have N in the nature column
        x.N <- x[x$Value %in% c("N"),]
        x.N.test <- x.N$Value == x.N$Nature
        
        if(length(x.N.test) == 0){
            x.N.test <- 0
        }
        
        #Test to see if NAs in value columns have NAs or blanks in the nature column
        x.NA <- x[x$Value %in% c("NA"),]
        
        if(nrow(x.NA) == 0){
          x.NA.test <- 0
        } else {
        
          x.NA$Value <- NA
          x.NA$ValueTest <- is.na(x.NA$Value)
          
          x.NA$NatureTest <- is.na(x.NA$Nature)
          
          #Negate, so we can use a sum of greater than 1 to indicate an error
          x.NA.test <- !(x.NA$ValueTest == x.NA$NatureTest) 
        }
        
        result <- sum(x.NA.test,x.N.test)
        
        if(result >= 1){
          
          "ERROR: If there is a N, NA, or blank in the value column, there must be N, or NA in the Nature column. Please correct before resubmitting!"
        } else {
          
          "The correct nature codes were applied to N and NAs."
        }
    }
    
  })
  
  #Check duplicates
  output$duplicatesT <- renderTable({
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    
    x <- readxl::read_xlsx(inFile$datapath)
    x <- cleanInputFileCols(x)
    
    colsToCheck <- c("SeriesCode","GeoAreaCode","TimePeriod","CL_SEX","Age","Disaggregation")
    
    filtercols <- colnames(x) %in% colsToCheck
    
    y <- x[,filtercols]
    
    result <- y[duplicated(y),]
    
    if(nrow(result) == 0){
     result <- "No duplicates"
    } else {
    
      result[, ] <- lapply(result[, ], as.character)
    }
  
  result
    
  })
  
  
  
}


  
