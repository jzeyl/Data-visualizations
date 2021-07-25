d<-read.csv(file.choose())

d <- gsub(",","",d)#remove commas introduced in table
library(ggplot2)

geo<-split(d,d$Geography)

View(geo[2][[1]])
point<-ggplot(data = d, aes(x = Median.total.family.income.10.11.12, 
                     y = Median.of.total.assessment.value.8.9.10, factor = Geography))+
  geom_point(aes(col = Geography), show.legend = F)+
  scale_color_manual(values = c("red","green","blue"))+
  geom_smooth(method = "lm", col = "black")+
  ylab("median residence value")+
  xlab("median total family income")+
  theme_classic()
point
  #geom_point(aes(col = Sex.of.property.owner, shape = Family.type.4))

options("scipen"=100, "digits"=4)

#property values
bx<-  ggplot(data = d, aes(x = reorder(Geography,Median.of.total.assessment.value.8.9.10), 
                                 y = Median.of.total.assessment.value.8.9.10))+
  geom_boxplot(aes(fill = Geography))+
  geom_point(aes(), col = "black")+
  scale_fill_manual(values = c("red","green","blue"))+
  theme_classic()+
  theme(legend.position = "none")+
  ylab("Asset value")+
  xlab("Province")
  bx

income<-ggplot(data = d, aes(x = reorder(Geography,Median.of.total.assessment.value.8.9.10),
                           y = Median.total.family.income.10.11.12))+
  geom_boxplot(aes(fill = Geography))+
  geom_point(aes(), col = "black")+
  scale_fill_manual(values = c("red","green","blue"))+
  theme_classic()+
  theme(legend.position = "none")+
  ylab("Median total household income ($)")+
  xlab("Province")
income

library(ggpubr)
ggarrange(map,point,bx,income, nrow = 1)
library(patchwork)
map+(point/bx/income)

 
d$diff<-d$Median.of.total.assessment.value.8.9.10-d$Median.total.family.income.10.11.12
ggplot(data = d, aes(x = reorder(Geography,Median.of.total.assessment.value.8.9.10), y = diff))+
  geom_point()

  theme_classic()
d$Median.of.total.assessment.value.8.9.10<-as.numeric(gsub(",","",d$Median.of.total.assessment.value.8.9.10), na.action = na.omit)
d$Median.total.family.income.10.11.12<-as.numeric(gsub(",","",d$Median.total.family.income.10.11.12), na.action = "omit")