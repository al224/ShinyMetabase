pkgs = c("shiny", "shinydashboard", "dplyr", "reshape2", "glue", "Metabase",
         "ggplot2", "R6", "DT", "shinyPagerUI", "shinyjs", "plotly", "heatmaply",
         "fontawesome", "shinyjqui")
for(pkg in pkgs) library(pkg, character.only = TRUE, verbose = FALSE, warn.conflicts = FALSE, quietly = TRUE)

`%!in%` = function(x, y){
    !(`%in%`(x, y))
}
