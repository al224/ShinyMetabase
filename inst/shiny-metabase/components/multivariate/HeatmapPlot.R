HeatmapPlot = R6Class(
    "HeatmapPlot",
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
                    title = tags$span(icon("chart-bar"),"Heatmap"),
                    status = "primary",
                    solidHeader = TRUE,

                    shinyjqui::jqui_resizable(plotlyOutput(ns("plot")))
                )
            )
        },

        # server
        #' @props data: a reactive returns the filtered mSet data
        #' @props Rowv: boolean whether to draw row dendrogram
        #' @props Colv: boolean whether to draw column dengrogram
        #' @props anno-row: string
        #' @props anno-col: string
        #' @props seriate: string
        #' @props row_text_angle: numeric
        #' @props column_text_angle: numeric
        server = function(input, output, session, props){
            output$plot = renderPlotly({
                if(length(props$`anno-row`) == 0) {
                    row_side_colors = NULL
                } else if(length(props$`anno-row`) == 1 & props$`anno-row` == "null") {
                    row_side_colors = NULL
                } else {
                    row = props$`anno-row`
                    row = row[row != "null"]
                    row_side_colors = data.frame(props$data()$feature_data[,row])
                    colnames(row_side_colors) = row
                }
                if(length(props$`anno-col`) == 0) {
                    col_side_colors = NULL
                } else if(length(props$`anno-col`) == 1 & props$`anno-col` == "null") {
                    col_side_colors = NULL
                } else {
                    col = props$`anno-col`
                    col = col[col != "null"]
                    col_side_colors = data.frame(props$data()$sample_table[,col])
                    colnames(col_side_colors) = col
                }

                args = list(
                    x = props$data()$conc_table,
                    Rowv = props$Rowv,
                    Colv = props$Colv,
                    row_side_colors = row_side_colors,
                    col_side_colors = col_side_colors,
                    seriate = props$seriate,
                    row_text_angle = props$row_text_angle,
                    column_text_angle = props$column_text_angle
                )
                args = args[!sapply(args, is.null)]
                do.call(heatmaply, args)
            })
        },

        # call
        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
