pkgs = c("shiny", "shinydashboard", "dplyr", "reshape2", "glue", "Metabase",
         "ggplot2", "R6", "DT", "shinyPagerUI", "shinyjs", "plotly", "heatmaply",
         "shinyjqui", "space")
for(pkg in pkgs) {
    suppressPackageStartupMessages(
        library(
            pkg, character.only = TRUE, verbose = FALSE,
            warn.conflicts = FALSE, quietly = TRUE
        )
    )
}

`%!in%` = function(x, y){
    !(`%in%`(x, y))
}
