library(tidyverse)
# add age breakdown -------------------------------------------------------
byage<-as_tibble(read.csv(file.choose()))
head(byage)

#clean remove spaces and cover to numeric
removespaces<-function(x){
  nospace<-gsub(" ","",x)
  as.numeric(nospace)
}
removespaces(byage$Female)

byage<- byage %>% mutate(Female_ = removespaces(Female),
                         Male_ = removespaces(Male)) 


disorderedlevs<-byage$Age %>% as.factor() %>% levels()
orderedlevs<-c(disorderedlevs[1],
               disorderedlevs[11],
               disorderedlevs[2],
               disorderedlevs[c(4:10,12:21)],
               disorderedlevs[3])
byage$Age<-factor(byage$Age,levels = orderedlevs)
levels(byage$Age)


longformat<-pivot_longer(byage,cols = Male_:Female_)

# ANIMATION ---------------------------------------------------------------
library(gganimate)
library(patchwork)
ggplot(longformat[longformat$Time<2030,], aes(y = Age, fill = name,
                                                  x = ifelse(name == "Male_", yes = value,
                                                             no = -value)))+
  geom_col()+
  theme_void()+
  labs(title = "Canada Population Pyramid Across Time",x = "Population (Thousands)", y = 'Age (Years)') +
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.text = element_text(color = "black"),
        plot.title = element_text(hjust = 0.5, size = rel(2)),
        axis.title.y = element_text(angle = 90),
        axis.text.y = element_blank())+
  scale_fill_manual(labels = c("Female", "Male"), 
                    values = c("#F8766D", "#00BFC4"))+
  xlab("Population (Thousands)")+
  ylab("")+
  geom_text(aes(x = 0, y = Age, label = Age))+
  geom_text(aes(x = -1000, y = 20, label =  format(Time, digits = 0)), 
            size = rel(10))+
  transition_time(Time) +
  enter_fade() +
  exit_fade()+
  ease_aes('linear')+
scale_x_continuous(labels = abs, 
                   limits = max(longformat$value) * c(-1,1),
                   breaks = c(-1000,-500,500,1000))

