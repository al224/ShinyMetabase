import::here(TabOverview, .from="../overview/overview.R")
import::here(TabNormality, .from="../normality/normality.R")
import::here(TabUnivariate, .from="../univariate/univariate.R")
import::here(TabMultivariate, .from="../multivariate/multivariate.R")
import::here(TabNetwork, .from="../network/network.R")

source("../network/network.R", local = TRUE)

Body = R6Class(
    "Body",
    inherit = ShinyModule,
    public = list(

        tabOverview = NULL,
        tabQC = NULL,
        tabNormality = NULL,
        tabUnivariate = NULL,
        tabMultivariate = NULL,
        tabNetwork = NULL,

        initialize = function(){
            self$tabOverview = TabOverview$new()
            self$tabNormality = TabNormality$new()
            self$tabUnivariate = TabUnivariate$new()
            self$tabMultivariate = TabMultivariate$new()
            self$tabNetwork = TabNetwork$new()
        },

        ui = function(){
            dashboardBody(
                tags$link(href="style.css", rel = "stylesheet"),
                tags$script(src="script.js"),
                tags$script(src="cytoscape/bundle.js"),
                shinyjs::useShinyjs(),
                extendShinyjs(text = self$jscode),

                fluidRow(
                    tabItems(
                        tabItem( tabName = "tab_overview", self$tabOverview$ui()),
                        tabItem( tabName = "tab_normality", self$tabNormality$ui()),
                        tabItem( tabName = "tab_univariate", self$tabUnivariate$ui() ),
                        tabItem( tabName = "tab_multivariate", self$tabMultivariate$ui() ),
                        tabItem( tabName = "tab_network", self$tabNetwork$ui() )
                    )
                )
            )
        },

        server = function(input, output, session){

            states = self$tabOverview$call()

            observe({
                if(is.null(states$data())) {
                    js$disableTab("tab_normality")
                    js$disableTab("tab_univariate")
                    js$disableTab("tab_multivariate")
                    js$disableTab("tab_network")
                } else {
                    js$enableTab("tab_normality")
                    js$enableTab("tab_univariate")
                    js$enableTab("tab_multivariate")
                    js$enableTab("tab_network")

                    norm_data = self$tabNormality$call(props = states)
                    stats_data = self$tabUnivariate$call(props = norm_data)

                    self$tabMultivariate$call(props = reactiveValues(
                        data = norm_data$data, statsData = stats_data
                    ))
                    self$tabNetwork$call(props = norm_data)
                }
            })
        },

        jscode = "
            shinyjs.disableTab = function(name) {
              var tab = $('a[data-value=' + name + ']');
              tab.bind('click.tab', function(e) {
                e.preventDefault();
                return false;
              });
              tab.addClass('disabled');
            }

            shinyjs.enableTab = function(name) {
              var tab = $('a[data-value=' + name + ']');
              tab.unbind('click.tab');
              tab.removeClass('disabled');
            }
        "
    )
)

