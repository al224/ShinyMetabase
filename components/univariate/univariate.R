import::here(FormulaPanel, .from="./FormulaPanel.R")
import::here(StatsTable, .from="./StatsTable.R")
import::here(VolcanoPlot, .from="./VolcanoPlot.R")
import::here(BoxPlot, .from="./BoxPlot.R")

TabUnivariate = R6Class(
    "TabUnivariate",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = "univariate",
        formulaPanel = NULL,
        statsTable = NULL,
        maPlot = NULL,
        volcanoPlot = NULL,
        boxPlot = NULL,

        # initializer
        initialize = function(){
            self$formulaPanel = FormulaPanel$new("formula", self$id)
            self$statsTable = StatsTable$new("stats", self$id)
            self$volcanoPlot = VolcanoPlot$new("volcano", self$id)
            self$boxPlot = BoxPlot$new("boxplot", self$id)
        },

        # UI
        ui = function(){
            ns = NS(self$id)
            tagList(
                column(
                    width = 6,
                    self$formulaPanel$ui(),
                    self$statsTable$ui()
                ),
                column(
                    width = 6,
                    self$volcanoPlot$ui(),
                    self$boxPlot$ui()
                )
            )
        },

        # server
        #' @props data: a reactive that returns a mSet object after normalization
        server = function(input, output, session, props){

            states = reactiveValues(
                formulaSubmited = FALSE
            )
            formulaData = self$formulaPanel$call(props = props)

            statsData = self$statsTable$call(data = props, formulaData = formulaData)

            self$volcanoPlot$call(data = statsData)
            self$boxPlot$call(data = props, statsData = statsData)

            return(statsData)
        },

        # call
        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
