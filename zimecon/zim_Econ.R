library(tidyverse)
library("ggplot2")
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
library(patchwork)
library(ggpubr)
library(ggrepel)
library(showfonts)
library(rsvg)

# map ------------------------------------------------------------
worldmap <- ne_countries(scale = 'medium', type = 'map_units',
                         returnclass = 'sf')
Zimbabwe <- worldmap[worldmap$name == 'Zimbabwe',]

zimflag <- rsvg("C:/Users/jeffz/Desktop/data analysis projects/zimecon/Flag_of_Zimbabwe.svg")


zim<-ggplot() + 
  background_image(zimflag)+
  geom_sf(data = Zimbabwe, fill = "grey", 
          alpha =0.5,
          col = "black") + 
  theme_void()
zim

# zim econ data -----------------------------------------------------------

zimecon<-data.frame(matrix(nrow=4, ncol = 2))

names(zimecon) <- c("Sector", "Percentage")
zimecon$Sector <- c("Formal sector (non-agriculture)",
                    "Informal sector (non-agriculture)",
                    "Agriculture", 
                    "Private households")
zimecon$Percentage <- c(26.0,45.6,23.6,4.8)

zimecon<- arrange(zimecon,Percentage)

zimecon$cum<-NA
zimecon$cum<-rev(c(100,54.4,28.4,4.8))

zimecon$Sector<-factor(zimecon$Sector,
                        levels = c("Private households",
                        "Agriculture",
                        "Formal sector (non-agriculture)",
                        "Informal sector (non-agriculture)"))

library(forcats)

sectors<-ggplot(zimecon, 
               aes(x = 1, y = Percentage, 
                  fill = fct_rev(Sector))) +
  geom_bar(stat = "identity",position = "stack")+ 
geom_text(aes(x = 1.5, y = cum-Percentage/2,
                    label = paste0(Sector, " (",Percentage," %)")),
                nudge_x = 0,
          hjust = 0)+
  xlim(c(0.5,3))+
  scale_y_continuous(expand=c(0,0))+
theme_void()+
  theme(legend.position ="none",
        plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  scale_fill_manual(values = c("#000000",
    "#d40000",
    "#ffd200",
    "#006400"))
sectors

library(ggtext)

ggplot(zimecon)+
  geom_text(aes(x = -0.05,y = 0.7), label = "
                Percent Distribution of the Employed Population \n
                15 Years and Above by Sector of 
               Employment, 3rd Quarter QLFS (2021).\n
               Private households\n
               Agriculture\n
               Formal sector (non-agriculture)\n
               Informal sector (non-agriculture)",
            label.size = 5,
            hjust = 0)

zim+sectors+plot_annotation(
  title = "Percent Distribution of the Employed Population
                15 Years and Above by Sector of 
               Employment, 3rd Quarter QLFS (2021)",
  caption = "Source: Zimstat Labour Force Survey, 3rd quarter, 2021\n
            Graphic: @jeff_zeyl",
  theme = theme(plot.background = element_rect("#012456"),
                plot.title = element_text(hjust = 0.5))
                  )




