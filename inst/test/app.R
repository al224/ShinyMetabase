library(shiny); library(R6); library(shinyPagerUI)

library(shiny)

# Define UI for data upload app ----
ui <- fluidPage(
    textOutput("text")
)

# Define server logic to read selected file ----
server <- function(input, output) {

    states = reactiveValues(
        lipid = reactive({
            Metabase::lipid
        })
    )

    output$text = renderText({
        Metabase::nfeatures(states$lipid())
    })
}

# Create Shiny app ----
shinyApp(ui, server)
