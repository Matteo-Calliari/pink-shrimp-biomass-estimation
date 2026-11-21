# Pink Shrimp Biomass Estimation

Spatial modelling of pink shrimp biomass using Generalized Additive Models (GAMs)
and Universal Kriging, in both Frequentist and Bayesian frameworks. Developed in R
as a project for the Spatial Statistics course (M.Sc. Statistical Sciences,
Sapienza University of Rome).

## Question
How is pink shrimp biomass distributed across [study area / GSA], and how well can
it be predicted at unsampled locations? **[One sentence: your main finding]**

## Data
Survey data from the MEDITS programme, [years]. The data files are not included in
this repository. `shrimpsfull.RData` holds the survey observations and
`AllGrids.RData` holds the prediction grid. **[Where to request or download the data]**

## Methods
- Exploratory spatial analysis of the survey data
- GAMs for the trend component
- Universal Kriging, Frequentist and Bayesian
- **[Model comparison method, for example cross-validation]**

## Repository contents
- `presentazione.Rmd`: the full analysis and report (R Markdown)
- `presentazione.R`: the analysis script
- `presentazione.pdf`: the rendered presentation

## How to run
1. Place `shrimpsfull.RData` and `AllGrids.RData` in the project folder.
2. Install the required R packages: **[list, for example mgcv, gstat, sf]**.
3. Open `presentazione.Rmd` in RStudio and click Knit.

## Results
**[One or two key findings, plus a figure if you want one]**

## Author
Matteo Calliari. M.Sc. in Statistical Sciences, Sapienza University of Rome.
