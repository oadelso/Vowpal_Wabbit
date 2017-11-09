'
The following R script calculates AUC values for two sets of data:
1) Training data and 2) test data, corresponding to 80% and 20% of the
formatted trump_data.tsv content, respectively.

In addition, it saves a total of 4 graphs in the working directory:
1) A graph containing the ROC curves for both sets
2) A Calibration graph for the training set
3) A Calibration graph or the test set
4) A graph containing both 2) & 3) in a 2 by 1 grid format
'
##Working directory and removing memory
rm(list = objects())
setwd(dir = getwd())

##Required libraries
#!/usr/bin/Rscript
#install.packages('ROCR')
library(ROCR)
library(tidyverse)
library(data.table)
library(grid)
library(gridExtra)

##Code for the training dataset
#calculation for the AUC
training_predictions=read.table("training_predictions.txt")
colnames(training_predictions)=c('pred', 'label')
training_predictions$boolean=ifelse(training_predictions$label=="Trump", 1, 0)
pred=prediction(training_predictions$pred,training_predictions$boolean)
perf_train=performance(pred, "tpr", "fpr")
auc=performance(pred, "auc")
t_auc_train=unlist(slot(auc, "y.values"))

#build Calibration Plot
#round the predicted probabilities
training_predictions$rounded=round(training_predictions$pred*2, 1) / 2

hit_rate=training_predictions %>% 
  group_by(rounded) %>% 
  summarise(hit=mean(boolean), size=n(), probability=mean(pred))

p1=ggplot(hit_rate, aes(x=probability, y=rounded))+
  geom_abline(intercept=0, slope=1, linetype="dotted")+
  geom_point(aes(size=size))+
  labs(x="Hit Rate Model", y="Hit Rate Empirical")+
  ggtitle("Calibration Graph [Training]")
  ggsave(file="mse231_hw3_calibration_training.pdf", width=8, height=5)

##Code for the test dataset
#Calculation for AUC
test_predictions=read.table("test_predictions.txt")
colnames(test_predictions)=c('pred', 'label')
test_predictions$boolean=ifelse(test_predictions$label=="Trump", 1, 0)
pred=prediction(test_predictions$pred,test_predictions$boolean)
perf_test=performance(pred,"tpr","fpr")
auc=performance(pred,"auc")
t_auc_test=unlist(slot(auc,"y.values"))

#build calibration plot
#round calculated probabilities
test_predictions$rounded=round(test_predictions$pred*2, 1) / 2
hit_rate_test=test_predictions %>% 
  group_by(rounded) %>% 
  summarise(hit=mean(boolean), size=n(), probability=mean(pred))

p3=ggplot(hit_rate_test, aes(x=probability, y=rounded))+
  geom_point(aes(size=size))+
  geom_abline(intercept=0, slope=1, linetype="dotted")+
  labs(x="Hit Rate Model", y="Hit Rate Empirical")+
  ggtitle("Calibration Graph [Test]")
  ggsave(file="mse231_hw3_calibration_test.pdf", width=8, height=5)

##Output
#graph the Calibration Curves
jpeg('Calibration_Plots.jpg')
grid.arrange(p1,p3, ncol=2, nrow=1)
dev.off()
#graph the ROC Curves
jpeg('ROC_Curves.jpg')
plot(perf_train, col='red', main="ROC Curves - Final Model")
plot(perf_test, add=TRUE, colorsize=TRUE, col='blue')
legend(.85,.95, legend=c("Train","Test"), col=c("red","blue"),lty=1:1,cex=0.8)
dev.off()

#print message regarding the values calculated and plots generated
print(paste("AUC value for training predictions is ", t_auc_train))
print(paste("AUC value for test predictions is ", t_auc_test))
print(paste("A total of 4 plots were saved in the Directory:", getwd()))
