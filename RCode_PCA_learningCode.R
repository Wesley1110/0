dataset=read.csv("C:\\crime.csv") 
head(dataset)

#Figure 1
newData=dataset[,-c(1,2)] 
.PC= princomp(newData ,cor=TRUE)
dev.new()
biplot(.PC)

#Figure 2
rownames(newData)=dataset[,1]  # Establish row ID by rownames 把第一欄的States變成row ID
.PC= princomp(newData ,cor=TRUE)
dev.new();biplot(.PC,cex=0.8) 
abline(h=0,v=0,lty=3,col=("blue"))

plot(.PC, col=c("blue"))
screeplot(.PC, col=c("lightblue"))


summary(.PC, loadings=TRUE)
names(.PC)
.PC$sdev

.PC$scores 
predict(.PC) #Both of them are equal. 

loadings(.PC)
round(unclass(loadings(.PC))[,1:2],4)


## Advanced visualization
library("FactoMineR")
library("factoextra")
fviz_eig(.PC)

#Graph of individuals. Individuals with a similar profile are grouped together.
fviz_pca_ind(.PC,
             col.ind = "cos2", # Color by the quality of representation
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)

#Graph of variables. Positive correlated variables point to the same side of the plot. Negative correlated variables point to opposite sides of the graph.
fviz_pca_var(.PC,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)

#Biplot of individuals and variables
fviz_pca_biplot(.PC, repel = TRUE,
                col.var = "#2E9FDF", # Variables color
                col.ind = "#696969"  # Individuals color
)





