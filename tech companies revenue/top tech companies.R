library(tidyverse)
library(ggthemes)
library(ggpubr)#to put image in background of plot

#load data and dollar bill image
df<-read.csv("most valuable tech companies.csv")
img <- png::readPNG("one-dollar-bill.png")

#make revenue field numeric
df[]<-lapply(df,gsub,pattern="$",fixed=TRUE,replacement="")
df$Revenue...B..USD.2.<-as.numeric(df$Revenue...B..USD.2.)

df %>% ggplot(aes(x = reorder(Company,-Revenue...B..USD.2.), y = Revenue...B..USD.2.))+
  background_image(img)+
  geom_col(fill = "light green", color = "black")+
  theme_classic()+
  ylab("Revenue ($Billion USD)")+
  xlab("Company")+
  scale_y_continuous(limits = c(0,300), expand = c(0, 0))+
  ggtitle("Largest technology companies by revenue, 2021")+
  labs(caption = "Source: https://en.wikipedia.org/wiki/List_of_largest_technology_companies_by_revenue")+ 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.95, hjust=1, color = "black"),
        axis.text.y = element_text(color = "black"),
        axis.title.x = element_text(vjust = 1),
        plot.caption = element_text(size = 8))
