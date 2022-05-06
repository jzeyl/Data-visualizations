#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(reactable)
library(tidyverse)
freedom<-read.csv(url('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-02-22/freedom.csv'))
colnames(freedom)<-c("Country","Year","Civil liberties score",
                     "Political rights score", "Status",
                     "Region_Code","Region_Name","is_ldc")

freedom2020<-freedom[freedom$Year==2020,]
sparklinebycountry<-
freedom %>% group_by(Country)

# Define UI 

ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(    
          selectInput("region", "Explore Region",
                c("Asia" ,
                  "Europe",
                  "Africa",
                  "Americas",
                  "Oceania")),
        #div tag
          tags$div(class="header", checked=NA,
             tags$a(href="https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-02-22/freedom.csv", "Raw data here.")
    )
          ),
    mainPanel(
      # Output: Tabset w/ plot, summary, and table ----
reactableOutput("data")
              )
)
)

server <- function(input, output) {
      output$data <- renderReactable({
        reactable(freedom2020[freedom2020$Region_Name==input$region,c("Country","Civil liberties score","Political rights score")]
                  )
                                    })

        
    output$tab_b<-renderPrint({
      "hello"
    })
}



# Run the application 
shinyApp(ui = ui, server = server)
