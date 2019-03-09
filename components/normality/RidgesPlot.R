#import::here(Pagination, .from="../modules/Pagination.R")

RidgesPlot = R6Class(
    "RidgesPlot",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = NULL,
        parent_id = NULL,

        # initializer
        initialize = function(id, parent_id){
            self$id = id
            self$parent_id = parent_id
        },

        # UI
        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            tagList(
                box(
                    width = NULL,
                    status = "primary",
                    title = tags$span(icon("chart-bar"), "Ridges Plot"),
                    solidHeader = TRUE,
                    numericInput(
                        ns("feats-per-page"),
                        "Features per page",
                        min = 10, max = 50,
                        value = 20,
                        width = "50%"
                    ),
                    tags$hr(),
                    uiOutput(ns("plot-ui")),
                    tags$hr(),
                    pageruiInput(
                        inputId = ns("page"), page_current = 1,
                        pages_total = 5
                    )
                )
            )
        },

        # Server
        server = function(input, output, session, props){

            states = reactiveValues(
                featuresPerPage = 20,
                totalFeatures = NULL,
                pages = NULL,
                currentPage = 1,
                plotHeight = "600px"
            )

            observe({
                states$totalFeatures = nfeatures(props$data())
                states$featuresPerPage = input$`feats-per-page`
                states$pages = ceiling(states$totalFeatures / states$featuresPerPage)

                updatePageruiInput(session, "page", pages_total = states$pages)

                if(states$featuresPerPage <= 30) {
                    states$plotHeight = "600px"
                } else {
                    states$plotHeight = glue("{20 * states$featuresPerPage}px")
                }
            })

            observeEvent(input$page$page_current, {
                states$currentPage = input$page$page_current
            })

            output$`plot-ui` = renderUI({
                plotOutput(session$ns("plot"), height = states$plotHeight)
            })

            output$plot = renderPlot({
                from = (states$currentPage - 1) * states$featuresPerPage + 1
                to = min(states$currentPage * states$featuresPerPage, states$totalFeatures)
                plot_normality_ridges(subset_features(props$data(), from:to)) +
                    theme(legend.position = "none")
            })
        },

        # Call
        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
