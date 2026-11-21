##### libraries ####

x <- c("patchwork","metR","fpp3", "maps","geoR", "gstat", "sp", "sf", "MBA", "caret", "scatterplot3d", "ggplot2", "ade4", "gridExtra", "statmod", "tweedie", "mgcv", "np")
lapply(x, install.packages, character.only = TRUE)
lapply(x, library, character.only = TRUE)



##### load and organize datasets ####

load("shrimpsfull.RData") # Load dataset
load("AllGrids.RData") # Load dataset

# Divide the data set into two years
s97 = shrimpsdata |> filter(ANNO=="1997")
s02 = shrimpsdata |> filter(ANNO =="2002")

#remove useless objects
rm(list = c("shrimpsdata","x", ls(pattern = "^grid_199[5-6]|^grid_199[8-9]|^grid_200[0-1]|^grid_200[3-9]|^grid_2010")))

#remove variables: spawners, recruits, year since they are not useful for analysis
s02 = s02[, -c(3:5)]
s97 = s97[, -c(3:5)]

#spatial objects
s02s = s02
coordinates(s02s) = ~X + Y
s97s = s97
coordinates(s97s) = ~X + Y

#Geo data object with the transformed variable 
s97$log = log(s97$tot + 1)
geo_data_97 <- as.geodata(s97, coords.col = 1:2, data.col = "log", covar.col = 3:25)

s02$log = log(s02$tot + 1)
geo_data_02 <- as.geodata(s02, coords.col = 1:2, data.col = "log", covar.col = 3:25)

##### plot coordinates, total biomass, 1997, 2002 ####

plot1 = ggplot(data = s97) +
  geom_point(aes(x = X, y = Y, color = tot)) +
  scale_color_gradient(low = "yellow", high = "black") +  
  theme_minimal() +
  ggtitle("Year 1997, coordinates and biomass") +
  labs(color = "Total biomass") +
  theme(
    panel.background = element_rect(fill = "lightblue", colour = NA),  # Sfondo del pannello
    plot.background = element_rect(fill = "gray90", colour = NA)      # Sfondo complessivo
  )

plot2=ggplot(data=s02) +
  geom_point(aes(x = X, y = Y, color = tot)) +
  scale_color_gradient(low = "yellow", high = "black") + 
  theme_minimal() +
  ggtitle("Year 2002, coordinates and biomass")+
  labs(color = "Total biomass")+
  theme(
    panel.background = element_rect(fill = "lightblue", colour = NA),  # Sfondo del pannello
    plot.background = element_rect(fill = "gray90", colour = NA)      # Sfondo complessivo
  )

grid.arrange(plot1, plot2, ncol = 1)

##### Histogram of biomass ####
# Istogramma per s02$tot
hist_tot_s02 <- ggplot(s02, aes(x = tot)) +
  geom_histogram(binwidth = 10, fill = "steelblue", color = "white") +
  ggtitle("Distribuzione di tot (s02)") +
  xlab("Total biomass (s02)") +
  ylab("Frequency") +
  theme_minimal()

# Istogramma per s97$tot
hist_tot_s97 <- ggplot(s97, aes(x = tot)) +
  geom_histogram(binwidth = 10, fill = "darkorange", color = "white") +
  ggtitle("Distribuzione di tot (s97)") +
  xlab("Total biomass (s97)") +
  ylab("Frequency") +
  theme_minimal()

# Istogramma per s02$log
hist_log_s02 <- ggplot(s02, aes(x = log)) +
  geom_histogram(binwidth = 0.5, fill = "forestgreen", color = "white") +
  ggtitle("Distribuzione di log (s02)") +
  xlab("Log biomass (s02)") +
  ylab("Frequency") +
  theme_minimal()

# Istogramma per s97$log
hist_log_s97 <- ggplot(s97, aes(x = log)) +
  geom_histogram(binwidth = 0.5, fill = "purple", color = "white") +
  ggtitle("Distribuzione di log (s97)") +
  xlab("Log biomass (s97)") +
  ylab("Frequency") +
  theme_minimal()

# Visualizzazione dei grafici (ad esempio con patchwork per combinarli)
(hist_tot_s02 | hist_tot_s97) / (hist_log_s02 | hist_log_s97)

##### normality test ####

# Esegui il test di Shapiro-Wilk
pvalue=shapiro.test(s02$log[s02$log > 0])

#Risultato:
 # Un p-value > 0.05 indica che i dati seguono una distribuzione normale.
 # Un p-value ≤ 0.05 indica che i dati non sono normalmente distribuiti.

pvalue$p.value> 0.05

##### tweedie ####

hist(s97$log, freq = FALSE, main = "Distribuzione campionaria", col = "lightblue")
lines(density(s97$log), col = "red", lwd = 2)

# Esempio: Adatta una distribuzione Tweedie ai dati
fit_97 <- tweedie.profile(s97$log ~ 1, p.vec =seq(1.0, 2.0, by = 0.01))
fit_02 <- tweedie.profile(s02$log ~ 1, p.vec =seq(1.0, 2.0, by = 0.01))

fit_97$p.max
fit_97$phi.max

# Simula dati da una distribuzione Tweedie
sim_data_97 <- rtweedie(n = length(s97$log), mu = mean(s97$log), phi = fit_97$phi.max, power = fit_97$p.max)
sim_data_02 <- rtweedie(n = length(s02$log), mu = mean(s02$log), phi = fit_02$phi.max, power = fit_02$p.max)


par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))

# Confronta le densità
hist(s97$log, freq = FALSE, main = "Confronto Dati vs Tweedie", col = "lightblue")
lines(density(sim_data_97), col = "blue", lwd = 2)
lines(density(s97$log), col = "red", lwd = 2)
legend("topright", legend = c("Campionaria", "Tweedie"), col = c("red", "blue"), lwd = 2)

hist(s02$log, freq = FALSE, main = "Confronto Dati vs Tweedie", col = "lightblue")
lines(density(sim_data_02), col = "blue", lwd = 2)
lines(density(s02$log), col = "red", lwd = 2)
legend("topright", legend = c("Campionaria", "Tweedie"), col = c("red", "blue"), lwd = 2)

# Calcola i quantili teorici
prob_97 <- ppoints(length(sim_data_97))  # Probabilità per i quantili
quant_theoretical_97 <- qtweedie(prob, mu = mean(s97$log), phi = fit_97$phi.max, power = fit_97$p.max)

# QQ-plot
qqplot(quant_theoretical_97, sort(sim_data_97), main = "QQ-plot Tweedie",
       xlab = "Quantili teorici Tweedie", ylab = "Quantili campionari 1997")
abline(0, 1, col = "red", lwd = 2)  # Linea di riferimento

# Calcola i quantili teorici
prob_02 <- ppoints(length(sim_data_02))  # Probabilità per i quantili
quant_theoretical_02 <- qtweedie(prob, mu = mean(s02$log), phi = fit_02$phi.max, power = fit_02$p.max)

# QQ-plot
qqplot(quant_theoretical_02, sort(sim_data_02), main = "QQ-plot Tweedie",
       xlab = "Quantili teorici Tweedie", ylab = "Quantili campionari 2002")
abline(0, 1, col = "red", lwd = 2)  # Linea di riferimento

##### PCA ####

#compute the PCA for each year, without considering the variables "anno", "spawners", "recruits",
#selecting the first three PC
pca97=dudi.pca(df = s97[,-26], scannf = FALSE, nf = 3)
pca02=dudi.pca(df = s02[,-26], scannf = FALSE, nf = 3)


#plot of the PCA output
scatter(pca97, clab.row = 0.1, clab.col = 0.9)
scatter(pca02, clab.row = 0.1)

# Scatter plot PCA
fviz_pca_ind(pca97, 
             geom = "point",         # Mostra i punti
             pointsize = 3,          # Dimensione dei punti
             col.ind = "cos2",       # Colora i punti in base al coseno quadrato
             gradient.cols = c("blue", "green", "red"), # Scala colori
             repel = TRUE)           # Evita sovrapposizioni delle etichette

fviz_pca_var(pca97, 
             col.var = "contrib",    # Colora le variabili in base al contributo
             gradient.cols = c("blue", "orange", "red"),
             repel = TRUE)

##### correlation ####
# Calcolare la matrice di correlazione tra variabili
cor_matrix_97 <- cor(s97[,-26], method = "spearman")
cor_matrix_02 <- cor(s02[,-26], method = "spearman")

#La correlazione di Spearman misura la forza e la direzione della relazione monotona tra due variabili 
#ordinali o continue. 
#In altre parole, analizza se, all'aumentare di una variabile, l'altra tende a crescere (correlazione positiva) 
#o decrescere (correlazione negativa).

#Quando usare Spearman:
 # Quando i dati non seguono una distribuzione normale.
 # Quando la relazione tra le variabili non è necessariamente lineare, ma monotona.

print(cor_matrix_97)
print(cor_matrix_02)

corrplot(cor_matrix_97, 
         method = "square",              # Usa il metodo "square"
         type = "upper",                 # Mostra solo la parte superiore della matrice (per evitare duplicati)
         tl.col = "black",               # Colore delle etichette delle variabili
         tl.srt = 45,                    # Angolo di rotazione delle etichette (45° per una migliore leggibilità)
         addCoef.col = "white",          # Aggiungi i valori della correlazione in bianco
         number.cex = 0.8,               # Dimensione dei numeri
         col = colorRampPalette(c("blue", "white", "red"))(200),  # Colori blu-bianco-rosso per una migliore distinzione
         diag = FALSE,                   # Non visualizzare i valori sulla diagonale
         title = "Matrice di Correlazione",  # Titolo
         mar = c(0, 0, 1, 0)             # Margini per il titolo
)

corrplot(cor_matrix_02, 
         method = "square",              # Usa il metodo "square"
         type = "upper",                 # Mostra solo la parte superiore della matrice (per evitare duplicati)
         tl.col = "black",               # Colore delle etichette delle variabili
         tl.srt = 45,                    # Angolo di rotazione delle etichette (45° per una migliore leggibilità)
         addCoef.col = "white",          # Aggiungi i valori della correlazione in bianco
         number.cex = 0.8,               # Dimensione dei numeri
         col = colorRampPalette(c("blue", "white", "red"))(200),  # Colori blu-bianco-rosso per una migliore distinzione
         diag = FALSE,                   # Non visualizzare i valori sulla diagonale
         title = "Matrice di Correlazione",  # Titolo
         mar = c(0, 0, 1, 0)             # Margini per il titolo
)

##### plot dist, slope, tot, bat ####

# First plot
plot1 = ggplot(data = s97) +
  geom_point(aes(x = dist, y = slope, color = log)) +
  scale_color_gradient(low = "red", high = "green") +  # Change color scale from red to green
  theme_minimal() +
  ggtitle("Year 1997, distance and slope") +
  labs(color = "Total biomass") +
  theme(
    plot.background = element_rect(fill = "lightgrey"),  # Set background to light grey
    panel.background = element_rect(fill = "lightyellow") # Set rectangular wallpaper (panel background)
  )

# Second plot
plot2 = ggplot(data = s97) +
  geom_point(aes(x = bat, y = slope, color = log)) +
  scale_color_gradient(low = "red", high = "green") +  # Change color scale from red to green
  theme_minimal() +
  ggtitle("Year 1997, bathymetry and slope") +
  labs(color = "Total biomass") +
  theme(
    plot.background = element_rect(fill = "lightgrey"),  # Set background to light grey
    panel.background = element_rect(fill = "lightyellow") # Set rectangular wallpaper (panel background)
  )

# Third plot
plot3 = ggplot(data = s02) +
  geom_point(aes(x = dist, y = slope, color = log)) +
  scale_color_gradient(low = "red", high = "green") +  # Change color scale from red to green
  theme_minimal() +
  ggtitle("Year 2002, distance and slope") +
  labs(color = "Total biomass") +
  theme(
    plot.background = element_rect(fill = "lightgrey"),  # Set background to light grey
    panel.background = element_rect(fill = "lightyellow") # Set rectangular wallpaper (panel background)
  )

# Fourth plot
plot4 = ggplot(data = s02) +
  geom_point(aes(x = bat, y = slope, color = log)) +
  scale_color_gradient(low = "red", high = "green") +  # Change color scale from red to green
  theme_minimal() +
  ggtitle("Year 2002, bathymetry and slope") +
  labs(color = "Total biomass") +
  theme(
    plot.background = element_rect(fill = "lightgrey"),  # Set background to light grey
    panel.background = element_rect(fill = "lightyellow") # Set rectangular wallpaper (panel background)
  )

# Arrange all plots into a grid
grid.arrange(plot1, plot2, plot3, plot4, ncol = 2)

##### plot salinity, temperature, biomass, minimum, fourth trimester 1997 and 2002 ####

plot1 = ggplot(data = s97) +
  geom_point(aes(x = salinity.minq4p, y = temp.minq4p, color = tot)) +
  scale_color_gradient(low = "green", high = "red") +  # Consistent color scale from yellow to black
  theme_minimal() +  # Clean minimal theme
  ggtitle("Year 1997: Salinity vs Temperature") +  # Add a title
  labs(color = "Total biomass") +  # Label for the color scale
  theme(
    plot.background = element_rect(fill = "lightgrey"),  # Set plot background color
    panel.background = element_rect(fill = "white")      # Set panel background to white
  )

# Second plot (Year 2002)
plot2 = ggplot(data = s02) +
  geom_point(aes(x = salinity.minq4p, y = temp.minq4p, color = tot)) +
  scale_color_gradient(low = "green", high = "red") +  # Consistent color scale from yellow to black
  theme_minimal() +  # Clean minimal theme
  ggtitle("Year 2002: Salinity vs Temperature") +  # Add a title
  labs(color = "Total biomass") +  # Label for the color scale
  theme(
    plot.background = element_rect(fill = "lightgrey"),  # Set plot background color
    panel.background = element_rect(fill = "white")      # Set panel background to white
  )


# Arrange all plots into a grid
grid.arrange(plot1, plot2, ncol = 2)

##### Trend estimation ####
##### Variogram ####
geo_data_97 <- as.geodata(s97, coords.col = 1:2, data.col = "log", covar.col = 3:25) #log biomass
bio_geo_data_97 = as.geodata(s97, coords.col = 1:2, data.col = "tot", covar.col = 3:25) #biomass

#
par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))  # Adjust margins for better spacing

# Plot 1: Variogram for bio_geo_data_97
plot(variog(bio_geo_data_97), 
     main = "Variogram for bio_geo_data_97", 
     xlab = "Distance", ylab = "Semivariance", 
     col = "blue", pch = 16, cex = 0.8, 
     type = "b")

# Plot 2: Variogram for geo_data_97
plot(variog(geo_data_97), 
     main = "Variogram for geo_data_97", 
     xlab = "Distance", ylab = "Semivariance", 
     col = "green", pch = 16, cex = 0.8, 
     type = "b")

# Plot 3: Variogram for geo_data_97 with max.dist = 300
plot(variog(geo_data_97, max.dist = 300), 
     main = "Variogram (max.dist = 300)", 
     xlab = "Distance", ylab = "Semivariance", 
     col = "red", pch = 16, cex = 0.8, 
     type = "b")

# Plot 4: Variogram for geo_data_97 with max.dist = 50
plot(variog(geo_data_97, max.dist = 50), 
     main = "Variogram (max.dist = 50)", 
     xlab = "Distance", ylab = "Semivariance", 
     col = "purple", pch = 16, cex = 0.8, 
     type = "b")


#Variance parameters estimation : matern, exponential and spherical models have been chosen as potential choices, due to the nature of the empirical variogram

#initial parameter estimate using graphical analysis
#d = eyefit(emp_variogram_97)

##### model estimation likelihood approach ####
vv.mat_97 = likfit(geo_data_97, ini.cov.pars = c(4.12, 11.69), nugget = 1.98, kappa = 0.27, cov.model = "matern")
vv.exp_97 = likfit(geo_data_97, ini.cov.pars = c(3.79, 11.69), nugget = 1.98, cov.model = "exponential")
vv.sph_97 = likfit(geo_data_97, ini.cov.pars = c(2.47, 11.69), nugget = 2.8, cov.model = "spherical")

# Leave one out cross-validation
xval.sph_97 = xvalid(geo_data_97, model = vv.sph_97)
xval.exp_97 = xvalid(geo_data_97, model = vv.exp_97)
xval.mat_97 = xvalid(geo_data_97, model = vv.mat_97)


# CV index
mean(xval.sph_97$std.error^2)
mean(xval.exp_97$std.error^2)
mean(xval.mat_97$std.error^2)
#1.01, 0.98, 0.95

# mse
mean(xval.sph_97$error^2)
mean(xval.exp_97$error^2)
mean(xval.mat_97$error^2)
#3.85, 3.77, 3.85

#predictions on the original scale
prev_orig_mat_97 = exp(xval.mat_97$predicted) - 1
prev_orig_exp_97 = exp(xval.exp_97$predicted) - 1
prev_orig_sph_97 = exp(xval.sph_97$predicted) - 1

# RMSE on the original scale
sqrt(mean((prev_orig_mat_97 - s97$tot)^2))
sqrt(mean((prev_orig_exp_97 - s97$tot)^2))
sqrt(mean((prev_orig_sph_97 - s97$tot)^2))
#152, 150, 149


##### Plot empirical and estimated variogram #### 
emp_variogram_97 = variog(geo_data_97, max.dist = 50)

par(mfrow = c(1, 1))

plot(
  emp_variogram_97,
  main = "Empirical Variogram with Fitted Models",
  xlab = "Distance",
  ylab = "Semivariance",
  pch = 16,
  col = "black"
)

# Add lines for each model with clear colors and line widths
lines(vv.sph_97, col = "red", lwd = 2)
lines(vv.exp_97, col = "blue", lwd = 2)
lines(vv.mat_97, col = "orange", lwd = 2)

# Add a legend with descriptive labels and line width
legend(
  "bottomright",
  legend = c("Spherical Model", "Exponential Model", "Matern Model"),
  col = c("red", "blue", "orange"),
  lty = 1,
  lwd = 2,
  bty = "n"
)





vv.exp_97$parameters.summary[,]

