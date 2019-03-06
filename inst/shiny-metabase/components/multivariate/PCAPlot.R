PCAPlot = R6Class(
    "PCAPlot",
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
                    title = tags$span(icon("chart-bar"), "PCA Plot"),
                    status = "primary",
                    solidHeader = TRUE,

                    plotlyOutput(ns("plot"))
                )
            )
        },

        # server
        #' @props data: a reactive that retures a mSet after transformation
        #' @props color: string
        #' @props ellipse: boolean
        #' @props x: string, the name of PC for x axis
        #' @props y: string, the name of PC for y axis
        server = function(input, output, session, props){

            output$plot = renderPlotly({
                pca = prcomp(t(props$data()$conc_table))
                explained = pca$sdev ^ 2 / sum(pca$sdev ^ 2)

                getLabel = function(pc, ex){
                    ind = as.integer(gsub("PC", "", pc))
                    ex = formatC(ex[ind] * 100, digits = 2, format = "f")
                    glue("{pc} [{ex}%]")
                }
                xLabel = getLabel(props$x, explained)
                yLabel = getLabel(props$y, explained)

                df = data.frame(
                    x = pca$x[, props$x],
                    y = pca$x[, props$y]
                )
                df = cbind(df, props$data()$sample_table)

                color = props$color
                if(length(color) == 0){
                    color = NULL
                } else if (length(color) == 1 & color == "null"){
                    color = NULL
                } else {
                    color = color[color != "null"]
                }

                if(length(color) == 0){
                    color = NULL
                } else if(length(color) == 1){
                    if(color == "null"){
                        color = NULL
                    } else {
                        color = df[, color]
                    }
                } else {
                    color = interaction(df[,color])
                }

                p = ggplot(df, aes(x = x, y = y, color = color)) +
                    geom_point()

                if(props$ellipse){
                    p = p + stat_ellipse()
                }
                p + labs(x = xLabel, y = yLabel) +
                    theme_bw()
            })

        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
