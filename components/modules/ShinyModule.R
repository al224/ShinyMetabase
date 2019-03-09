ShinyModule = R6Class(
    "ShinyModule",
    public = list(
        id = NULL,
        ui = function(){

        },
        server = function(input, output, session){

        },
        call = function(input, output, session){
            callModule(self$server, self$id)
        }
    ),
    private = list(

    )
)
