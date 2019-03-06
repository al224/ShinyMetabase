MedianHist = R6Class(
    "MedianHist",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = NULL,
        parent_id = NULL,

        # initializer
        initialize = function(id, parent_id){
            self$id = id
            self$parent_id = parent_id

        },

        # UI
        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            tagList(
                box(
                    width = NULL, status = "primary",
                    solidHeader = TRUE,
                    title = tags$span(icon("chart-bar"), "Z-score Median Histogram"),
                    numericInput(ns("bins"), "Input the number of bins",
                                 value = 30, min = 1, max = 100, step = 1,
                                 width = "50%"),
                    tags$hr(),
                    plotOutput(ns("hist"))
                )
            )
        },

        # server
        server = function(input, output, session, props){

            output$hist = renderPlot({
                plot_median_hist(props$data(), bins = input$bins)
            })

        },

        # Call
        call = function(input, ouput, sesison, props){
            callModule(self$server, self$id, props)
        }
    )
)
