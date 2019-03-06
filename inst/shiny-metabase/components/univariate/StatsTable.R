#import::here(DataTable, .from="../modules/DataTable.R")

StatsTable = R6Class(
    "StatsTable",
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
                    id = ns("box"),
                    status = "primary",
                    title = tags$span(icon("table"), "Linear Model"),
                    solidHeader = TRUE,
                    dataTableOutput(ns("data-table"))
                )
            )
        },

        # server
        server = function(input, output, session, data, formulaData){

            states = reactiveValues(
                statsData = reactive({
                    if(!is.null(formulaData$coef)) {
                        mSet_limma(
                            data$data(),
                            design = formulaData$design,
                            transform = function(x){return(x)},
                            coef = formulaData$coef,
                            p.value = formulaData$coef
                        )
                    }
                }),
                rowSelected = NULL
            )

            output$`data-table` = renderDataTable({
                if(!is.null(formulaData$coef)){
                    states$statsData() %>%
                        datatable(
                            selection = list(mode = "single", selected = 1),
                            options = list(
                                order = list(4, "asc")
                            )
                        ) %>%
                        formatSignif(columns = 1:5, digits = 4)
                }
            })

            observeEvent(input$`data-table_rows_selected`, {
                states$rowSelected = input$`data-table_rows_selected`
            })

            return(states)
        },

        call = function(input, output, session, data, formulaData){
            callModule(self$server, self$id, data = data, formulaData = formulaData)
        }
    )
)
