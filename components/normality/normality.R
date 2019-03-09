import::here(ParamsPanel, .from="./ParamsPanel.R")
import::here(RidgesPlot, .from="./RidgesPlot.R")
import::here(MedianHist, .from="./MedianHist.R")

TabNormality = R6Class(
    "TabNormality",
    inherit = ShinyModule,
    public = list(

        id = "normality",
        paramsPanel = NULL,
        ridgesPlot = NULL,
        medianHist = NULL,

        initialize = function(data){
            self$paramsPanel = ParamsPanel$new("params", self$id)
            self$ridgesPlot = RidgesPlot$new("ridges", self$id)
            self$medianHist = MedianHist$new("hist", self$id)

        },

        ui = function(){
            ns = NS(self$id)
            tagList(
                column(
                    width = 6,
                    self$paramsPanel$ui(),
                    textOutput(ns("normal")),
                    self$medianHist$ui()
                ),
                column(
                    width = 6,
                    self$ridgesPlot$ui()
                )
            )
        },
        server = function(input, output, session, props){
            emit = reactiveValues(
                data = reactive(
                    props$data
                )
            )

            emit = self$paramsPanel$call(props = reactiveValues(
                data = reactive(props$data())
            ))

            self$ridgesPlot$call(props = emit)

            self$medianHist$call(props = emit)

            return(emit)
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)

