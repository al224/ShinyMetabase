source("global.R", local = TRUE)

module2UI = function(id) {
    ns = NS(id)
    tags$div(
        uiOutput(ns("input_ui"))
    )
}

module2 = function(input, output, session, msg){
    output$input_ui = renderUI({
        numericInput(session$ns("nrows"), msg, value = 6, step = 1)
    })

    return(reactive(input$nrows))
}

module1UI = function(id) {
    ns = NS(id)
    tags$div(
        module2UI(ns("mod2")),
        tableOutput(ns("table"))
    )
}

module1 = function(input, output, session, data){

    nrows = callModule(module2, "mod2", msg = "Input number of rows")

    output$table = renderTable({
        head(data, nrows())
    })
}

ui <- fluidPage(
    fluidRow(
        module1UI("iris"),
        module1UI("mtcars")
    )
)

server <- function(input, output, session) {
    callModule(module1, "iris",  data = iris)
    callModule(module1, "mtcars",  data = mtcars)
}

shinyApp(ui, server)
