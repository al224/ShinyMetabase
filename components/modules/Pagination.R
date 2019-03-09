Pagination = R6Class(
    "Pagination",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = NULL,
        parent_id = NULL,
        pages = NA,
        currentPage = 1,

        # initializer
        initializer = function(id, parent_id, pages, currentPage){
            self$id = id
            self$parent_id = parent_id
            self$pages = pages
            self$currentPage = currentPage
        },

        # UI
        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            tagList(
                pageruiInput(ns("page"))
            )
        },

        # server
        server = function(input, output, session){
            return({input$page$page_current})
        }
    )
)
