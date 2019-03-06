HeatmapParams = R6Class(
    "HeatmapParams",
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
                    title = tags$span(icon("list-alt"),"Heatmap Settings"),
                    status = "primary",
                    solidHeader = TRUE,

                    radioButtons(
                        ns("scale"),
                        label = "Scaling method",
                        choices = c(
                            "none",
                            "z-score scale",
                            "absolute scale"
                        ),
                        inline = TRUE,
                        selected = "z-score scale"
                    ),

                    tags$div(
                        class= "row",
                        column(
                            width = 6,
                            radioButtons(
                                ns("filter-method"),
                                label = "Filtering method",
                                choices = c(
                                    "Top N",
                                    "p-value"
                                ),
                                inline = TRUE
                            )
                        ),
                        column(
                            width = 6,
                            uiOutput(ns("filter-ui"))
                        )
                    ),

                    uiOutput(ns("anno-ui")),

                    tags$div(
                        class = "row",
                        column(
                            width = 6,
                            checkboxInput(
                                ns("rowv"), "Show row-wise dendrogram",
                                value = TRUE
                            )
                        ),
                        column(
                            width = 6,
                            checkboxInput(
                                ns("colv"), "Show column-wise dendrogram",
                                value = TRUE
                            )
                        )
                    ),

                    tags$div(
                        class = "row",
                        column(
                            width = 6,
                            selectInput(
                                ns("seriate"), "Seriate (matrix sorting)",
                                choices = c("none", "OLO", "GW")
                            )
                        )
                    ),

                    tags$div(
                        class = "row",
                        column(
                            width = 6,
                            numericInput(
                                ns("row-text-angle"), "Row text angle",
                                min = 0, max = 90, step = 1, value = 0
                            )
                        ),
                        column(
                            width = 6,
                            numericInput(
                                ns("column-text-angle"), "Column text angle",
                                min = 0, max = 90, step = 1, value = 0
                            )
                        )
                    )
                )
            )
        },

        # server
        #' @props data: a reactive that returns a mSet object after normalization
        #' @props statsData: a reactiveValues with the limma table result and the
        #' rowSelected, passed from ../univariate/StatsTable.R
        #' @emit data: a reactive returns the filtered mSet data
        #' @emit Rowv: boolean
        #' @emit Colv: boolean
        #' @emit anno-row: string
        #' @emit anno-col: string
        #' @emit seriate: string
        #' @emit row_text_angle: numeric
        #' @emit column_text_angle: numeric
        server = function(input, output, session, props){

            output$`anno-ui` = renderUI({
                tags$div(
                    class = "row",
                    column(
                        width = 6,
                        self$selectInput(
                            session$ns("anno-row"),"Row Annotation", props$data(), "row"
                        )
                    ),
                    column(
                        width = 6,
                        self$selectInput(
                            session$ns("anno-col"),"Column Annotation", props$data(), "col"
                        )
                    )
                )
            })

            emit = reactiveValues(
                data = NULL,
                Rowv = TRUE,
                Colv = TRUE,
                `anno-row` = NULL,
                `anno-col` = NULL,
                seriate = NULL,
                row_text_angle = 0,
                column_text_angle = 0
            )

            output$`filter-ui` = renderUI({
                if(input$`filter-method` == "Top N"){
                    numericInput(
                        session$ns("topn"), "Top N most abundant",
                        min = 1, step = 1, value = 25
                    )
                } else {
                    numericInput(
                        session$ns("pvalue"),
                        "P-value cutoff",
                        min = 0, max = 1, step = 0.01, value = 0.1
                    )
                }
            })

            observeEvent(input$`filter-method`, {
                if(input$`filter-method` == "p-value" & is.null(props$statsData$rowSelected)){
                    showNotification(
                        "Only avaiable when the univariate is done",
                        type = "error"
                    )
                    updateRadioButtons(
                        session, "filter-method", selected = "Top"
                    )
                }
            })

            emit$data = reactive({
                if(input$`filter-method` == "Top N") {
                    feats = order(
                        rowMeans(data$conc_table, na.rm = TRUE),
                        decreasing = TRUE
                    )[1:input$topn]
                    dataFiltered = subset_features(props$data(), feats)
                } else {
                    dataFiltered = subset_features(
                        props$data(),
                        props$statsData$statsData()$pvalue < input$pvalue
                    )
                }

                scale_func = switch(
                    input$scale,
                    "none" = function(x){return(x)},
                    "z-score scale" = self$zscoreScale,
                    "absolute scale" = self$absoluteScale
                )
                dataFiltered = scale_func(dataFiltered)

                return(dataFiltered)
            })

            observeEvent(input$`anno-col`, { emit$`anno-col` = input$`anno-col` })
            observeEvent(input$`anno-row`, { emit$`anno-row` = input$`anno-row` })
            observeEvent(input$colv, { emit$Colv = input$colv })
            observeEvent(input$rowv, { emit$Rowv = input$rowv })
            observeEvent(input$seriate, { emit$seriate = input$seriate })
            observeEvent(input$`row-text-angle`, { emit$row_text_angle = input$`row-text-angle` })
            observeEvent(input$`column-text-angle`, { emit$column_text_angle = input$`column-text-angle` })

            return(emit)
        },

        # call
        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        },

        selectInput = function(inputId, label, data, side){
            choices = list("-- Please select --" = "null")
            if(side == "col"){
                items = colnames(data$sample_table)
            } else {
                items = colnames(data$feature_data)
            }
            for(x in items){
                choices[[x]] = x
            }
            selectInput(inputId, label, choice = choices, multiple = TRUE)
        },

        zscoreScale = function(x){
            edata = t(apply(x$conc_table, 1, scale))
            dimnames(edata) = dimnames(x$conc_table)
            edata = conc_table(edata)
            x$conc_table = edata
            return(x)
        },
        absoluteScale = function(x){
            edata = apply(x$conc_table, 1, function(row){
                ((row - min(row)) / (max(row) - min(row)) - 0.5) * 2
            }) %>% t
            dimnames(edata) = dimnames(x$conc_table)
            edata = conc_table(edata)
            x$conc_table = edata
            return(x)
        }
    )
)
