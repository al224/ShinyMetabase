BoxPlot = R6Class(
    "BoxPlot",
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
                    width = NULL,
                    status = "primary",
                    title = tags$span(icon("chart-bar"), "Box Plot"),
                    solidHeader = TRUE,

                    uiOutput(ns("params")),
                    plotlyOutput(ns("plot"))
                )
            )
        },

        # server
        server = function(input, output, session, data, statsData){

            output$`params` = renderUI({
                tags$div(
                    class = "row",
                    tags$div(
                        class = "col-md-6",
                        self$selectInput(
                            session$ns("x"), "x variable",
                            colnames(data$data()$sample_table)
                        )
                    ),
                    tags$div(
                        class = "col-md-6",
                        self$selectInput(
                            session$ns("col"), "Column facet",
                            colnames(data$data()$sample_table)
                        )
                    ),
                    tags$div(
                        class = "col-md-6",
                        self$selectInput(
                            session$ns("row"), "Row facet",
                            colnames(data$data()$sample_table)
                        )
                    ),
                    tags$div(
                        class = "col-md-6",
                        self$selectInput(
                            session$ns("color"), "Color Variable",
                            colnames(data$data()$sample_table)
                        )
                    ),
                    tags$div(
                        class = "col-md-6",
                        self$selectInput(
                            session$ns("line"), "Line",
                            colnames(data$data()$sample_table)
                        )
                    ),
                    tags$div(
                        class = "col-md-6",
                        checkboxInput(
                            session$ns("points"), "Show points", value = TRUE
                        )
                    )
                )
            })

            output$plot = renderPlotly({
                logjs(col)
                if(!is.null(statsData$rowSelected) & input$x != "null"){
                    feature = featureNames(data$data())[statsData$rowSelected]
                    args = list(
                        object = data$data(),
                        x = input$x,
                        feature = feature,
                        rows = input$row,
                        cols = input$col,
                        line = input$line,
                        color = input$color
                    )
                    args = args[args != "null"]
                    p = do.call(plot_boxplot, args)
                    p + labs(title = feature, y = "")
                }
            })
        },

        call = function(input, output, session, data, statsData){
            callModule(self$server, self$id, data, statsData)
        },

        selectInput = function(inputId, label, choices){
            choices_list = list("-- Please select --" = "null")
            for(x in choices){
                choices_list[[x]] = x
            }
            selectInput(inputId, label, choice = choices_list)
        }
    )
)
