library(shiny)
library(ggplot2)

library(geojsonio)
library(rmapshaper)
library(rgdal)
library(tidyverse)
library(spdplyr)
library(sf)
library(socviz)

library(patchwork)

canada_cd <- st_read("canada_cd_sim.geojson", quiet = TRUE) # 1

crs_string = "+proj=lcc +lat_1=49 +lat_2=77 +lon_0=-91.52 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs" # 2

# Define the maps' theme -- remove axes, ticks, borders, legends, etc.
theme_map <- function(base_size=9, base_family="") { # 3
  require(grid)
  theme_bw(base_size=base_size, base_family=base_family) %+replace%
    theme(axis.line=element_blank(),
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank(),
          panel.background=element_blank(),
          panel.border=element_blank(),
          panel.grid=element_blank(),
          panel.spacing=unit(0, "lines"),
          plot.background=element_blank(),
          legend.justification = c(0,0),
          legend.position = c(0,0)
    )
}
# Define the filling colors for each province; max allowed is 9 but good enough for the 13 provinces + territories
map_colors <- RColorBrewer::brewer.pal(9, "Pastel1") %>% rep(37) # 4

canada_cd$PRNAME<-as.factor(canada_cd$PRNAME)

# Plot the maps
map<-ggplot() +
  geom_sf(aes(fill = PRNAME), size = 0.1, data = canada_cd) + # 5
  coord_sf(crs = crs_string) + # 6
  scale_fill_manual(values = c(rep("grey",1),"red",
                               rep("grey",4),"green",
                               rep("grey",1),"blue",
                               rep("grey",4)
  )) +
  guides(fill = FALSE) +
  theme_map() +
  theme(panel.grid.major = element_line(color = "white"),
        legend.key = element_rect(color = "gray40", size = 0.1))
map

scalevalues<-rep("blue",13)


rent<-read.csv("rent canada.csv")

#remove cities that have parts in two provinces
rentclean<-rent[!grepl("part", rent$province),]
rentclean<-rentclean[which(rentclean$VALUE>0),]
rentclean
names(rentclean)[1]<-"REF_DATE"



# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Rent in Canada by province and unit type"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      selectInput(inputId = "bins",
                  label = "Province",
                  choices = list("Alberta",
                                 "British Columbia",
                                 "Manitoba"                                           ,
                                 "New Brunswick"                  ,
                                 "Newfoundland and Labrador",
                                 "Northwest Territories"  ,
                                 "Nova Scotia"                      ,
                                 "Nunavut"                                            ,
                                 "Ontario"                                            ,
                                 "Prince Edward Island"       ,
                                 "Quebec"                                    ,
                                 "Saskatchewan"                                       ,
                                 "Yukon",
                                 "All"),      
                  selected = "Alberta"),
      selectInput("type", 
                  label = "Housing unit type",
                  choices = list("Bachelor units",
                                 "One bedroom units",
                                 "Two bedroom units",  
                                 "Three bedroom units"),
                  selected = "Percent White"),
      tags$div(
        #h1("Hello Shiny!"),
        #hr(),
        #p(strong("Data from Statcan "), em("italic font")),
        #p(code("code block")),
        a(href="https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3410013301", 
          "Data from Statistics Canada"),
        #HTML('<p>
        # <label>A numeric input:</label><br /> 
        # <input type="number" name="n" value="7" min="1" max="30" />
        # </p>')
      )
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "distPlot")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  

  
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  output$distPlot <- renderPlot({
    

    if(input$bins =="Alberta"){
       scalevalues<-c("red", rep("grey",12)) 
    }
    else if(input$bins =="British Columbia"){
    scalevalues<-c("grey","red", rep("grey",11)) 
  }
    else if(input$bins =="Manitoba"){
      scalevalues<-c(rep("grey",2),"red", rep("grey",10)) 
    }
    else if(input$bins =="New Brunswick"){
      scalevalues<-c(rep("grey",3),"red", rep("grey",9)) 
    }
    else if(input$bins =="Newfoundland and Labrador"){
      scalevalues<-c(rep("grey",4),"red", rep("grey",8)) 
    }
    else if(input$bins =="Northwest Territories"){
      scalevalues<-c(rep("grey",5),"red", rep("grey",7)) 
    }
    else if(input$bins =="Nova Scotia"){
      scalevalues<-c(rep("grey",6),"red", rep("grey",6)) 
    }
    else if(input$bins =="Nunavut"){
      scalevalues<-c(rep("grey",7),"red", rep("grey",5)) 
    }
    else if(input$bins =="Ontario"){
      scalevalues<-c(rep("grey",8),"red", rep("grey",4)) 
    }
    else if(input$bins =="Prince Edward Island"){
      scalevalues<-c(rep("grey",9),"red", rep("grey",3)) 
    }
    else if(input$bins =="Quebec"){
      scalevalues<-c(rep("grey",10),"red", rep("grey",2)) 
    }
    else if(input$bins =="Saskatchewan"){
      scalevalues<-c(rep("grey",11),"red", rep("grey",1)) 
    }
    else if(input$bins =="Yukon"){
      scalevalues<-c(rep("grey",12),"red") 
    } 
    

    
    
    # Plot the maps
    map<-ggplot() +
      geom_sf(aes(fill = PRNAME), size = 0.1, data = canada_cd) + # 5
      coord_sf(crs = crs_string) + # 6
      scale_fill_manual(values = scalevalues) +
      guides(fill = FALSE) +
      theme_map() +
      theme(panel.grid.major = element_line(color = "white"),
            legend.key = element_rect(color = "gray40", size = 0.1))
    

   if(input$bins =="All"){
     rentdata<-rentclean[rentclean$Type.of.unit==input$type,]
     
     
     rentplt<-ggplot(data = rentdata, 
                      aes(x = REF_DATE, y = VALUE))+
        geom_hline(yintercept = 1000)+
        geom_point(aes())+
        ylab("Rent in Dollars")+
        xlab("Year")+
        theme_bw()+
        geom_smooth(method = "loess", col = "red")+
        facet_wrap(facets = vars(province))+
        ggtitle(paste0(input$type))
      
      rentplt
      
    }
    
    else{
      rentdata<-rentclean[rentclean$Type.of.unit==input$type&
                            rentclean$province==paste0(" ",input$bins),]
      
      rentplt<-ggplot(data = rentdata, 
                    aes(x = REF_DATE, y = VALUE))+
      geom_hline(yintercept = 1000)+
      geom_point(aes())+
      ylab("Rent in Dollars")+
      xlab("Year")+
      theme_bw()+
      geom_smooth(method = "loess", col = "red")+
      #facet_wrap(facets = vars(province))+
      ggtitle(paste0(input$type," in ",input$bins))
   
    rentplt+map
    }

      
    
    
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)