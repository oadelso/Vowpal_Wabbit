library(ROCR)
library(tidyverse)
library(grid)
library(gridExtra)

#code start
training_predictions=read.table("training_predictions.txt")
colnames(training_predictions)=c('pred','label')
training_predictions$boolean=ifelse(training_predictions$label=="Trump",1,0)
pred=prediction(training_predictions$pred,training_predictions$boolean)
perf=performance(pred,"tpr","fpr")
p0=plot(perf)
auc=performance(pred,"auc")
t_auc=unlist(slot(auc,"y.values"))
t_auc
training_predictions$rounded=round(training_predictions$pred*2,1)/2
hit_rate=training_predictions %>% group_by(rounded)%>%summarise(hit=mean(boolean),size=n(),probability=mean(pred))

p1=ggplot(hit_rate,aes(x=probability,y=rounded))+
  geom_abline(intercept=0,slope=1,linetype="dotted")+
  labs(tite="Train Calibration", x="Hit Rate Model",y="Hit Rate Actual")

#test data
test_predictions=read.table("test_predictions.txt")
colnames(test_predictions)=c('pred','label')
test_predictions$boolean=ifelse(test_predictions$label=="Trump",1,0)
pred=prediction(test_predictions$pred,test_predictions$boolean)
perf=performance(pred,"tpr","fpr")
p2=plot(perf)
auc=performance(pred,"auc")
t_auc=unlist(slot(auc,"y.values"))
t_auc

test_predictions$rounded=round(test_predictions$pred*2,1)/2
hit_rate_test=test_predictions %>% group_by(rounded)%>%summarise(hit=mean(boolean),size=n(),probability=mean(pred))

p3=ggplot(hit_rate_test,aes(x=probability,y=rounded))+
  geom_point(aes(size=size))+
  geom_abline(intercept=0,slope=1,linetype="dotted")+
  labs(tite="Test Calibration", x="Hit Rate Model",y="Hit Rate Actual")

grid.arrange(p1,p3, ncol=2,nrow=1)