library(rvest)
library(tidyverse)
library(ggrepel)
library(sf)
library(stringr)
library(ggrepel)
library(gganimate)
library(ggtext)
library(showtext)
library(gt)
library(ggiraph)
library(patchwork)

sysfonts::font_add_google(name = "Roboto", "Roboto")
showtext::showtext_auto()


url<- "https://en.wikipedia.org/wiki/Ontario_Parks"

dates<-as.data.frame(readClipboard())
colnames(dates)<-"date_text"
dates<-dates[dates$date_text!="",]

#get first 4 to isolate year
year<-as_tibble(as.numeric(substr(dates, 1, 4)[-5]))
year$description<-substr(dates,8,1000000L)[-5]
year$description[4]<-paste(year$Description[4],dates[5])
colnames(year)<-c("Year","Description")
seq(1893,2022,1)

#add in years between
yearsfilled<-year %>%
  complete(Year = seq(1893,2022,1))

year<- year %>% arrange(desc(Year))
#table of labels
yeartb <- 
  gt(year) %>% 
  tab_header(
    title = "History of Ontario parks",
    subtitle = "Key dates"
  )
yeartb

gtsave(yeartb, "gttable.png")

year$Description_html<-htmltools::htmlEscape(year$Description, TRUE)


# Plot timeline -----------------------------------------------------------

           
plt<-ggplot(yearsfilled, (aes(x = 0.05, y = Year, 
                              label = Description)))+
  #geom_path()+
  geom_point_interactive(data = year, aes(tooltip = Description_html, data_id = Description_html),
             fill = "#00ab67", size = 3,
             shape = 21, col = "black")+
  scale_x_continuous(limits = c(0,6),expand = c(0, 0))+
  scale_y_continuous(limits = c(1880, 2020), 
                     breaks = scales::pretty_breaks(n = 10)(1900:2020))+
  theme_classic()+
  labs(title = "Ontario Parks Historical Timeline",y = "", x = "",
       caption = "Data: Wikipedia, Graphic: @jeff_zeyl")+
  coord_cartesian(clip = "off")+
  theme(panel.background = element_rect(fill = "#0075bf"),
        plot.background = element_rect(fill = "#0075bf"),
        axis.text.y = element_text(colour = "black"),
        axis.ticks.y = element_line(colour = "black"),
        
        axis.text.x = element_blank(),
        axis.line.x = element_blank(),
        plot.title = element_text(hjust = 0.5),
        axis.ticks.x = element_blan)
plt



# Add the map -------------------------------------------------------------
canada_cd <- st_read("C:/Users/jeffz/Desktop/data analysis projects/ontarioparks/canada_cd_sim.geojson", quiet = TRUE) # 1
canada_cd$PRNAME<-as.factor(canada_cd$PRNAME)

crs_string = "+proj=lcc +lat_1=49 +lat_2=77 +lon_0=-91.52 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs" # 2


ontariomap<-ggplot() +
  geom_sf(aes(fill = PRNAME), size = 0.1, 
          data = canada_cd[canada_cd$PRNAME=="Ontario",],
          fill = "#0075bf",
          col = "white") + 
  coord_sf(crs = crs_string)+
  theme_bw()+
  theme(axis.text = element_blank(),
        panel.border = element_rect(colour = "#0075bf", fill=NA, size = 5),
        panel.background = element_rect(fill = "#0075bf"),
        panel.grid = element_blank(),
        legend.position = "none",
        axis.ticks = element_blank(),
        plot.background = element_rect(fill = "#0075bf", colour = NA))

ontariomap



# Combine plots in patchwork ----------------------------------------------


two<-plt+inset_element(ontariomap, left = 0,
                    right = 1,
                    bottom =0,
                    top = 1)
  #theme(panel.border = element_rect(col = "pink"))
two
two$patches$layout$widths  <- 1
two$patches$layout$heights <- 1

two

#make interactive plot
tooltip_css <- "background-color:white;
                font-style:bold;
                font:5px 'Roboto', sans-serif;
                border-color:black;

                stroke-width:7;"
tooltip_css<- "
border:2px solid black;
width: 50%;

background:#eee;
color:black;
line-height:10px;
border-radius:10px;
                padding: 5px 0;
font:8px 'Roboto', sans-serif;
text-decoration:none;
transition:all .5s ease-in-out;"
  girafe(ggobj = two, 
         options = list(
           opts_tooltip(css = tooltip_css,
                        offx = 3,offy = 0),
           opts_hover(css = "fill:white;"),
           opts_sizing(rescale = TRUE)
           ))
