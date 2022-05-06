library(rgl)

#multi-colour triangle
for (i in 1:100){
  triangles3d(cbind(rnorm(6), rnorm(6), rnorm(6)), col = "green") # x = numeric vector, y = numeric vector#each triangl is
  triangles3d(cbind(rnorm(9), rnorm(9), rnorm(9)), col = "red") # x
  triangles3d(cbind(rnorm(9), rnorm(9), rnorm(9)), col = "black") # x = numeric vector, y = numeric vector
  triangles3d(cbind(rnorm(9), rnorm(9), rnorm(9)), col = "yellow")
}

#triangle ball bounded by box:
c3d <- cube3d(color=rep(rainbow(6), each = 4), alpha = 0.5)

c3d$vb<-c3d$vb*5
for (i in 1:6){
  lines3d(t(c3d$vb)[c3d$ib[,i],], col = "black")
}

c3d$vb<-c3d$vb/5

for (i in 1:400){
  triangles3d(cbind(rnorm(6), rnorm(6), rnorm(6)), col = "cadetblue") # x = numeric vector, y = numeric vector#each triangl is
  #triangles3d(cbind(rnorm(6/2), rnorm(6/2), rnorm(6/2)), col = "darkgoldenrod", alpha = 1) # x = numeric vector, y = numeric vector#each triangl is
  
  
}