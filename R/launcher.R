#' @title Launch the ShinyMetabase app
#' @param data A \link{\code{mSet}} object. If is parsed, the data will be loaded
#' when the ShinyMetabase app is lunched.
#' @export
#' @examples
#' ShinyMetabase::launch(Metabase::lipid)
#' ShinyMetabase::launch()
launch = function(data){

    if(!missing(data)){
        if(!inherits(data, "mSet")) {
            stop("data must inherit from mSet")
        }
        .GlobalEnv$data <- data
        on.exit(rm(list=c("data"), envir=.GlobalEnv))
    }

    appdir = system.file(
        paste0("shiny-metabase", "/app.R"),
        package = 'ShinyMetabase',
        mustWork = TRUE
    )
    shiny::runApp(appdir)
}
