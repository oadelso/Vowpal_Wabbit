library(ROCR)
library(tidyverse)
library(grid)
library(gridExtra)

#code start
training_predictions=read.table("training_predictions_v2.txt")
colnames(training_predictions)=c('pred','label')
training_predictions$boolean=ifelse(training_predictions$label=="Trump",1,0)
pred=prediction(training_predictions$pred,training_predictions$boolean)
perf_train=performance(pred,"tpr","fpr")
auc=performance(pred,"auc")
t_auc=unlist(slot(auc,"y.values"))
t_auc
training_predictions$rounded=round(training_predictions$pred*2,1)/2
hit_rate=training_predictions %>% group_by(rounded)%>%summarise(hit=mean(boolean),size=n(),probability=mean(pred))

p1=ggplot(hit_rate,aes(x=probability,y=rounded))+
  geom_abline(intercept=0,slope=1,linetype="dotted")+
  geom_point(aes(size=size))+
  labs(x="Hit Rate Model",y="Hit Rate Empirical")+
  ggtitle("Calibration Graph [Training]")

#test data
test_predictions=read.table("test_predictions_v2.txt")
colnames(test_predictions)=c('pred','label')
test_predictions$boolean=ifelse(test_predictions$label=="Trump",1,0)
pred=prediction(test_predictions$pred,test_predictions$boolean)
perf_test=performance(pred,"tpr","fpr")
auc=performance(pred,"auc")
t_auc=unlist(slot(auc,"y.values"))
t_auc

test_predictions$rounded=round(test_predictions$pred*2,1)/2
hit_rate_test=test_predictions %>% group_by(rounded)%>%summarise(hit=mean(boolean),size=n(),probability=mean(pred))

p3=ggplot(hit_rate_test,aes(x=probability,y=rounded))+
  geom_point(aes(size=size))+
  geom_abline(intercept=0,slope=1,linetype="dotted")+
  labs(x="Hit Rate Model",y="Hit Rate Empirical")+
  ggtitle("Calibration Graph [Test]")

#graph the Calibration Curves
grid.arrange(p1,p3, ncol=2,nrow=1)

#graph the ROC Curves
plot(perf_train, col='red', main="ROC Curves - Final Model")
plot(perf_test,add=TRUE,colorsize=TRUE, col='blue')
