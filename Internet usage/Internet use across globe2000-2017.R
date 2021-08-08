library("ggplot2")
theme_set(theme_bw())
library("sf")

library("rnaturalearth")
library("rnaturalearthdata")


#create the world map
world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

ggplot(data = world) +
  geom_sf()

ggplot(data = world) + 
  geom_sf(color = "black", fill = "lightgreen")

#play with the data that comes with the dataset
ggplot(data = world) +
  geom_sf(aes(fill = economy)) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")

ggplot(data = world) +
  geom_sf(aes(fill = region_wb)) 

ggplot(data = world) +
  geom_sf(aes(fill = income_grp)) 


#add internet data
internet<-read.csv(file.choose())

unique(world$name_long)
unique(internet$X)


#find names that are different
setdiff(world$name_long,internet$X)#names in world dataset that weren't matched

setdiff(internet$X,world$name_long)#names in internet dataset that weren't matched

match(world$name_long,internet$X)
match(internet$X,world$name_long)
  

world$name_long

#put name diffs in excell file and match the names from the internet fil
#$to the world dataset
internet$X2<-gsub("Bolivia (Plurin. State of)","Bolivia",internet$X)
internet$X2<-gsub("Cabo Verde","Cape Verde",internet$X2)
internet$X2<-gsub("Congo","Republic of Congo",internet$X2)
internet$X2<-gsub("CÃ´te dâ???TIvoire","Côte d'Ivoire",internet$X2)
internet$X2<-gsub("Dem. Rep. of the Congo","Democratic Republic of the Congo",internet$X2)
internet$X2<-gsub("Falkland Islands (Malvinas)","Falkland Islands",internet$X2)
internet$X2<-gsub("Iran (Islamic Republic of)","Iran",internet$X2)
internet$X2<-gsub("Republic of Moldova","Moldova",internet$X2)
internet$X2<-gsub("State of Palestine","Palestine",internet$X2)
internet$X2<-gsub("Syrian Arab Republic","Syria",internet$X2)
internet$X2<-gsub("United Rep. of Tanzania","Tanzania",internet$X2)
internet$X2<-gsub("United States of America","United States",internet$X2)
internet$X2<-gsub("Venezuela (Boliv. Rep. of)","Venezuela",internet$X2)
internet$X2<-gsub("Viet Nam","Vietnam",internet$X2)


#rename 'Values' to 'Percent'
names(internet)[5]<-"Percent"
splt_year<-split(internet,internet$Year)
  

#missing values:
addinternet$name_long[which(is.na(addinternet$Value))]


#plot for different years
runplot<-function(i){
# LEFT JOIN
addinternet <- left_join(world, splt_year[[i]], by = c('name_long' = 'X2'), copy = T)

a<-ggplot(data = addinternet)+
  geom_sf(aes(fill = Percent), col = "black")+
  scale_fill_viridis_c(option = "plasma")+
  
  #xlab("Longitude") + ylab("Latitude") +
  ggtitle(paste0("Percentage of citizens using internet in ", expression(splt_year[[i]]$Year)),
          subtitle = "Source: https://data.un.org/default.aspx (under Communication-->Internet Usage)")

a
}
runplot(1)+
runplot(2)+
runplot(3)+
runplot(4)+
runplot(5)+
runplot(6)

expression('No. of'~italic(bacteria X)~'isolates with corresponding types')


###################MAKE GIF

for(x in 1:7){
ggsave(filename = paste0("internetyear_",x,".png"),runplot(x))
       #width = 8.5, height = 4, units = "cm")
}

library(magick)
library(magrittr)

list.files(path='C:/Users/jeffz/Documents/worldinternet animation/', pattern = '*.png', full.names = TRUE) %>% 
  image_read() %>% # reads each path file
  image_join() %>% # joins image
  image_animate(fps=0.5) %>% # animates, can opt for number of loops
  image_write("FileName.gif") # write to current dir



