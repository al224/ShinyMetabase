VolcanoPlot = R6Class(
    "VolcanoPlot",
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
                    title = tags$span(icon("chart-bar"), "Volcano Plot"),
                    solidHeader = TRUE,
                    plotlyOutput(ns("plot"))
                )
            )
        },

        # server
        server = function(input, output, session, data){
            #pointData = data$statsData()[,]
            output$plot = renderPlotly({
                if(!is.null(data$rowSelected)){
                    data$statsData() %>%
                        tibble::rownames_to_column("feature") %>%
                        ggplot(aes(x = logFC, y = -log(pvalue), feature = feature),
                            pvalue = pvalue, logFC = logFC, padj = padj) +
                        geom_point(alpha = 0.7) +
                        geom_point(data = function(x){x[data$rowSelected,]},
                                   aes(x = logFC, y = -log(pvalue)),
                                   color = "firebrick2") +
                        geom_hline(yintercept = -log(0.05), linetype = "dashed", color = "firebrick2") +
                        theme_bw()
                }
            })
        },

        # call
        call = function(input, output, session, data){
            callModule(self$server, self$id, data)
        }
    )
)
