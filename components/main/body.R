import::here(TabOverview, .from="../overview/overview.R")
import::here(TabNormality, .from="../normality/normality.R")
import::here(TabUnivariate, .from="../univariate/univariate.R")
import::here(TabMultivariate, .from="../multivariate/multivariate.R")
import::here(NetworkTuning, .from="../network/NetworkTuning.R")
import::here(NetworkVisual, .from="../network/NetworkVisual.R")

Body = R6Class(
    "Body",
    inherit = ShinyModule,
    public = list(

        tabOverview = NULL,
        tabQC = NULL,
        tabNormality = NULL,
        tabUnivariate = NULL,
        tabMultivariate = NULL,
        tabNetworkTuning = NULL,
        tabNetworkVisual = NULL,

        initialize = function(){
            self$tabOverview = TabOverview$new()
            self$tabNormality = TabNormality$new()
            self$tabUnivariate = TabUnivariate$new()
            self$tabMultivariate = TabMultivariate$new()
            self$tabNetworkTuning = NetworkTuning$new()
            self$tabNetworkVisual = NetworkVisual$new()
        },

        ui = function(){
            dashboardBody(
                tags$link(href="style.css", rel = "stylesheet"),
                tags$script(src="script.js"),
                tags$script(src="cytoscape/bundle.js"),
                shinyjs::useShinyjs(),

                fluidRow(
                    tabItems(
                        tabItem( tabName = "tab_overview", self$tabOverview$ui()),
                        tabItem( tabName = "tab_normality", self$tabNormality$ui()),
                        tabItem( tabName = "tab_univariate", self$tabUnivariate$ui() ),
                        tabItem( tabName = "tab_multivariate", self$tabMultivariate$ui() ),
                        tabItem( tabName = "tab_network_tuning", self$tabNetworkTuning$ui() ),
                        tabItem( tabName = "tab_network_visual", self$tabNetworkVisual$ui() )
                    )
                )
            )
        },

        server = function(input, output, session){

            states = self$tabOverview$call()

            observe({
                if(is.null(states$data())) {
                    session$sendCustomMessage("dataNotLoaded", list(
                        tabs = c(
                            "tab_normality",
                            "tab_univariate",
                            "tab_multivariate",
                            "tab_network"
                        )
                    ))
                } else {
                    session$sendCustomMessage("dataLoaded", list(
                        tabs = c(
                            "tab_normality",
                            "tab_univariate",
                            "tab_multivariate",
                            "tab_network"
                        )
                    ))

                    norm_data = self$tabNormality$call(props = states)
                    stats_data = self$tabUnivariate$call(props = norm_data)

                    self$tabMultivariate$call(props = reactiveValues(
                        data = norm_data$data, statsData = stats_data
                    ))
                    self$tabNetworkTuning$call(props = norm_data)
                    self$tabNetworkVisual$call(props = norm_data)
                }
            })
        }
    )
)

