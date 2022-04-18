library(rvest)
library(patchwork)
library(tidyverse)
library(ggpubr)#to put image in background of plot
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(RColorBrewer)
library(ggrepel)
library(magick)
library(showtext)
library(geomtextpath)
library(ggtext)


sysfonts::font_add_google(name = "Passion One", "Passion One")
showtext::showtext_auto()

url<- "https://en.wikipedia.org/wiki/List_of_tallest_statues"

img<-png::readPNG(("C:/Users/jeffz/Desktop/data analysis projects/unity_small_crop_.png"))
#rst<-as.raster(img)

lab1<-"The tallest statue in the world is the Statue of Unity, in India"

bckcol<-"aliceblue"

# data wrangling ----------------------------------------------------------
table1<-url %>% read_html %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/table[2]') %>%
html_table(fill = TRUE) 

table1<-table1[[1]]
table1<-as_tibble(table1)
table1$height_m<-parse_number(table1$`Heightmeters (feet)`)
table1$completed_year<-parse_number(table1$Completed)

#group all statues with buddha in name
table1$buddhagrouped<-table1$Depicts
table1$buddhagrouped[grep('Buddha', table1$Depicts)]<-"Buddha"
  
depictions<-table1 %>% group_by(buddhagrouped)%>% 
    summarise(cnt = n(),
              meanheight = mean(height_m, na.rm = T),
              maxheight = max(height_m, na.rm = T)) %>%
  arrange(desc(cnt))
depictions

#summary stats by country (for map)  
country_counts<-table1 %>% group_by(Country)%>% 
  summarise(cnt = n(),
            meanheight = mean(height_m, na.rm = T),
            maxheight = max(height_m, na.rm = T)) %>%
  arrange(desc(cnt))
country_counts

world<-ne_countries(scale = 'medium', type = 'map_units',
                    returnclass = 'sf')

leftjn<-world %>% left_join(country_counts,by = c("sovereignt" = "Country"))

display.brewer.all()#view palettes
brewer.pal(4,"Purples")#get color codes from palette

maptext<-"China has the most tall statues (32), 
followed by India (29)"

map<-ggplot(data = leftjn) +
  geom_sf(data = leftjn, aes(fill = cnt))+
  scale_fill_viridis_c(na.value="white")+
  labs(title = maptext,
    fill = "Number of tall\nstatues by country")+
  theme_classic()+
  theme(plot.title = element_textbox_simple(
      size = 13,
      lineheight = 1,
      #padding = margin(5.5, 5.5, 5.5, 5.5),
      margin = margin(0, 0, 0, 0),
      fill = bckcol
    ),
        axis.line = element_line(color = bckcol),
        text = element_text(family = "Passion One"),
        plot.background = element_rect(fill = bckcol, colour = NA),
        panel.background = element_rect(fill = bckcol),
        plot.margin = unit(c(0,0,0,0), "cm"),
    legend.position = c(0.1,0.5),
    legend.background = element_rect(fill = "transparent"))
  guides(color = guide_legend(direction = "horizontal"))+
  coord_sf()
map

# meanheight by country ---------------------------------------------------

tallesttext<-"India's Statue of Unity is the tallest\n 
statue in the world (182 m)"
#library(stringr)
#labs(title = str_wrap(my_title, 60))

top5height<-arrange(table1, desc(height_m))[1:5,]
top5height$Statue <- ordered(top5height$Statue, 
                             levels=c(
                               "Statue of Unity",
                               "Spring Temple Buddha", 
                               "Laykyun Sekkya",
                               "Statue of Belief",
                               "Ushiku Daibutsu"
                             ))


maxplt<-ggplot(data = top5height)+
  geom_segment(aes(x = -3,y = height_m,
                   xend = -2, yend = height_m))+
  scale_y_continuous(limits = c(0,190), expand = c(0,0))+
  scale_x_continuous(limits = c(-3,0),expand = c(0,0))+
  geom_richtext(aes(x = -2.5, y = height_m,label = Statue),hjust = 0,
             label.colour = bckcol, fill = bckcol, family = "Passion One",
             size = 3)+
  theme_classic()+
  labs(y = "Height (m)",
       x = "",
       title = tallesttext)+
  theme(panel.border = element_blank(),
        panel.grid=element_blank(),
        plot.title = element_textbox_simple(
          size = 13,
          lineheight = 1,
          #padding = margin(5.5, 5.5, 5.5, 5.5),
          margin = margin(0, 0, 0, 0),
          fill = bckcol
        ),
        plot.background = element_rect(fill = bckcol, color = NA),
        panel.background = element_rect(fill = bckcol),
        text = element_text(family = "Passion One"),
        axis.text.y = element_text(angle = 0,color = "black"),
        axis.text.x =  element_blank(),
        axis.title.y = element_text(angle = 0, vjust = 0.5),
        axis.line.x = element_blank(),
        #axis.line.x = element_line(color=),
        axis.line.y = element_line(color="black", size = 2),
        axis.ticks = element_blank())+
  geom_point(aes(x = -3, y = height_m),
             size = 3, shape = 21, fill = "white")
maxplt


# count by country ----------------------------------------------------

depictstext<-"The Buddha is the most common depiction"

depicts<-ggplot(data = depictions[1:5,])+
  #background_image(img)+
  geom_point(aes(y = reorder(buddhagrouped, cnt), x = cnt),
             size = 3)+
  geom_segment(aes(y = reorder(buddhagrouped, -cnt), 
                   x = 0,
                   yend = reorder(buddhagrouped, -cnt),
                   xend = cnt))+
  labs(title = depictstext, 
       y = "",
       x = "Number of depictions")+
  theme_bw()+
  theme(panel.border = element_blank(),
        panel.grid = element_blank(),
        plot.title = element_textbox_simple(
          size = 13,
          lineheight = 1,
          margin = margin(0, 0, 0, 0),
          fill = bckcol
        ),
        plot.background = element_rect(fill = bckcol,, color = NA),
        panel.background = element_rect(fill = bckcol),
        axis.text = element_text(color = "black"),
        axis.text.x = element_text(angle = 0),
        text = element_text(family = "Passion One"),
        axis.ticks = element_blank(),
        axis.line.x = element_line(color="black", size = 2),
        axis.line.y = element_line(color=bckcol, size = 0))
depicts


# layout ------------------------------------------------------------------

desgn <- "
  1123
  1123
  1123
"
#library(cowplot)
#plot_grid(map, plot_grid(depicts/maxplt), ncol = 2)


fin<-map+maxplt+depicts+ 
  plot_layout(guides = "keep", design = desgn)+
  plot_layout()+
  plot_annotation(title = "Tallest statues in the world",
                  caption = "Data: Wikipedia\n Graphic: @jeff_zeyl",
    theme = theme(plot.background = element_rect(fill = bckcol),
                  plot.title = element_text(hjust = 0.5, size = 25),
                  text = element_text(family = "Passion One")))
fin

ggsave("C:/Users/jeffz/Desktop/data analysis projects/talleststat_apr18_.png",
       plot = fin,
       height = 5, width = 10, units = "in")


