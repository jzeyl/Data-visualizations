library(tidyverse)
library(ggthemes)
library(ggpubr)#to put image in background of plot

#load data and dollar bill image
df<-read.csv("most valuable tech companies.csv")
img <- png::readPNG("one-dollar-bill half opacity.png")

sysfonts::font_add_google(name = "Jura", "Jura")
showtext::showtext_auto()

#make revenue field numeric
df[]<-lapply(df,gsub,pattern="$",fixed=TRUE,replacement="")
df$Revenue...B..USD.2.<-as.numeric(df$Revenue...B..USD.2.)

df %>% ggplot(aes(x = reorder(Company,-Revenue...B..USD.2.), y = Revenue...B..USD.2.))+
  background_image(img)+
  #geom_col(fill = "light green", color = "black")+
  geom_segment(aes(x = reorder(Company,-Revenue...B..USD.2.),
                   y = 0,
                   xend = reorder(Company,-Revenue...B..USD.2.),
                   yend = Revenue...B..USD.2.),
               color = "black",
               lineend = "round")+
  geom_point(size = 10, shape = 21, color = "black", fill = "#f6f6e5")+
  geom_text(size = 4, label = "$")+
  theme_classic()+
  scale_y_continuous(limits = c(0,300), expand = c(0, 0))+
  labs(y = "Revenue\n (Billion USD)",
       x = "Company",
       title = "Largest technology companies by revenue (**2021**)",
    caption = "Source: https://en.wikipedia.org/wiki/\nList_of_largest_technology_companies_by_revenue\n
    Graphic: @jeff_zeyl")+ 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.95, hjust=1, color = "black"),
        axis.text.y = element_text(color = "black"),
        axis.title.x = element_text(vjust = 1),
        plot.caption = element_text(size = 8),
        plot.title = element_markdown(hjust = 0.5),
        panel.background = element_blank(),
        text = element_text(family = "Jura"),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        plot.background = element_rect(fill = "#f6f6e5"))
