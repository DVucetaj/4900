#Donat VUcetaj CISC4900 SPRING2017
#---------------------------------------------------------------------
#Library imports
library(xlsx)
library(rJava)
library(xlsxjars)
library(readxl)

#---------------------------------------------------------------------
#This script contains a series of methods that work with the formatted
#excel sheet containing the paired values of the survey responses
#(The difference of post survey response to pre survey response)
#The questions labeled A# or B# relate to the common surveys in
#both the pre and post surveys. A is the first set of questions
#(Expected to do course elements), and B is the second set of
#questions(Opinions on self and science).

#----------------------------------------------------------------------
#This section create data frame for all of the aggregated data sheets.
#It requires user input for the location of the workbook and the
#name of the spreadsheet along with the name of the data frame to be
#used. Some sheets skip different amounts of lines before the header
#row and therefore need to be formatted to fit a standard template
#to allow for simpler integration of the script.
#Create the data frame from the read in file and remove empty rows.

CUNYCampusNames <- list(c("Brooklyn COllege","Baruch College","College of Staten Island",
                          "The City College of New York","Guttman Community College",
                          "LaGuardia Community College","Queensborough Community College"))

BlankColumnNames <- c("ProjectSemester","Campus","StudentName","Major","A1","A2","A3","A4","A5","A6",
                      "A7","A8","A9","A10","A11","A12","A13","A14","A15","A16","A17","A18",
                      "A19","A20","A21","A22","A23","A24","A25","B1","B2","B3","B4","B5","B6",
                      "B7","B8","B9","B10","B11","B12","B13","B14","B15","B16","B17","B18",
                      "B19","B20","B21","B22")
QuestionNames <- c("A1","A2","A3","A4","A5","A6",
                   "A7","A8","A9","A10","A11","A12","A13","A14","A15","A16","A17","A18",
                   "A19","A20","A21","A22","A23","A24","A25","B1","B2","B3","B4","B5","B6",
                   "B7","B8","B9","B10","B11","B12","B13","B14","B15","B16","B17","B18",
                   "B19","B20","B21","B22")
#--------------------------------------------------------------------------------------------------
CreatePairedSheet <- function(PostDF, PreDF){
  NewDf <- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  for(i in 1:nrow(PostDF)){
    for(j in 1:nrow(PreDF)){
      if(PostDF[i,]$StudentName == PreDF[j,]$StudentName){
        for(n in 1:4){
          NewDf[i,n] <- PostDF[i,n]
        }
        for(k in 5:ncol(PostDF)){
          if(!is.na(PostDF[i,k]) && !is.na(PreDF[j,k]) && PostDF[[i,k]] < 6 && PreDF[[j,k]] < 6){
            NewDf[i,k] <- PostDF[i,k] - PreDF[j,k]
          }else{
            NewDf[i,k] = NA
          }
        }
        return#END Qestion Parse
      }#END String Match
    }#END Pre Parse
  }#END Post Parse
  NewDf <- NewDf[rowSums(is.na(NewDf)) != ncol(NewDf),]
  return(NewDf)
}

#TESTING other methods to parse and create paired.
CreatePairedSheet <- function(PostDF, PreDF){
  i = 1
  while(i != nrow(PostDF) + 1){
    j = 1
    while(PostDF[i,]$StudentName != PreDF[j,]$StudentName && j <nrow(PreDF) + 1){
      j = j +1
    }
    for(k in 5:ncol(PostDF)){
      if(!is.na(PostDF[i,k]) && !is.na(PreDF[j,k]) && PostDF[[i,k]] < 6 && PreDF[[j,k]] < 6){
        PostDF[i,k] <- PostDF[i,k] - PreDF[j,k]
      }else{
        PostDF[i,k] = NA
      }
    }
    i = i + 1
  }
  return(PostDF)
}

#----------------------------------------------------------------------
#These are functions that take in data frames and clean up the data set
#to include only the necessary information since not all data sheets
#are formatted the same way and will have errors merging.
#addPre("Fall2015Pre","Brooklyn College","BrooklynCollegePre")
#The first parameter is the data frame that you wish to parse, the frame
#that you want to get the data from. The second is the specific campus
#you are searching for as a String. The last is the data frame that you
#want to add the rows to, ie: BrooklynCollegePre, GuttmanCollegePost, etc


addSurveys <- function(ReadFromDF, CampusName, AddToDF){
  for(i in 1:nrow(ReadFromDF)){
    if(is.na(ReadFromDF[i,]$Consent)){
      print(ReadFromDF[i,]$StudentName)
    }
    if(ReadFromDF[i,]$Campus == CampusName && ReadFromDF[i,]$Consent == 'Y'){
      ToAdd<- subset(ReadFromDF[i,], select = BlankColumnNames)
      ToAdd[ToAdd == "NA"] <- NA
      AddToDF <- rbind(AddToDF, ToAdd)
    }
    else{}
  }
  return(AddToDF)
}
#------------------------------------------------------------------------
#CleanDF takes in a data frame, in this case it is used to 'clean' the data set, and sets the column type
#for the questions as numeric values. This is done to ensure that when the data is being processed, then
#this is no conflict if a values being compared are not both numeric. This does end up getting rid of
#some data due to either human error on input or because of student error on input, but it ensures that
#the values can be processed.
CleanDF <- function(DFToClean){
  for(i in 1:length(QuestionNames)){
    DFToClean[[QuestionNames[i]]] <- as.numeric(DFToClean[[QuestionNames[i]]])
  }
  for(i in 1:nrow(DFToClean)){
    if(DFToClean[i,]$Consent != "Y" || is.na(DFToClean[i,]$Consent)){
      DFToClean[i,]$Consent = "N"
    }else{
      DFToClean[i,]$Consent = toupper(DFToClean[i,]$Consent)
    }
  }
  return(DFToClean)
}

#---------------------------------------------------------------------------
CampusNames <- data.frame(c("Brooklyn College","College of Staten Island","The City College of New York",
                             "Guttman Community College","LaGuardia Community College","Queensborough Community College"))
  options(warn=-1)
  Fall2015Pre <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx",sheet="Fall2015-PreSurveyData", skip = 2, na = "0")
  Fall2015Pre <- Fall2015Pre[rowSums(is.na(Fall2015Pre)) != ncol(Fall2015Pre),]
  Fall2015Pre <- CleanDF(Fall2015Pre)
  
  Fall2015Post <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Fall2015-PostSurveyData", skip = 2, na = "0")
  Fall2015Post <- Fall2015Post[rowSums(is.na(Fall2015Post)) != ncol(Fall2015Post),]
  Fall2015Post <- CleanDF(Fall2015Post)
  
  Spring2016Pre <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Spring2016-PreSurveyData", skip = 2, na = "0")
  Spring2016Pre <- Spring2016Pre[rowSums(is.na(Spring2016Pre)) != ncol(Spring2016Pre),]
  Spring2016Pre <- CleanDF(Spring2016Pre)
  
  Spring2016Post <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Spring2016-PostSurveyData", skip = 2, na = "0")
  Spring2016Post <- Spring2016Post[rowSums(is.na(Spring2016Post)) != ncol(Spring2016Post),]
  Spring2016Post <- CleanDF(Spring2016Post)
  
  Fall2016Pre <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Fall2016-PreSurveyData", skip = 2, na = "0")
  Fall2016Pre <- Fall2016Pre[rowSums(is.na(Fall2016Pre)) != ncol(Fall2016Pre),]
  Fall2016Pre <- CleanDF(Fall2016Pre)
  
  Fall2016Post <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Fall2016-PostSurveyData", skip = 2, na = "0")
  Fall2016Post <- Fall2016Post[rowSums(is.na(Fall2016Post)) != ncol(Fall2016Post),]
  Fall2016Post <- CleanDF(Fall2016Post)
  
  options(warn=-0)


#Spring2017Pre <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Spring2017-PreSurveyData", skip = 2)
#Spring2017Post <- read_excel("A:/DropBox/Dropbox/4900/AllSemesters.xlsx", sheet="Spring2017-PostSurveyData", skip = 2)
  


CreateCUNYCampusDataFrames <- function(){
  BrooklynCollegePre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  BrooklynCollegePost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  BrooklynCollegePaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  
  BaruchCollegePre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  BaruchCollegePost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  BaruchCollegePaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  
  CityCollegePre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  CityCollegePost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  CityCollegePaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  
  GuttmanCollegePre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  GuttmanCollegePost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  GuttmanCollegePaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  
  LaGuardiaCollegePre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  LaGuardiaCollegePost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  LaGuardiaCollegePaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  
  QueensboroughCollegePre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  QueensboroughCollegePost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  QueensboroughCollegePaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  
  StatenIslandPre <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  StatenIslandPost <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
  statenIslandPaired <<- setNames(data.frame(matrix(ncol = 51, nrow = 0)),BlankColumnNames)
}
#Creates the data frames above on script execution
CreateCUNYCampusDataFrames()

#--------------------------------------------------------------------------------------------------
#Revised general function to create workbook

PopulateWorkBook <- function(campusName,preSheet,postSheet,pairedSheet){
  wb <- createWorkbook()
  
  temp = deparse(substitute(preSheet))
  sheet = createSheet(wb, temp)
  preSheet <- addSurveys(Fall2015Pre,campusName,preSheet)
  preSheet <- addSurveys(Spring2016Pre,campusName,preSheet)
  preSheet <- addSurveys(Fall2016Pre,campusName,preSheet)
  addDataFrame(preSheet, sheet = sheet)
  #PreSheet
  
  temp = deparse(substitute(postSheet))
  sheet = createSheet(wb, temp)
  postSheet <- addSurveys(Fall2015Pre,campusName,postSheet)
  postSheet <- addSurveys(Spring2016Pre,campusName,postSheet)
  postSheet <- addSurveys(Fall2016Pre,campusName,postSheet)
  addDataFrame(postSheet, sheet = sheet)
  #PostSheet
  
  temp = deparse(substitute(pairedSheet))
  sheet = createSheet(wb,temp)
  pairedSheet <- CreatePairedSheet(postSheet, preSheet)
  addDataFrame(pairedSheet, sheet = sheet)
  
  campusName = gsub(" ", "", campusName, fixed = TRUE)
  campusName = sprintf("%s.xlsx",campusName)
  saveWorkbook(wb,campusName)
}
#Example of function use
#  PopulateWorkBook("Baruch College", BaruchCollegePre, BaruchCollegePost,BaruchCollegePaired)



#--------------------------------------------------------------------------------------------------
#COLLEGE RPE POST POPULATION 
PopulateWorkBook <- function(){
  wb <- createWorkbook()
  
  sheet = createSheet(wb,"BrooklynCollegePre")
  BrooklynCollegePre <- addSurveys(Fall2015Pre,"Brooklyn College",BrooklynCollegePre)
  BrooklynCollegePre <- addSurveys(Spring2016Pre,"Brooklyn College",BrooklynCollegePre)
  BrooklynCollegePre <- addSurveys(Fall2016Pre,"Brooklyn College",BrooklynCollegePre)
  BrooklynCollegePre <- BrooklynCollegePre[order(BrooklynCollegePre$StudentName),]
  addDataFrame(BrooklynCollegePre, sheet = sheet)
  #
  sheet = createSheet(wb,"BrooklynCollegePost")
  BrooklynCollegePost <- addSurveys(Fall2015Post,"Brooklyn College",BrooklynCollegePost)
  BrooklynCollegePost <- addSurveys(Spring2016Post,"Brooklyn College",BrooklynCollegePost)
  BrooklynCollegePost <- addSurveys(Fall2016Post,"Brooklyn College",BrooklynCollegePost)
  BrooklynCollegePost <- BrooklynCollegePost[order(BrooklynCollegePost$StudentName),]
  addDataFrame(BrooklynCollegePost, sheet = sheet)
  #
  sheet = createSheet(wb,"BrooklynCollegePaired")
  BrooklynCollegePaired <- CreatePairedSheet(BrooklynCollegePost, BrooklynCollegePre)
  BrooklynCollegePaired <- BrooklynCollegePaired[order(BrooklynCollegePaired$StudentName),]
  addDataFrame(BrooklynCollegePaired, sheet = sheet)
  saveWorkbook(wb, "Brooklyn.xlsx")
  ###---END_BROOKLYN_COLLGE PRE/POST
  
  wb <- createWorkbook()
  sheet = createSheet(wb,"BaruchCollegePre")
  BaruchCollegePre <- addSurveys(Fall2015Pre,"Baruch College",BaruchCollegePre)
  BaruchCollegePre <- addSurveys(Spring2016Pre,"Baruch College",BaruchCollegePre)
  BaruchCollegePre <- addSurveys(Fall2016Pre,"Baruch College",BaruchCollegePre)
  BaruchCollegePre <- BaruchCollegePre[order(BaruchCollegePre$StudentName),]
  addDataFrame(BaruchCollegePre, sheet = sheet)
  #
  sheet = createSheet(wb,"BaruchCollegePost")
  BaruchCollegePost <- addSurveys(Fall2015Post,"Baruch College",BaruchCollegePost)
  BaruchCollegePost <- addSurveys(Spring2016Post,"Baruch College",BaruchCollegePost)
  BaruchCollegePost <- addSurveys(Fall2016Post,"Baruch College",BaruchCollegePost)
  BaruchCollegePost <- BaruchCollegePost[order(BaruchCollegePost$StudentName),]
  addDataFrame(BaruchCollegePost, sheet = sheet)
  #
  sheet = createSheet(wb,"BaruchCollegePaired")
  BaruchCollegePaired <- CreatePairedSheet(BaruchCollegePost, BaruchCollegePre)
  BaruchCollegePaired <- BaruchCollegePaired[order(BaruchCollegePaired$StudentName),]
  addDataFrame(BaruchCollegePaired, sheet = sheet)
  saveWorkbook(wb, "Baruch.xlsx")
  ###---END_BARUCH_COLLEGE Pre/POST
  
  wb <- createWorkbook()
  sheet = createSheet(wb,"CityCollegePre")
  CityCollegePre <- addSurveys(Fall2015Pre,"The City College of New York",CityCollegePre)
  CityCollegePre <- addSurveys(Spring2016Pre,"The City College of New York",CityCollegePre)
  CityCollegePre <- addSurveys(Fall2016Pre,"The City College of New York",CityCollegePre)
  CityCollegePre <- CityCollegePre[order(CityCollegePre$StudentName),]
  addDataFrame(CityCollegePre, sheet = sheet)
  #
  sheet = createSheet(wb,"CityCollegePost")
  CityCollegePost <- addSurveys(Fall2015Post,"The City College of New York",CityCollegePost)
  CityCollegePost <- addSurveys(Spring2016Post,"The City College of New York",CityCollegePost)
  CityCollegePost <- addSurveys(Fall2016Post,"The City College of New York",CityCollegePost)
  CityCollegePost <- CityCollegePost[order(CityCollegePost$StudentName),]
  addDataFrame(CityCollegePost, sheet = sheet)
  #
  sheet = createSheet(wb,"CityCollegePaired")
  CityCollegePaired <- CreatePairedSheet(CityCollegePost, CityCollegePre)
  CityCollegePaired <- CityCollegePaired[order(CityCollegePaired$StudentName),]
  addDataFrame(CityCollegePaired, sheet = sheet)
  saveWorkbook(wb, "CityCollege.xlsx")
  ###---END_CITY_COLLEGE Pre/POST
  
  wb <- createWorkbook()
  sheet = createSheet(wb,"GuttmanCollegePre")
  GuttmanCollegePre <- addSurveys(Fall2015Pre,"Guttman Community College",GuttmanCollegePre)
  GuttmanCollegePre <- addSurveys(Spring2016Pre,"Guttman Community College",GuttmanCollegePre)
  GuttmanCollegePre <- addSurveys(Fall2016Pre,"Guttman Community College",GuttmanCollegePre)
  GuttmanCollegePre <- GuttmanCollegePre[order(GuttmanCollegePre$StudentName),]
  addDataFrame(GuttmanCollegePre, sheet = sheet)
  #
  sheet = createSheet(wb,"GuttmanCollegePost")
  GuttmanCollegePost <- addSurveys(Fall2015Post,"Guttman Community College",GuttmanCollegePost)
  GuttmanCollegePost <- addSurveys(Spring2016Post,"Guttman Community College",GuttmanCollegePost)
  GuttmanCollegePost <- addSurveys(Fall2016Post,"Guttman Community College",GuttmanCollegePost)
  GuttmanCollegePost <- GuttmanCollegePost[order(GuttmanCollegePost$StudentName),]
  addDataFrame(GuttmanCollegePost, sheet = sheet)
  #
  sheet = createSheet(wb,"GuttmanCollegePaired")
  GuttmanCollegePaired <- CreatePairedSheet(GuttmanCollegePost, GuttmanCollegePre)
  GuttmanCollegePaired <- GuttmanCollegePaired[order(GuttmanCollegePaired$StudentName),]
  addDataFrame(GuttmanCollegePaired, sheet = sheet)
  saveWorkbook(wb, "Guttman.xlsx")
  ###---END_GUTTMAN_COLLEGE Pre/POST
  
  wb <- createWorkbook()
  sheet = createSheet(wb,"StatenIslandPre")
  StatenIslandPre <- addSurveys(Fall2015Pre,"College of Staten Island",StatenIslandPre)
  StatenIslandPre <- addSurveys(Spring2016Pre,"College of Staten Island",StatenIslandPre)
  StatenIslandPre <- addSurveys(Fall2016Pre,"College of Staten Island",StatenIslandPre)
  StatenIslandPre <- StatenIslandPre[order(StatenIslandPre$StudentName),]
  addDataFrame(StatenIslandPre, sheet = sheet)
  #
  sheet = createSheet(wb,"StatenIslandPost")
  StatenIslandPost <- addSurveys(Fall2015Post,"College of Staten Island",StatenIslandPost)
  StatenIslandPost <- addSurveys(Spring2016Post,"College of Staten Island",StatenIslandPost)
  StatenIslandPost <- addSurveys(Fall2016Post,"College of Staten Island",StatenIslandPost)
  StatenIslandPost <- StatenIslandPost[order(StatenIslandPost$StudentName),]
  addDataFrame(StatenIslandPost, sheet = sheet)
  #
  sheet = createSheet(wb,"StatenIslandPaired")
  StatenIslandPaired <- CreatePairedSheet(StatenIslandPost, StatenIslandPre)
  StatenIslandPaired <- StatenIslandPaired[order(StatenIslandPaired$StudentName),]
  addDataFrame(StatenIslandPaired, sheet = sheet)
  saveWorkbook(wb, "StatenIsland.xlsx")
  ###---END_STATEN_ISLAND Pre/POST
  
  wb <- createWorkbook()
  sheet = createSheet(wb,"QueensboroughCollegePre")
  QueensboroughCollegePre <- addSurveys(Fall2015Pre,"Queensborough Community College",QueensboroughCollegePre)
  QueensboroughCollegePre <- addSurveys(Spring2016Pre,"Queensborough Community College",QueensboroughCollegePre)
  QueensboroughCollegePre <- addSurveys(Fall2016Pre,"Queensborough Community College",QueensboroughCollegePre)
  QueensboroughCollegePre <- QueensboroughCollegePre[order(QueensboroughCollegePre$StudentName),]
  addDataFrame(QueensboroughCollegePre, sheet = sheet)
  #
  sheet = createSheet(wb,"QueensboroughCollegePost")
  QueensboroughCollegePost <- addSurveys(Fall2015Post,"Queensborough Community College",QueensboroughCollegePost)
  QueensboroughCollegePost <- addSurveys(Spring2016Post,"Queensborough Community College",QueensboroughCollegePost)
  QueensboroughCollegePost <- addSurveys(Fall2016Post,"Queensborough Community College",QueensboroughCollegePost)
  QueensboroughCollegePost <- QueensboroughCollegePost[order(QueensboroughCollegePost$StudentName),]
  addDataFrame(QueensboroughCollegePost, sheet = sheet)
  #
  sheet = createSheet(wb,"QueensboroughCollegePaired")
  QueensboroughCollegePaired <- CreatePairedSheet(QueensboroughCollegePost, QueensboroughCollegePre)
  QueensboroughCollegePaired <- QueensboroughCollegePaired[order(QueensboroughCollegePaired$StudentName),]
  addDataFrame(QueensboroughCollegePaired, sheet = sheet)
  saveWorkbook(wb, "Queensborough.xlsx")
  ###---END_QEEUNSBOROUGH_COLLEGE Pre/POST
  
  wb <- createWorkbook()
  sheet = createSheet(wb,"LaGuardiaCollegePre")
  LaGuardiaCollegePre <- addSurveys(Fall2015Pre,"LaGuardia Community College",LaGuardiaCollegePre)
  LaGuardiaCollegePre <- addSurveys(Spring2016Pre,"LaGuardia Community College",LaGuardiaCollegePre)
  LaGuardiaCollegePre <- addSurveys(Fall2016Pre,"Queensborough Community College",LaGuardiaCollegePre)
  LaGuardiaCollegePre <- LaGuardiaCollegePre[order(LaGuardiaCollegePre$StudentName),]
  addDataFrame(LaGuardiaCollegePre, sheet = sheet)
  #
  sheet = createSheet(wb,"LaGuardiaCollegePost")
  LaGuardiaCollegePost <- addSurveys(Fall2015Post,"LaGuardia Community College",LaGuardiaCollegePost)
  LaGuardiaCollegePost <- addSurveys(Spring2016Post,"LaGuardia Community College",LaGuardiaCollegePost)
  LaGuardiaCollegePost <- addSurveys(Fall2016Post,"LaGuardia Community College",LaGuardiaCollegePost)
  LaGuardiaCollegePost <- LaGuardiaCollegePost[order(LaGuardiaCollegePost$StudentName),]
  addDataFrame(LaGuardiaCollegePost, sheet = sheet)
  #
  sheet = createSheet(wb,"LaGuardiaCollegePaired")
  LaGuardiaCollegePaired <- CreatePairedSheet(LaGuardiaCollegePost, LaGuardiaCollegePre)
  LaGuardiaCollegePaired <- LaGuardiaCollegePaired[order(LaGuardiaCollegePaired$StudentName),]
  addDataFrame(LaGuardiaCollegePaired, sheet = sheet)
  saveWorkbook(wb, "LaGuardia.xlsx")
  ###---END_LAGUARDIA_COLLEGE Pre/POST
}
#END COLLEGE PRE POST POPULATION

#----------------------------------------------------------------------
#There are a few metrics that are created through the means of relating
#questions. The metrics include: 
#Student level of confidence (In self and work)
#Student understanding of scientific work (Experience)
#High Experience Students Vs Low experiece students Cluster
#STEM vs Non-STEM Major students
#
#----------------------------------------------------------------------
#This function is used to create the data frame for the means of the
#confidence questions.
#The parameter passed in is the data frame you wish to find the confidence
#means of. The return value is the data frame with the means.
  

getConfidenceMeans <- function(ReadFromDF){
  ConfidenceMeans <- data.frame(colMeans(subset(ReadFromDF, select = c(ProjectSemester,Campus,StudentName,Major,A7,A9,A10,A15,A16,A18,A23,B10,B13,B15,B16,B19,B22))))
  ConfidenceMeans <- setNames(ConfidenceMeans[1], "Mean")
  
  return(ConfidenceMeans)
}

ConfidenceIndex <- colMeans(ConfidenceMeans)

#----------------------------------------------------------------------
#High skilled students vs low Skilled 
#Compare the students average for questions A11,A12,A12,A14,A15,A16
#against the average of the whole set. The students above the set 
#average will be considered high skilled whereas the ones under 
#the set average will be the low skilled. 
SkillSetMean <- data.frame(colMeans(subset(AREM_Fall15, subset = c(A11,A12,A13,A14,A15,A16))))
SkillSetMean <- setNames(SkillSetMean[1], "Mean")
SkillSetIndex <- colMeans(SkillSetMean)




