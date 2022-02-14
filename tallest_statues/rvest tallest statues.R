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


sysfonts::font_add_google(name = "Passion One", "Passion One")
showtext::showtext_auto()

url<- "https://en.wikipedia.org/wiki/List_of_tallest_statues"

img<-png::readPNG(("C:/Users/jeffz/Desktop/data analysis projects/unity_small_crop_.png"))
rst<-as.raster(img)

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
table1$buddhagrouped[grep('Buddha', table1$Depicts)]<-"Buddha Statues"
  
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
  arrange(desc(cnt))1q
country_counts

world<-ne_countries(scale = 'medium', type = 'map_units',
                    returnclass = 'sf')

leftjn<-world %>% left_join(country_counts,by = c("sovereignt" = "Country"))

display.brewer.all()#view palettes
brewer.pal(4,"Purples")#get color codes from palette


map<-ggplot(data = leftjn) +
  geom_sf(data = leftjn, aes(fill = cnt))+
  scale_fill_viridis_c(na.value="white")+
  #labs(title = "Count")+
  labs(fill = "Number of tall statues\n by country")+
  theme_classic()+
  theme(#panel.border = element_line(col = "pink"),
        #legend.position=c(0.1,.25),
        legend.background = element_rect(fill = bckcol, colour = NA),
        axis.line = element_line(color = bckcol),
        text = element_text(family = "Passion One"),
        plot.background = element_rect(fill = bckcol, colour = NA),
        panel.background = element_rect(fill = bckcol),
        plot.margin = unit(c(0,0,0,0), "cm"))+
  coord_sf()
map

# meanheight by country ---------------------------------------------------

maxplt<-ggplot(data = arrange(table1, desc(height_m))[1:5,])+
  #geom_col(aes(x = reorder(Country, maxheight), y = maxheight))+
  #annotation_raster(rst, 0.5, 1.5, 0, 182)+#xmin,xmax,ymin,ymax
  geom_segment(aes(x = reorder(Statue, -height_m), y = 0,
                   xend = reorder(Statue, -height_m),
                   yend = height_m))+
  scale_y_continuous(expand = expansion(mult = 0, add = 0))+
  geom_point(aes(x = reorder(Statue, -height_m), y = height_m))+
  geom_text_repel(aes(x = reorder(Statue, -height_m), y = height_m, label = height_m), nudge_x = 0.25)+
  theme_bw()+
  labs(y = "Height (m)",
       x = "",
       title = "Top 5 tallest statues")+
  theme(panel.border = element_blank(),
        panel.grid=element_blank(),
        plot.title = element_text(hjust=0.5),
        plot.background = element_rect(fill = bckcol, color = NA),
        panel.background = element_rect(fill = bckcol),
        axis.text = element_text(color = "black"),
        text = element_text(family = "Passion One"),
        axis.text.x = element_text(, angle = 30))+
        #axis.text = element_text(col = "black"))+
  coord_cartesian(clip = 'off')
maxplt


# count by country ----------------------------------------------------

depicts<-ggplot(data = depictions[1:5,])+
  #background_image(img)+
  geom_point(aes(x = reorder(buddhagrouped, -cnt), y = cnt))+
  geom_segment(aes(x = reorder(buddhagrouped, -cnt), 
                   y = 0,
                   xend = reorder(buddhagrouped, cnt),
                   yend = cnt))+
  labs(title = "Top 5 depictions", 
       x = "",
       y = "Number of n\ depictions")+
  theme_bw()+
  theme(panel.border = element_blank(),
        panel.grid = element_blank(),
        plot.title = element_text(hjust = 0.5),
        plot.background = element_rect(fill = bckcol,, color = NA),
        panel.background = element_rect(fill = bckcol),
        axis.text = element_text(color = "black"),
        axis.text.x = element_text(, angle = 30),
        text = element_text(family = "Passion One"),
        axis.ticks = element_blank())#axis.text.x = element_text(angle = 70)
  #scale_x_continuous(expand = c(0,0))
depicts


# layout ------------------------------------------------------------------

design <- "
  111#
  1112
  1113
  111#
"


fin<-map/(depicts+maxplt)+ 
  plot_layout(heights = c(5,1))+
  plot_annotation(title = "Tallest statues in the world",
                  caption = "Data: Wikipedia, Graphic: @jeff_zeyl",
    theme = theme(plot.background = element_rect(fill = bckcol),
                  plot.title = element_text(hjust = 0.5),
                  text = element_text(family = "Passion One")))

ggsave("C:/Users/jeffz/Desktop/data analysis projects/talleststat__.png",plot = fin,
       height = 6, width = 12.5, units = c("in"))


