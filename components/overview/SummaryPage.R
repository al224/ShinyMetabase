import::here(StatsBox, .from = "../modules/StatsBox.R")
import::here(DataTable, .from = "../modules/DataTable.R")

SummaryPage = R6Class(
    "SummaryPage",
    inherit = ShinyModule,
    public = list(

        id = NULL,
        parent_id = NULL,
        data = NULL,
        featNumBox = NULL,
        sampNumBox = NULL,
        featVarBox = NULL,
        sampVarBox = NULL,
        sampTable = NULL,
        featTable = NULL,
        concTable = NULL,

        initialize = function(id, parent_id){
            self$id = id
            self$parent_id = parent_id
            self$featNumBox = StatsBox$new("feat-num", NS(parent_id)(id))
            self$sampNumBox = StatsBox$new("samp-num", NS(parent_id)(id))
            self$featVarBox = StatsBox$new("feat-var", NS(parent_id)(id))
            self$sampVarBox = StatsBox$new("samp-var", NS(parent_id)(id))
            #Tables
            self$sampTable = DataTable$new("samp-table", NS(parent_id)(id))
            self$featTable = DataTable$new("feat-table", NS(parent_id)(id))
        },

        ui = function(){
            tags$div(
                tags$section(
                    class="col",
                    tags$div(
                        class = "col-sm-6 col-lg-3",
                        self$featNumBox$ui()
                    ),
                    tags$div(
                        class = "col-sm-6 col-lg-3",
                        self$sampNumBox$ui()
                    ),
                    tags$div(
                        class = "col-sm-6 col-lg-3",
                        self$featVarBox$ui()
                    ),
                    tags$div(
                        class = "col-sm-6 col-lg-3",
                        self$sampVarBox$ui()
                    )
                ),
                tags$section(
                    class="col",
                    tags$div(
                        class="col-sm-12",
                        box(
                            width = NULL,
                            tabsetPanel(
                                tabPanel(
                                    "Sample Data",
                                    self$sampTable$ui()
                                ),
                                tabPanel(
                                    "Feature Data",
                                    self$featTable$ui()
                                )
                            )
                        )
                    )
                )
            )
        },

        server = function(input, output, session, props){

            self$featNumBox$call(props = reactiveValues(
                message = reactive({
                    glue("Number of features: {nfeatures(props$data())}")
                })
            ))
            self$sampNumBox$call(props = reactiveValues(
                message = reactive({
                    glue("Number of samples: {nsamples(props$data())}")
                })
            ))
            self$featVarBox$call(props = reactiveValues(
                message = reactive({
                    glue("Feature variables: {ncol(props$data()$feature_data)}")
                })
            ))
            self$sampVarBox$call(props = reactiveValues(
                message = reactive({
                    glue("Sample variables: {ncol(props$data()$sample_table)}")
                })
            ))

            self$sampTable$call(data = reactive({
                as(props$data()$sample_table, "data.frame")
            }))
            self$featTable$call(data = reactive({
                as(props$data()$feature_data, "data.frame")
            }))
        },
        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
