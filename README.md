# 📊 Modélisation de l'Indice d'Octane Moteur en R

Ce dépôt contient un projet d'analyse statistique complet visant à modéliser et prédire l'indice d'octane moteur de l'essence en fonction de son processus de fabrication. 

Face à une forte problématique de **multicolinéarité** détectée par l'Analyse en Composantes Principales (ACP) et le calcul des facteurs d'inflation de la variance (VIF), plusieurs approches de régression avancées ont été implémentées et comparées.

## 📁 Contenu du Projet
*   `traitement_octane.R` : Le script R complet contenant l'ensemble des analyses et modèles.
*   `octane_model.csv` : Le jeu de données utilisé pour l'étude.
*   `Rapport_SD.pdf` : Le rapport d'analyse détaillé mis en page.

📄 **[Télécharger et lire le rapport complet au format PDF](Rapport_SD.pdf)**

## 🧪 Modèles Implémentés & Comparaison
Pour optimiser le pouvoir prédictif et gérer la redondance des variables, les méthodes suivantes ont été évaluées par validation croisée (Leave-One-Out) :

| Méthode de Régression | Paramètres Optimaux | Performance (RMSEP) | Stratégie / Résultat |
| :--- | :--- | :--- | :--- |
| **Lasso** | λ ≈ 0.085 | **~0.57** | **Meilleur modèle** (Sélectionne 4 variables clés : x1, x4, x5, x6) |
| **Ridge** | λ ≈ 8 | ~0.68 | Conserve toutes les variables en réduisant leurs amplitudes |
| **PLS** | 3 composantes | ~1.30 | Réduction dimensionnelle supervisée (variables clés : x6, x4) |
| **PCR** | 4 composantes | ~1.31 | Réduction dimensionnelle non supervisée via ACP |

Le modèle **Lasso** offre ici le compromis idéal entre la performance prédictive (erreur la plus faible) et la parcimonie (modèle simplifié et robuste).

## 🛠️ Dépendances R
Pour exécuter le script, assurez-vous d'avoir installé les packages suivants :
```R
install.packages(c("pls", "glmnet", "MASS", "car", "FactoMineR"))
```
