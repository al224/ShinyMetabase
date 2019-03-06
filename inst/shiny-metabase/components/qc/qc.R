TabQC = R6Class(
    "TabQC",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = "qc",
        # initializer
        initialize = function(){

        },

        # UI
        ui = function(){
            ns = NS(self$id)
            tagList(
                "QC"
            )
        },

        # server
        server = function(input, output, session){

        }
    )
)
