TabNetwork = R6Class(
    "TabNetwork",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = "network",
        # initializer
        initialize = function(){
            ns = NS(self$id)
        },

        # UI
        ui = function(){
            ns = NS(self$id)
            tagList(
                tags$div(
                    class = "col",
                    column(
                        width = 12,
                        box(
                            width = NULL,
                            status = "primary",
                            solidHeader = TRUE,
                            title = tags$span(icon("wrench"), "Partial Correlation Settings"),
                            collapsible = TRUE,

                            # tags$div(
                            #     class = "col-xs-6 col-sm-4 col-md-3 col-lg-2",
                            #     selectInput(
                            #         ns("corr-method"), "Correlation method",
                            #         choices = c(
                            #             "Pearson's correlation",
                            #             "Spearman's correlation",
                            #             "Partial correlation"
                            #         ),
                            #         selected = "Partial correlation",
                            #     )
                            # ),
                            tags$div(
                                class = "col",
                                tags$h5(
                                    class = "font-weight-bold",
                                    "Partial correlation parameters"
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                numericInput(
                                    ns("lambda"), "lambda",
                                    min = 0, max = 1, value = 0.625, step = 0.1
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                numericInput(
                                    ns("iter"), "iter",
                                    min = 1, max = 100, value = 2, step = 1
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                numericInput(
                                    ns("coef"), "Coefficient cutoff",
                                    min = 0, max = 1, step = 0.01, value = 0.3
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                numericInput(
                                    ns("occur"), "Minimal occurance",
                                    min = 0, max = 100, step = 1, value = 4
                                )
                            ),

                            tags$div(
                                class = "col",
                                actionButton(ns("submit"), "Submit", class="btn-primary")
                            ),

                            tags$hr(),
                            tags$div(
                                class = "col",
                                tags$h5(
                                    class = "font-weight-bold",
                                    "Aesthetic parameters"
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                uiOutput(ns("node-color-ui"))
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                selectInput(
                                    ns("layout"), "Layout",
                                    choices = c(
                                        "cose",
                                        "cola",
                                        "cola-edge-weighted",
                                        "cose-bilkent"
                                    )
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                numericInput(
                                    ns("edge-length-scale"), "Edge length scale",
                                    min = 30, max = 1000, value = 60, step = 1
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3 ",
                                numericInput(
                                    ns("edge-width-scale"), "Edge width scale",
                                    min = 1, max = 100, value = 20
                                )
                            ),

                            tags$div(
                                class = "col-xs-6 col-md-3",
                                numericInput(
                                    ns("node-size"), "Node size",
                                    min = 1, max = 100, value = 20, step = 1
                                )
                            )
                        )
                    ),
                    column(
                        width = 12,
                        box(
                            width = NULL,
                            title = tags$span(icon("wifi"), "Network"),
                            status = "primary",
                            solidHeader = TRUE,
                            tags$span(id="cy-tooltip", class="tooltip"),
                            shinyjqui::jqui_resizable(
                                tags$div(
                                    class = "cy-container",
                                    tags$div( id = "cy" )
                                )
                            )
                        )
                    )
                )
            )
        },

        # server
        #' @props data, reactive that returns the data
        server = function(input, output, session, props){

            states = reactiveValues(
                id = NULL
            )

            observe({

                output$`node-color-ui` = renderUI({
                    choices = list("-- please select --" = "null")
                    for (item in colnames(feature_data(props$data()))){
                        choices[[item]] = item
                    }
                    selectInput(
                        session$ns("node-color"), "Node color",
                        choices = choices
                    )
                })
            })

            observeEvent(input$submit, {
                # Partical correlation
                Data = apply(t(props$data()$conc_table), 2, scale)
                spn = space.joint(Data, input$lambda, iter = input$iter)
                spn_cor = spn$ParCor
                colnames(spn_cor) = colnames(Data)
                rownames(spn_cor) = colnames(Data)
                id = apply(spn_cor, 2, function(x) {sum(!between(x, -input$coef, input$coef)) > input$occur})
                states$id = id
                mat = spn_cor[id, id]
                mat[between(mat, -input$coef, input$coef)] = 0
                mat[do.call(c, lapply(1:nrow(mat), function(x) (1:x) + nrow(mat) * (x-1)))] = 0
                # Node list
                nodes = list(id = colnames(mat))
                if(input$`node-color` != "null") {
                    color = props$data()$feature_data[id, input$`node-color`]
                    if(length(unique(color)) > 65 ){
                        showNotification("The node color variable has too many levels")
                    } else {
                        nodes$color = color
                    }
                }
                # edge list
                edges = melt(mat) %>% filter(value != 0)
                colnames(edges)[1:2] = c("source", "target")
                edges$sign = ifelse(
                    edges$value > 0, "positive",
                    ifelse(edges$value < 0, "negative", "")
                )

                edges$value = abs(edges$value)
                #edges$value = (edges$value - min(edges$value)) / (max(edges$value) - min(edges$value))
                #edges$value = edges$value * input$`edge-width` + 1
                edges$id = with(edges, glue("{source}-{target}"))

                # params
                params = list(
                    layout = input$layout,
                    "node-size" = input$`node-size`,
                    "edge-width-scale" = input$`edge-width-scale`,
                    "edge-length-scale" = input$`edge-length-scale`
                )

                session$sendCustomMessage("cyDataSubmited", list(
                    nodes = nodes,
                    edges = edges,
                    params = params
                ))
            })

            observeEvent(input$`node-color`, {
                if(input$`node-color` != "null" & !is.null(states$id)){
                    session$sendCustomMessage("cyNodeColorUpdate", list(
                        color = props$data()$feature_data[states$id, input$`node-color`]
                    ))
                }
            })

            observeEvent(input$`edge-width-scale`, {
                if(!is.null(states$id)){
                    session$sendCustomMessage("cyEdgeWidthUpdate",list(
                        "edge-width-scale" = input$`edge-width-scale`
                    ))
                }
            })

            observeEvent(input$`node-size`, {
                if(!is.null(states$id)){
                    session$sendCustomMessage("cyNodeSizeUpdate", list(
                        "node-size" = input$`node-size`
                    ))
                }
            })

            observeEvent({
                input$layout
                input$`edge-length-scale`
            }, {
                if(!is.null(states$id)){
                    messageData = list(
                        "layout" = input$layout
                    )
                    if(input$layout == "cola-edge-weighted"){
                        messageData$`edge-length-scale` = input$`edge-length-scale`
                    }
                    session$sendCustomMessage("cyLayoutTypeUpdate", messageData)
                }
            })

        },

        call = function(input, output, sessiont, props){
            callModule(self$server, self$id, props)
        }
    )
)
