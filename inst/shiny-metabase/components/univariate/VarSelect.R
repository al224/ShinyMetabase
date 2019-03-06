VarSelect = R6Class(
    "VarSelect",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = NULL,
        parent_id = NULL,
        data = NULL,
        varName = NULL,
        varType = NULL,
        # initializer
        initialize = function(id, parent_id, data, varName, varType){
            self$id = id
            self$parent_id = parent_id
            self$data = data
            self$varName = varName
            self$varType = varType
        },

        # UI
        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            tagList(
                tags$tr(
                    tags$td(
                        selectInput(
                            ns(glue("varName-{self$id}")), NULL,
                            choices = colnames(sample_table(self$data)),
                            selected = if(!is.null(self$varName)) self$varName
                                        else colnames(sample_table(self$data))[1]
                        )
                    ),
                    tags$td(
                        selectInput(
                            ns(glue("varType-{self$id}")), NULL,
                            choices = c("numeric", "factor"),
                            selected = if(!is.null(self$varType)) self$varType
                                        else "numeric"
                        )
                    )
                )
            )
        },

        # server
        server = function(input, output, session){
            return(reactiveValues(
                varName = input[[glue("varName-{self$id}")]],
                varType = input[[glue("varType-{self$id}")]]
            ))
        }
    )
)
