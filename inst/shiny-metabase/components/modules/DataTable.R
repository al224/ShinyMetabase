DataTable = R6Class(
    "DataTable",
    inherit = ShinyModule,
    public = list(
        id = NULL,
        parent_id = NULL,

        initialize = function(id, parent_id = NULL){
            self$id = id
            self$parent_id = parent_id
        },

        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            dataTableOutput(ns("data-table"))
        },

        server = function(input, output, session, data){
            output$`data-table` = renderDataTable(data())
        },

        call = function(input, output, session, data){
            callModule(self$server, self$id, data)
        }
    )
)
