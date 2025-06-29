
###load model###
library(devtools)
library(opencv)
library(psych)
library(MASS)
library(sampling)
library(dplyr)
library(magick)
library(image.libfacedetection)
library(xgboost)

##START HERE
######sample code
#################################
viewer <- getOption("viewer")
which_sex<-c("남자")
name<- "sample"
CamDir <- "DIRECTORY" # Set directory for your image

# Live face detection:
# ocv_video(ocv_face): Use this code to comfirm opencv has access to your built in camera
test <- ocv_picture()
print(test)
bitmap <- ocv_bitmap(test)
live_face <- image_read(bitmap)
image_write(live_face, path = paste0(CamDir,name,".jpg"), format = "jpg")


face_label<- c("정과","기과","신과","혈과")
Camlist <- grep("sample.jpg",list.files(CamDir), value = TRUE)
cam <- 1

################################
### face detect sample image ###
cam_face<-image_read(paste0(CamDir,Camlist[cam]))
cam_detect <- image_detect_faces(cam_face)
plot(cam_detect, cam_face, border = "red", lwd = 7, col = "white")
image_write(plot(cam_detect, cam_face, border = "red", lwd = 7, col = "white"), path = paste0(CamDir,name,"face_detect.jpg"), format = "jpg")
viewer(paste0(CamDir,name,"face_detect.jpg"))
################################

face_result<- c()
my_face<-c()
for (cam in 1:length(Camlist)){
  
  cam_face<-image_read(paste0(CamDir,Camlist[cam]))
  cam_detect <- image_detect_faces(cam_face)
  cam_tmp1<- cam_detect[[2]]
  cam_tmp1<- cam_tmp1[which.max(cam_tmp1$confidence),]
  cam_tmp1$ratio_hw<-cam_tmp1$height/cam_tmp1$width
  cam_tmp1$d<-sqrt(((cam_tmp1$width)/2)^2+((cam_tmp1$height)/2)^2)
  cam_tmp1$r<-(cam_tmp1$height)/2
  cam_tmp1$ratio_dr<-cam_tmp1$d/cam_tmp1$r
  cam_tmp1$id<- Camlist[cam]
  
  #estimate face area
  cam_ori<- ocv_read(paste0(CamDir,Camlist[cam]))
  cammask <- ocv_facemask(cam_ori)
  face_radius <- as.numeric(unlist(attr(cammask, 'faces')[1,1]))
  
  cam_tmp1$face_origin<- (3.14)*(face_radius)^2
  
  cam_tmp1$face_rect <- cam_tmp1$width*(cam_tmp1$height)
  cam_tmp1$face_trep <- (((cam_tmp1$width)+(cam_tmp1$width*0.3))*(cam_tmp1$height))/2
  cam_tmp1$face_circle <- (3.14)*(cam_tmp1$height/2)^2
  cam_tmp1$face_ellipse <- (3.14)*(cam_tmp1$width/2)*(cam_tmp1$height/2)
  
  cam_tmp1$ratio_or <- cam_tmp1$face_rect/cam_tmp1$face_origin
  cam_tmp1$ratio_ot <- cam_tmp1$face_trep/cam_tmp1$face_origin
  cam_tmp1$ratio_oc <- cam_tmp1$face_circle/cam_tmp1$face_origin
  cam_tmp1$ratio_oe <- cam_tmp1$face_ellipse/cam_tmp1$face_origin
  cam_tmp1$sex<- which_sex[cam]
  
  cam_te_dt <- cam_tmp1[,c("ratio_hw","ratio_dr"
                           ,"ratio_or","ratio_ot","ratio_oc","ratio_oe","sex")]
  cam_te_dt$sex <- ifelse(cam_te_dt$sex=="남자",0,1)
  
  
  p <- predict(fit4, newdata = as.matrix(cam_te_dt)) # calculate prediction
  
  
  face_result_tmp <- data.frame(
    # id=Camlist[cam]
    label=face_label
    ,Probability=p)
  
  my_face_tmp <- face_result_tmp[which.max(face_result_tmp$Probability),]
  
  face_result <- rbind(face_result, face_result_tmp)
  my_face <- rbind(my_face, my_face_tmp)
  
}

face_result<- face_result[order(face_result$Probability, decreasing=T), ]
write.table(face_result, "//Users//seoinjeong//Desktop//face_result.txt")


