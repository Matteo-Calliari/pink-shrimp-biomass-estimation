# Pink Shrimp Biomass Estimation: A Kriging-Based Approach

Spatial prediction of pink shrimp biomass using Universal Kriging, estimated with both **Maximum Likelihood** and **Bayesian** methods, with GAM-based trend estimation. Developed in R for the Spatial Statistics course of the M.Sc. in Statistical Sciences at Sapienza University of Rome, and presented in English in November 2024.

## Question

How is pink shrimp biomass distributed in the northern Tyrrhenian Sea and the Ligurian Sea, and how well can it be predicted at unsampled locations? Do the Maximum Likelihood and Bayesian approaches give different predictions?

## Data

Survey data from the **MEDITS** programme for the years **1997** and **2002**, covering the northern Tyrrhenian Sea and the Ligurian Sea. Covariates include bathymetry, slope, distance from the coast, temperature and salinity.

**The data files are not included in this repository.**
`shrimpsfull.RData` holds the survey observations and `AllGrids.RData` holds the prediction grids.
<!-- TODO: add where the data can be requested or downloaded -->

## Methods

1. **Exploratory analysis** of the spatial distribution of biomass, histograms, and Spearman correlations between covariates.
2. **Log transformation**, log(biomass + 1), because the biomass distribution is zero-inflated and asymmetric.
3. **Trend estimation** with four Generalized Additive Models (GAMs), using smooth terms for combinations of slope, bathymetry, distance from the coast, temperature and salinity.
4. **Spatial process model**: Z(s) = X(s)β + W(s) + ε(s), with a trend component, a spatial random effect and measurement error.
5. **Variogram estimation** by Maximum Likelihood (`geoR::likfit`) for exponential, spherical and Matérn covariance models, compared by leave-one-out cross-validation (CV index, MSE, RMSE).
6. **Maximum Likelihood kriging** on a prediction grid, with 95% confidence intervals.
7. **Bayesian kriging** (`geoR::krige.bayes`), with priors informed by the ML estimates and the empirical variogram, and 95% credibility intervals.
8. **Comparison** of the two approaches with CV index, MSE, RMSE and interval score (IS).

## Results

Model performance by leave-one-out cross-validation, on the log(biomass + 1) scale:

| Year | Method | CV index | MSE | RMSE | Interval score |
|------|--------|----------|-------|-------|----------------|
| 1997 | Bayesian | 0.996 | 3.775 | 1.943 | 8.416 |
| 1997 | ML | 0.982 | 3.779 | 1.944 | 8.270 |
| 2002 | Bayesian | 1.020 | 5.354 | 2.314 | 9.299 |
| 2002 | ML | 0.989 | 5.368 | 2.317 | 9.030 |

The two approaches perform almost identically in both years, for point predictions, interval predictions and explained variance. The prior distributions were mostly non-informative, so most of the information comes from the data. More informative priors might make the methods differ more.

## Repository contents

- `presentazione.Rmd`: the full analysis and report (R Markdown, Beamer presentation)
- `presentazione.R`: the analysis script
- `presentazione.pdf`: the rendered presentation

## How to run

1. Put `shrimpsfull.RData` and `AllGrids.RData` in the same folder as `presentazione.Rmd`.
2. Install the required R packages:
   `geoR`, `mgcv`, `ggplot2`, `gridExtra`, `patchwork`, `corrplot`, `metR`, `sf`, `sp`, `gstat`, `MBA`, `fpp3`, `knitr`.
3. Open `presentazione.Rmd` in RStudio and click **Knit**. A LaTeX installation (for example TinyTeX) is needed for the Beamer PDF. The Bayesian cross-validation is computationally heavy, so knitting takes a while.

## Authors

- Matteo Calliari
- Stefano Platti

M.Sc. in Statistical Sciences, Sapienza University of Rome.
