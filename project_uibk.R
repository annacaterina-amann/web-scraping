if (!require("pacman")) install.packages("pacman") #Installs package for package installation if not already here

pacman::p_load("tidyverse","rvest","stringr","stringr", "rebus", "lubridate", "xml2", "dplyr", "stringr", "purrr", "RSelenium")  #Loads packages and installs if they are not found


########################
####scrape lv-numbers####
#########################


#rD <- RSelenium::rsDriver() # This might throw an error

# Start Selenium server and browser
rD <- RSelenium::rsDriver(browser = "firefox", port = 4828L)
# Assign the client to an object
remDr <- rD[["client"]]

remDr$navigate("https://lfuonline.uibk.ac.at/public/lfuonline_lv.home?sem_id_in=22W&suche_in=")

faculties <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level1']")

Sys.sleep(1)

# Highlight to check that was correctly selected

for (faculty in faculties) {
  faculty$clickElement()
  
  Sys.sleep(0.1)
  
  studies <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level2']")
  
  for (study in studies) {
    study$clickElement()
    
    Sys.sleep(0.1)
    
    modules <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level3']")
    
    for (module in modules) {
      module$clickElement()
      
      Sys.sleep(0.1)
      
      subModules <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level4']")
      
      for (subModule in subModules) {
        subModule$clickElement()
        
        Sys.sleep(0.1)
        
        subsubModules <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level5']")
        
        for (subsubModule in subsubModules) {
          subsubModule$clickElement()
          
        }
        #break;
      }
      
      #break;
    }
    
    #break;
  }
  #break;
}

html <- remDr$getPageSource()[[1]]

html2 <- read_html(html)

lv_numbers <- c(html_text(html_nodes(html2, xpath = "//div[@class='lv-no']")))
print(lv_numbers)





#################
###create urls###
#################

url_vector <- c((paste("https://lfuonline.uibk.ac.at/public/lfuonline_lv.details?sem_id_in=22W&lvnr_id_in=",lv_numbers, sep = "")))



####put in a dataframe, pro Kurs eine Zeile, Attribute in Spalten####

#Creating a loop where he goes through all url of uni-innsbruck courses


# you have do define an empty data frame --> otherwise the colums in the loop data.frame don´t match
sum_courses = data.frame()


#Creating a loop for all course pages of uni-Insb starting with the min lv_number in +1 steps till the max

for(page_result in url_vector)   {
  print(paste("Page:", page_result))
  #the link needs to be adjusted with the course number
  #link = paste("https://lfuonline.uibk.ac.at/public/lfuonline_lv.details?sem_id_in=22W&lvnr_id_in=",page_result,sep="")
  page = read_html(page_result)
  # I used the selector gadget of chrome to chose the right html_nodes
  course_number = page %>% html_node(xpath = "//div[./label ='LV-Nummer:']/following-sibling::div") %>% html_text()
  course_name = page %>% html_node(xpath = "//div[./label ='Titel:']/following-sibling::div") %>% html_text()
  semester = page %>% html_node(".text-nowrap.xxs-block") %>% html_text() 
  institute = page %>% html_node("hr+ .form-group a") %>% html_text()
  ECTS = page %>% html_node(xpath = "//div[./label ='ECTS-AP:']/following-sibling::div") %>% html_text()
  repetition = page %>% html_node(xpath = "//div[./label ='Wiederholungsturnus:']/following-sibling::div") %>% html_text()
  language = page %>% html_node(xpath = "//div[./label ='Unterrichtssprache:']/following-sibling::div") %>% html_text()
  learning_result = page %>% html_node(xpath = "//div[./label ='Lernergebnis:']/following-sibling::div") %>% html_text()
  content = page %>% html_node(xpath = "//div[./label ='Inhalt:']/following-sibling::div") %>% html_text()
  method = page %>% html_node(xpath = "//div[./label ='Methoden:']/following-sibling::div") %>% html_text()
  exam_mode = page %>% html_node(xpath = "//div[./label ='Prüfungsmodus:']/following-sibling::div") %>% html_text()
  literature = page %>% html_node(xpath = "//div[./label ='Literatur:']/following-sibling::div") %>% html_text()
  requirements = page %>% html_node(xpath = "//div[./label ='Voraussetzungen:']/following-sibling::div") %>% html_text()
  
  #no double entries with unique and NAs shall be excluded
  sum_courses = rbind(sum_courses, data.frame(course_number,course_name, semester,institute,ECTS,repetition, language,learning_result, content, method, exam_mode, literature,requirements,  stringsAsFactors=TRUE))
  
  
  
}


#checking for duplicates

duplicated(sum_courses)
sum(duplicated(sum_courses))

#removing duplicate data

sum_courses_cleaned <- distinct(sum_courses, course_number, .keep_all = TRUE)

#remove empty data
sum_courses_fullrecords = data_frame()
sum_courses_fullrecords <- sum_courses_cleaned[complete.cases(sum_courses_cleaned), ]
