rm(list = ls(all = TRUE))
# please install these packages if necessary
# install.packages("fGarch")
# install.packages("QRM")
# install.packages("copula")
library(fGarch)
library(QRM)
library(copula)
#setwd("C:/...") # please change your working directory
file.name   = "COPapp1residual.csv"
main.names  = as.matrix(read.csv(file.name, header = FALSE))
X           = read.csv(file.name, header = FALSE) # read data set
rownames(X) = X[, 1]
R           = apply(log(X[, -1]), 2, diff) # compute log-returns
X           = X[, -1]
where.put   = which(diff(as.numeric(format(as.Date(rownames(X), "%d.%m.%Y"), 
                                           "%Y%m"))) != 0)
labels      = format(as.Date(rownames(X), "%d.%m.%Y"), "%b %Y")
eps         = matrix(nrow = dim(R)[1], ncol = dim(R)[2])
# estimate parameters of an ARMA(1,1)+GARCH(1,1) model
if(exists("params")){rm(params)}
for(i in 1:dim(R)[2]){
  fit = garchFit(~arma(1, 0) + garch(1, 1), data = R[, i], trace = F)
  eps[,i] = fit@residuals / fit@sigma.t # compute the residuals
  if(!exists("params")){params = c(fit@fit$coef, 
                                   "BL" = Box.test(eps[, i],
                                   type = "Ljung-Box", lag = 12)$p.value, 
                                   "KS" = ks.test(eps[, i], "pnorm")$p.value)}
  else {params = rbind(params, c(fit@fit$coef, 
                                 Box.test(eps[, i], type = "Ljung-Box",
                                          lag = 12)$p.value,
                                 ks.test(eps[, i], "pnorm")$p.value))}
  params = rbind(params, c(fit@fit$matcoef[, 2], NA, NA))
}
# do plot
layout(matrix(1:9, nrow=3, ncol=3, byrow = T))

par(mar=c(1, 2, 2, 1))
plot(0, 0, axes = FALSE, frame = TRUE, col = "white", xlab = "", ylab = "")
text(0, 0, "APPL", cex = 2)

par(mar=c(1, 1.5, 2, 1.5), pty="m")
plot(eps[, 2], eps[, 1], pch = 19, xlab = "", ylab = "", axes = F,
     frame = T); axis(3)
	 
par(mar=c(1, 1, 2, 2),pty="m")
plot(eps[,3], eps[,1], pch = 19, xlab = "", ylab = "", axes = F,
     frame = T); axis(3); axis(4)

par(mar=c(1.5, 2, 1.5, 1), pty="m")
plot(edf(eps[, 1], F), edf(eps[, 2], F), pch = 19, xlab = "",
     ylab = "", axes = F, frame = T); axis(2)
	 
par(mar=c(1.5, 1.5, 1.5, 1.5), pty="m")
plot(0, 0, axes = FALSE, frame = TRUE, col = "white", xlab = "",
     ylab = "")
text(0, 0, "HP", cex = 2)

par(mar=c(1.5, 1, 1.5, 2), pty="m")
plot(eps[, 3], eps[, 2], pch = 19, xlab = "", ylab = "", axes = F,
     frame = T); axis(4)

par(mar=c(2, 2, 1, 1), pty="m")
plot(edf(eps[, 1], F), edf(eps[, 3], F), pch = 19, xlab = "", 
     ylab = "", axes = F, frame = T); axis(1); axis(2)
	 
par(mar=c(2, 1.5, 1, 1.5), pty="m")
plot(edf(eps[, 2], F), edf(eps[, 3], F), pch = 19, xlab = "",
     ylab = "", axes = F, frame = T); axis(1)
	 
par(mar=c(2, 1, 1, 2), pty="m")
plot(0, 0, axes = FALSE, frame = TRUE, col = "white", xlab = "",
     ylab = "")
text(0, 0, "MSFT", cex = 2)
