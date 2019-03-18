## ShinyMetabase

This R package is a wrap up of a shiny app for Metabolomics data analysis. This app was built on top of the [Metabase](https://www.github.com/zhuchcn/Metabase) package, with a GUI interface provided by the [shiny](https://shiny.rstudio.com/) framework. It provides some fundamental types of analysis, including univariate analysis (linear model), principle component analysis (PCA), clustered heatmap, and partial correlation network analysis.

## Installation

There are quite a few packages that ShinyMetabase depends on. Please make sure all dependency packages were installed in your R environment. Using the command provided below to find out which packages are not installed.

```
pkgs = c(
    "shiny", "shinydashboard", "dplyr", "reshape2", "glue", "ggplot2", 
    "R6", "DT", "shinyPagerUI", "shinyjs", "plotly", "heatmaply", "shinyjqui",
    "space", "Metabase", "ggmetaplots"
)
for(pkg in pkgs){
    if(!suppressPackageStartupMessages(require(pkg, character.only = TRUE))){
        print(paste0("Package not installed: ", pkg))
    }
}
```

All packages can be installed from [CRAN](https://cran.r-project.org/) using the `install.packages()` function, except the **Metabase**, **ggmetaplots** and **shinyPagerUI** must be installed from github:

```
devtools::install_github("zhuchcn/Metabase")
devtools::install_github("zhuchcn/ggmetaplots")
devtools::install_github('wleepang/shiny-pager-ui')
```

When all dependency packages are installed, the package can be installed from github.

```
devtools::install_github("zhuchcn/ShinyMetabase")
```

## Data type

There are two entry points of this app. Users can either directly parse data to the launcher, or upload `.csv` files after the app is lunched. 

### Parse data to launcher

The data to be parsed to the launcher must inherits from the mSet class from the [Metabase](https://www.github.com/zhuchcn/Metabase) package.

```
data = Metabase::lipid
ShinyMetabase::launch(data)
```

### Upload data after launch

Users can also upload **three** separated '.csv' files after the app is launched. The three files:

1. **Conc table:** Must only contain numeric values with the first column and row being the name of each feature or sample.
2. **Sample table:** Each row contains the information of a sample. The number of row must equal to the number of samples in the **conc table**. The first column must be sample names and must equal to the sample names in the **conc table**
3. **Feature data:** Each row contains the inforamtion of a feature. The number of row must equal to the number of features in the **conc table**. THe first column must be feature names and must equal to the feature names in the **conc table**

Examples of the three `.csv` files can be found in this repository in `inst/shiny-metabase/data/` or from the package:

```
list.files(system.file("shiny-metabase/data/", package="ShinyMetabase"), pattern = ".csv")
```

To launch the app without parsing any data, just simply run:

```
ShinyMetabase::launch()
```
