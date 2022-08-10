dataset=read.csv("crime.csv")
head(dataset)

newData=dataset[,-c(1,2)]  # col 1,2 = States, Regions 把類別變數刪掉
rownames(newData)=dataset[,1]  rowname 設 States

##Case 1. Hierarchical Clustering
E.dist <- dist(newData, method="euclidean") # Euclidean distance
M.dist <- dist(newData, method="manhattan") # Manhattan distance

dev.new()
par(mfrow=c(1,2)) 
# Apply Euclidean distance to grouping work
h.E.cluster <- hclust(E.dist)
plot(h.E.cluster, xlab="Euclidean distance")  # plot 樹狀圖

# Apply Manhattan distance to grouping work
h.M.cluster <- hclust(M.dist) 
plot(h.M.cluster, xlab="Manhattan")
par(mfrow=c(1,1))

## We have many clustering methods 歸群連結法
hclust(E.dist, method="single")   # 最近法
hclust(E.dist, method="complete") # 最遠法
hclust(E.dist, method="average")  # 平均法
hclust(E.dist, method="centroid") # 中心法
hclust(E.dist, method="ward.D2")  # 華德法

# Use Euclidean distance to Ward method to Hier Cluster：歐式距離搭配 ward method
E.dist <- dist(newData, method="euclidean")      # 歐式距離
h.cluster <- hclust(E.dist, method="ward.D2") # 華德法
dev.new()
plot(h.cluster)
abline(h=2000, col="red")  # 切在這裡代表分4群K=4 可自行決定要切在哪

#Acording to the plot above, the best number of groups is 4.
#Hence, we use cutree() to shrink the structure into 4

cut.h.cluster <- cutree(h.cluster, k=4)  # Grouping states into 4 clusters
cut.h.cluster                            # Result 看每個州分到1~4哪一群
#a <- as.data.frame(cut.h.cluster)       # 用成dataframe格式
table(cut.h.cluster, dataset[,2]) #Check if crime pattern has geographical shape；dataset[,2] 是region，看4個集群和region的關係

##Case 2. Partitional Clustering 切割式分群(K-Means, K-Medoid)
# Method 1. kmeans
kmeans.cluster <- kmeans(newData, centers=4)   # 分4群

# variacne of withinss
kmeans.cluster$withinss  # 4群各自的variance

#Check if crime pattern has geographical shape
table(kmeans.cluster$cluster, dataset[,2])  # dataset[,2] 是region，看4個集群和region的關係

# Visualize k-meansresults(ggplot2)
require(factoextra)
fviz_cluster(kmeans.cluster,           # results
             data = newData,           # raw data
             geom = c("point","text"), # point & label
             frame.type = "norm")      # type of frame

# Method 2. K-Medoid needs function pam(), which is in package cluster 使用K-Mediods演算法時，
                                                                      #中心點將選選擇群內某個觀測值，而非群內平均值，
                                                                      #就像中位數一樣，較不易受離群值所影響。是K-Means更強大的版本。
require(cluster)

# pam = Partitioning Around Medoids ##K-Medoids最常使用的演算法為PAM(Partitioning Around Medoid, 分割環繞物件法）
kmedoid.cluster <- pam(newData, k=4) 

# variacne of withinss
kmedoid.cluster$objective

# Check if crime pattern has geographical shape
table(kmedoid.cluster$clustering, dataset[,2]) 

# Visualize k-Medoid results(ggplot2)
require(factoextra)
fviz_cluster(kmedoid.cluster,       # results
             data = newData,        # raw data
             geom = c("point","text"),     # point
             frame.type = "norm")   # type of frame

