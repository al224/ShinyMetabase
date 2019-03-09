PCAParams = R6Class(
    "PCAParams",
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
                    title = tags$span(icon("list-alt"), "PCA Settings"),
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
                        inline = TRUE
                    ),

                    uiOutput(ns("axis-ui")),

                    tags$div(
                        class = "row",
                        uiOutput(ns("color-ui")),
                        column(
                            width = 6,
                            checkboxInput(
                                ns("ellipse"), "Draw ellipse", value = FALSE
                            )
                        )
                    ),

                    div(
                        class="col-md-6",
                        disabled(
                            numericInput(
                                ns("cutoff"), "P value cutoff",
                                min = 0, max = 1, value = NA, step = 0.01
                            )
                        )
                    ),
                    "This is only available when the univariate analysis is done"
                )
            )
        },

        # server
        #' @props data: a reactive that returns a mSet object after normalization
        #' @props statsData: a reactiveValues with the limma table result and the
        #' rowSelected, passed from ../univariate/StatsTable.R
        #' @emit data: a reactive that retures a mSet after transformation
        #' @emit color: string
        #' @emit ellipse: boolean
        #' @emit x: string, the name of PC for x axis
        #' @emit y: string, the name of PC for y axis
        server = function(input, output, session, props){

            emit = reactiveValues(
                data = NULL,
                color = NULL,
                ellipse = FALSE,
                x = NULL,
                y = NULL
            )

            output$`color-ui` = renderUI({
                column(
                    width = 6,
                    self$selectInput(
                        session$ns("color"), "Color variable",
                        colnames(props$data()$sample_table)
                    )
                )
            })

            output$`axis-ui` = renderUI({
                tags$div(
                    class = "row",
                    column(
                        width = 6,
                        self$axisSelectInput(
                            session$ns("x"), "x-axis", "PC1", props$data()
                        )
                    ),
                    column(
                        width = 6,
                        self$axisSelectInput(
                            session$ns("y"), "y-axis", "PC2", props$data()
                        )
                    )
                )
            })

            observeEvent(props$statsData$rowSelected, {
                enable("cutoff")
            })

            emit$data = reactive({
                scale_fun = switch(
                    input$scale,
                    "none" = function(x) {x},
                    "z-score scale" = self$zscoreScale,
                    "absolute scale" = self$absoluteScale
                )
                pcaData = scale_fun(props$data())
                if(!is.na(input$cutoff)) {
                    pcaData = subset_features(
                        pcaData,
                        props$statsData$statsData()$pvalue < input$cutoff
                    )
                }
                return(pcaData)
            })

            observeEvent(input$color, {emit$color = input$color})
            observeEvent(input$ellipse, {emit$ellipse = input$ellipse})
            observeEvent(input$x, {emit$x = input$x})
            observeEvent(input$y, {emit$y = input$y})

            return(emit)
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        },

        selectInput = function(inputId, label, choices){
            choices_list = list("-- Please select --" = "null")
            for(x in choices){
                choices_list[[x]] = x
            }
            selectInput(inputId, label, choice = choices_list, multiple = TRUE)
        },

        axisSelectInput = function(inputId, label, selected, data){
            selectInput(
                inputId, label,
                choices = paste0(
                    "PC", seq_len(min(
                        nsamples(data), nfeatures(data)
                    ))
                ),
                selected = selected
            )
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
