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

.GlobalEnv$data = Metabase::lipid

`%!in%` = function(x, y){
    !(`%in%`(x, y))
}

# MyShinyApp <- function(data) {
#     .GlobalEnv$data <- data
#     on.exit(rm(list=c("data"), envir=.GlobalEnv))
#     shiny::runApp("./")
# }
# MyShinyApp(Metabase::lipid)
