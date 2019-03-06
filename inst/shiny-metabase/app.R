source("global.R", local = TRUE)
source("components/modules/ShinyModule.R")

import::here(Body, .from="./components/main/body.R")
import::here(SideBar, .from="./components/main/sidebar.R")

ShinyApp = R6Class(
    "ShinyApp",
    public = list(

        sideBarPage = NULL,
        bodyPage = NULL,

        initialize = function(){
            self$sideBarPage = SideBar$new()
            self$bodyPage = Body$new()
        },

        ui = function(){
            dashboardPage(
                header = dashboardHeader(title = "ShinyMetabase"),
                sidebar = self$sideBarPage$ui(),
                body = self$bodyPage$ui()
            )
        },

        server = function(input, output, session){
            shinyjs::removeClass(selector = ".btn", class="btn-default")
            shinyjs::addClass(selector = "span.btn-file", class="btn-warning")
            self$bodyPage$call()
        }
    )
)

shinyApp = ShinyApp$new()

shinyApp(shinyApp$ui(), shinyApp$server)
