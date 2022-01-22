d<-read.csv(file.choose())

#make data numeric

d$Median.of.total.assessment.value.8.9.10<-as.numeric(gsub(",","",d$Median.of.total.assessment.value.8.9.10), na.action = na.omit)/1000
d$Median.total.family.income.10.11.12<-as.numeric(gsub(",","",d$Median.total.family.income.10.11.12), na.action = "omit")/1000
d$diff<-d$Median.of.total.assessment.value.8.9.10-d$Median.total.family.income.10.11.12


library(ggplot2)

geo<-split(d,d$Geography)

View(geo[2][[1]])
point<-ggplot(data = d, aes(x = Median.total.family.income.10.11.12, 
                     y = Median.of.total.assessment.value.8.9.10, factor = Geography))+
  geom_point(aes(col = Geography), show.legend = F)+
  scale_color_manual(values = c("red","green","blue"))+
  geom_smooth(method = "lm", col = "black", aes(fill = Geography), show.legend = F)+
  ylab("Median residence value\n in thousands ($)")+
  xlab("Median total household income in thousands ($)")+
  theme_classic()
point
 
options("scipen"=100, "digits"=4)

#property values
bx<-  ggplot(data = d, aes(x = reorder(Geography,Median.of.total.assessment.value.8.9.10), 
                                 y = Median.of.total.assessment.value.8.9.10))+
  geom_boxplot(aes(fill = Geography))+
  geom_point(aes(), col = "black")+
  scale_fill_manual(values = c("red","green","blue"))+
  theme_classic()+
  theme(legend.position = "none")+
  ylab("Median residence value\n in thousands ($)")+
  xlab("Province")+
  theme(axis.text.x = element_text(angle = 30, vjust = 0.5))
  bx

income<-ggplot(data = d, aes(x = reorder(Geography,Median.of.total.assessment.value.8.9.10),
                           y = Median.total.family.income.10.11.12))+
  geom_boxplot(aes(fill = Geography))+
  geom_point(aes(), col = "black")+
  scale_fill_manual(values = c("red","green","blue"))+
  theme_classic()+
  ylim(c(0,800))+
  theme(legend.position = "none")+
  ylab("Median total household income\n in thousands ($)")+
  xlab("Province")+
  theme(axis.text.x = element_text(angle = 30, vjust = 0.5))
income

library(patchwork)
map+(point/(bx+income))+plot_layout(widths = c(1, 1))+  
  plot_annotation(title = "Housing prices and household income compared across 3 provinces (2018)",
    #subtitle = "These  plots will reveal yet-untold secrets about our beloved data-set",
    caption = "Data source: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=4610005101")
 
