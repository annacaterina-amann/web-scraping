if (!require("pacman")) install.packages("pacman") #Installs package for package installation if not already here

pacman::p_load("tidyverse","rvest","stringr","stringr", "rebus", "lubridate", "xml2", "dplyr", "stringr", "purrr", "RSelenium")  #Loads packages and installs if they are not found


########################
####scrape lv-numbers####
#########################


#rD <- RSelenium::rsDriver() # This might throw an error

# Start Selenium server and browser
rD <- RSelenium::rsDriver(browser = "chrome",
                          chromever = "107.0.5304.62")
# Assign the client to an object
remDr <- rD[["client"]]

remDr$navigate("https://lfuonline.uibk.ac.at/public/lfuonline_lv.home")

faculties <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level1']")

Sys.sleep(1)

# Highlight to check that was correctly selected

for (faculty in faculties) {
  faculty$clickElement()
  
  Sys.sleep(0.5)
  
  studies <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level2']")
  
  for (study in studies) {
    study$clickElement()
    
    Sys.sleep(0.5)
    
    modules <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level3']")
    
    for (module in modules) {
      module$clickElement()
      
      Sys.sleep(0.5)
      
      subModules <- remDr$findElements(using = "xpath", value = "//div[@class='xnode level4']")
      
      for (subModule in subModules) {
        subModule$clickElement()
        
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

#zusaetzlich den Titel ausgeben
#html_text(html_nodes(html2, xpath = "//div[@class='lv-title']"))

#############################
#########urls generieren#####
############################

url_vector <- c((paste("https://lfuonline.uibk.ac.at/public/lfuonline_lv.details?sem_id_in=22W&lvnr_id_in=",lv_numbers, sep = "")))

url_vector

####scraping data from one  lv####

course_1 <- read_html("https://lfuonline.uibk.ac.at/public/lfuonline_lv.details?sem_id_in=22W&lvnr_id_in=621009")

html_text(html_nodes(course_1,xpath = "//div[./label ='Titel:']/following-sibling::div"))
html_text(html_nodes(course_1,xpath = "//div[./label ='Inhalt:']/following-sibling::div"))

####put in a dataframe, pro Kurs eine Zeile, Attribute in Spalten####

##all courses###

require(httr)
library('xml2')
library("writexl")

dataframe_courses <- tibble()
source("https://raw.githubusercontent.com/ArminHaberl/Course_Scraping/main/One_Course_Scraping.R")

for (course_ID in url_vector){
  new_course <- scrape_data(course_ID)
  dataframe_courses <<- bind_rows(dataframe_courses,new_course)
  Sys.sleep(0.1)
  
  break;
 
}

write_xlsx(dataframe_courses,"courses.xlsx")




