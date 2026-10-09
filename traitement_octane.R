essence <- data.frame(
  x1 = c(0, 0, 0, 0, 0, 0, 0.17, 0.17, 0.17, 0.17, 0.21, 0),
  x2 = c(0.23, 0.10, 0.00, 0.49, 0, 0.62, 0.27, 0.19, 0.21, 0.15, 0.36, 0),
  x3 = c(0, 0, 0, 0, 0, 0, 0.10, 0.10, 0.10, 0.10, 0.12, 0),
  x4 = c(0, 0, 0.10, 0, 0.62, 0, 0.38, 0.38, 0.38, 0.38, 0.25, 0.55),
  x5 = c(0, 0.12, 0.12, 0.12, 0.12, 0, 0, 0.02, 0, 0.02, 0, 0),
  x6 = c(0.74, 0.74, 0.74, 0.37, 0.18, 0.37, 0, 0.06, 0.06, 0.10, 0, 0.37),
  x7 = c(0.03, 0.04, 0.04, 0.02, 0.08, 0.01, 0.08, 0.08, 0.08, 0.08, 0.06, 0.08),
  y  = c(98.7, 97.8, 96.6, 92.0, 86.6, 91.2, 81.9, 83.1, 82.4, 83.2, 81.4, 88.1)
)
 
write.csv(essence, "octane_model.csv", row.names = FALSE)

essence <- read.csv("octane_model.csv") 


summary(essence)

modele <- lm(y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7, data = essence)
summary(modele)

y_pred_complet <- predict(modele, essence) # Calcul du RMSEP 
rmsep <- sqrt(mean((essence$y - y_pred_complet)^2)) 
rmsep

library(FactoMineR)
acp = PCA(essence[,-8], scale=TRUE, graph = FALSE) #-8 : sans la variable y
print(acp$eig)

modele2 <- lm(y ~ x1 + x2 + x3 + x4 + x5 + x6, data = essence)
library(car)
vif(modele2)

library(MASS)
m_aic=stepAIC(modele, trace=0) # pas d'affichage du processus de selection
summary(m_aic)

y_pred <- predict(m_aic, essence) # Calcul du RMSEP 
rmsep_stepAIC <- sqrt(mean((essence$y - y_pred)^2)) 
rmsep_stepAIC

install.packages("pls")
library(pls)
m_pcr=pcr(y~., scale=TRUE, validation="LOO", jackknife = TRUE, data=essence)
plot(m_pcr,"validation", estimate = c("train", "CV"), legendpos = "topright")

summary(m_pcr)

# Graphique Observé vs Prédit avec 4 composantes
obsfit <- predplot(m_pcr, ncomp = 4, which = "validation",
                   asp = 1, line = TRUE,
                   main = "Predicted vs Observed (4 composantes)")

# Ajouter les points en rouge
points(obsfit, pch = 16, col = "red")


coefplot(m_pcr, ncomp=4, se.whiskers = TRUE, labels = prednames(m_pcr), cex.axis = 0.5)

jack.test(m_pcr, ncomp=4)

# Coefficients sur variables réduites
coef_reduced <- coef(m_pcr, ncomp=4, intercept=TRUE)
coef_reduced

# Extraire les coefficients du modèle PCR (variables réduites)
coef_reduced <- as.vector(coef(m_pcr, ncomp = 4, intercept = TRUE))

# Calcul des écarts-types et moyennes des variables explicatives (x1 à x7)
sds <- apply(essence[, 1:7], 2, sd)
means <- apply(essence[, 1:7], 2, mean)

# Ajustement des coefficients pour revenir aux variables originales
coef_original <- coef_reduced
coef_original[2:8] <- coef_reduced[2:8] / sds

# Ajustement de l'intercept
intercept_adj <- coef_reduced[1] - sum(means * (coef_reduced[2:8] / sds))
coef_original[1] <- intercept_adj

# Résultat final : intercept + coefficients sur variables originales
coef_original

# Exemple d'une nouvelle observation
test_data <- data.frame(
  x1 = 0.15,
  x2 = 0.30,
  x3 = 0.05,
  x4 = 0.40,
  x5 = 0.10,
  x6 = 0.20,
  x7 = 0.05
)

# Prédiction avec le modèle PCR (4 composantes)
predict(m_pcr, ncomp = 4, newdata = test_data)

#Régression PLS
m_pls=plsr(y~., scale=TRUE, validation="LOO", jackknife = TRUE, data=essence)
summary(m_pls)

# Graphique Observé vs Prédit avec 3 composantes
predplot(m_pls, ncomp = 3, which = "validation",
         asp = 1, line = TRUE,
         main = "Predicted vs Observed (PLS, 3 composantes)")

# Coefficients avec 3 composantes
coef(m_pls, ncomp = 3, intercept = TRUE)

# Test jackknife pour significativité
jack.test(m_pls, ncomp = 3)

# Extraire les coefficients PLS (variables réduites)
coef_reduced <- as.vector(coef(m_pls, ncomp = 3, intercept = TRUE))

# Calcul des écarts-types et moyennes des variables explicatives
sds <- apply(essence[, 1:7], 2, sd)
means <- apply(essence[, 1:7], 2, mean)

# Ajustement des coefficients pour revenir aux variables originales
coef_original <- coef_reduced
coef_original[2:8] <- coef_reduced[2:8] / sds

# Ajustement de l'intercept
intercept_adj <- coef_reduced[1] - sum(means * (coef_reduced[2:8] / sds))
coef_original[1] <- intercept_adj

# Résultat final : intercept + coefficients sur variables originales
coef_original


library(glmnet)

# Préparation des données
X <- as.matrix(essence[,1:7])
y <- essence$y

# Régression Ridge (alpha=0)
m_ridge <- glmnet(X, y, alpha = 0)

# Visualiser les coefficients en fonction de lambda
plot(m_ridge, xvar = "lambda")

cv_ridge <- cv.glmnet(X, y, alpha = 0)

# Lambda optimal
lambda_opt <- cv_ridge$lambda.min

# RMSEP associé
rmsep_ridge <- sqrt(mean((y - predict(cv_ridge, s=lambda_opt, newx=X))^2))
rmsep_ridge

#Les coefficients du modèle Ridge optimal
coef_ridge <- coef(cv_ridge, s = "lambda.min")
coef_ridge


# Régression Lasso (alpha=1) 
m_lasso <- glmnet(X, y, alpha = 1) 
# Visualiser les coefficients en fonction de lambda 
plot(m_lasso, xvar = "lambda")

cv_lasso <- cv.glmnet(X, y, alpha = 1)

# Lambda optimal
lambda_opt_lasso <- cv_lasso$lambda.min
lambda_opt_lasso

# RMSEP associé
rmsep_lasso <- sqrt(mean((y - predict(cv_lasso, s=lambda_opt_lasso, newx=X))^2))
rmsep_lasso

coef_lasso <- coef(cv_lasso, s = "lambda.min")
coef_lasso

