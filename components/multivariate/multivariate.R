import::here(PCAParams, .from="./PCAParams.R")
import::here(PCAPlot, .from="./PCAPlot.R")
import::here(HeatmapParams, .from="./HeatmapParams.R")
import::here(HeatmapPlot, .from="./HeatmapPlot.R")

TabMultivariate = R6Class(
    "TabMultivariate",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = "multivariate",
        pcaParams = NULL,
        pcaPlot = NULL,
        heatmapParams = NULL,
        heatmapPlot = NULL,

        # initializer
        initialize = function(){
            self$pcaParams = PCAParams$new("pca-params", self$id)
            self$pcaPlot = PCAPlot$new("pca-plot", self$id)
            self$heatmapParams = HeatmapParams$new("hm-params", self$id)
            self$heatmapPlot = HeatmapPlot$new("hm-plot", self$id)
        },

        # UI
        ui = function(){
            ns = NS(self$id)
            tagList(
                column(
                    width = 6,
                    self$heatmapParams$ui(),
                    self$heatmapPlot$ui()
                ),
                column(
                    width = 6,
                    self$pcaParams$ui(),
                    self$pcaPlot$ui()
                )
            )
        },

        # server
        #' @props data: a reactive that returns a mSet object after normalization
        #' @props statsData: a reactiveValues with the limma table result and the
        #' rowSelected, passed from ../univariate/StatsTable.R
        server = function(input, output, session, props){

            pcaData = self$pcaParams$call(props = props)
            self$pcaPlot$call(props = pcaData)

            hmData = self$heatmapParams$call(props = props)
            self$heatmapPlot$call(props = hmData)
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
