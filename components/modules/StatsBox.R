StatsBox = R6Class(
    "StatsBox",
    inherit = ShinyModule,
    public = list(

        id = NULL,
        parent_id = NULL,
        status = NULL,

        initialize = function(id, parent_id, status = "primary"){
            self$id = id
            self$parent_id = parent_id
            self$status = status
        },

        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            box(
                width = NULL,
                status = self$status,
                tags$h3(textOutput(ns("msg")))
            )
        },

        server = function(input, output, session, props){
            output$msg = renderText({props$message()})
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
