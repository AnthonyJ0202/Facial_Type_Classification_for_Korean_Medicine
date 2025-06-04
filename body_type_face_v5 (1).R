setwd('C:/Users/82105/OneDrive/바탕 화면/pose_estimation')
rm(list = ls())

library(magick)
library(image.libfacedetection)

dir = './'
pic_list <- grep(".png",list.files(path=dir), value = T)
pic_list <- pic_list[order(pic_list)]
anal_dt <- data.frame()

for(p in c(1:length(pic_list))){
  image0 <- image_read(pic_list[p])
  image<-image_crop(image0,geometry_area(400,300,150,100))
  faces <- image_detect_faces(image)
  temp <- data.frame(faces$detections)
  temp_dt <- temp[temp$confidence>=50,]
  
  if(nrow(temp_dt)==0){
    anal_dt <- rbind(anal_dt, temp_dt)
  }else{
    temp_dt <- temp_dt[1,]
    pic_dt <- data.frame(pic_num = pic_list[p])
    temp_dt <- cbind(temp_dt,pic_dt)
    anal_dt <- rbind(anal_dt, temp_dt)
  }
  
}

if(nrow(anal_dt)<=1){
  print(11)
  result <- 11
}else{
  
  before <- anal_dt[1,]
  after <- anal_dt[nrow(anal_dt),]
  loc_before<-c(mean(as.numeric(before[,c(6,8,10,12,14)]))
                ,mean(as.numeric(before[,c(7,9,11,13,15)])))
  
  loc_after<-c(mean(as.numeric(after[,c(6,8,10,12,14)]))
               ,mean(as.numeric(after[,c(7,9,11,13,15)])))
  
  if(loc_before[1]>loc_after[1]){
    loc_x_diff <- ceiling(loc_after[1]-loc_before[1])
    
  }else{
    loc_x_diff <- floor(loc_after[1]-loc_before[1])
  }
  
  if(loc_before[2]>loc_after[2]){
    loc_y_diff<-ceiling(loc_after[2]-loc_before[2])
  }else{
    loc_y_diff <- floor(loc_after[2]-loc_before[2])
  }
  
  abs_loc_x_diff <- abs(loc_x_diff)
  abs_loc_y_diff <- abs(loc_y_diff)
  
  
  #정상:1, 정향형:2, 후향형:3, 좌형:4, 좌향형:5, 좌후형:6, 우형:7, 우향형:8, 우후형:9, 운동불가:10, 판단불가:11(앉은상태, 사진이 한장 혹은 없는 경우)
  result <- if(abs_loc_x_diff<=5 & abs_loc_y_diff<=5){
    1
  }else if(abs_loc_x_diff<=5 & loc_y_diff> 5){
    2
  }else if(abs_loc_x_diff<=5 & loc_y_diff< (-5)){
    3
  }else if(loc_x_diff>5 & abs_loc_y_diff<=5){
    4
  }else if(loc_x_diff>5 & loc_y_diff>5){
    5
  }else if(loc_x_diff>5 & loc_y_diff< -5){
    6
  }else if(loc_x_diff<-5 & abs_loc_y_diff<=5){
    7
  }else if(loc_x_diff<-5 & loc_y_diff>5){
    8
  }else if(loc_x_diff<-5 & loc_y_diff< -5){
    9
  }else{11}
  
}

cat(result, file = "result.txt")


