NetworkTuning = R6Class(
    "NetworkTuning",
    inherit = ShinyModule,
    public = list(
        # attributes
        id = "network-tuning",
        parent_id = NULL,
        # initializer
        initialize = function(){

        },

        # UI
        ui = function(){
            ns = NS(self$id)
            tagList(
                column(
                    width = 12,
                    box(
                        width = NULL,
                        status = "primary",
                        title = "Parameters",
                        solidHeader = TRUE,

                        tags$div(
                            class = "col-xs-6 col-md-3",
                            radioButtons(
                                ns("param"), "The parameter to tune",
                                choices = c("lambda", "iter"),
                                inline = TRUE
                            )
                        ),

                        tags$div(
                            class = "col-xs-6 col-md-3",
                            uiOutput(ns("lambda-ui"))
                        ),

                        tags$div(
                            class = "col-xs-6 col-md-3",
                            uiOutput(ns("iter-ui"))
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
                        )
                    )
                ),
                column(
                    width = 12,
                    box(
                        width = NULL,
                        status = "primary",
                        title = "Plot",
                        solidHeader = TRUE,

                        tags$div(
                            class = "col-md-6 col-lg-4",
                            plotlyOutput(ns("plot1"))
                        ),
                        tags$div(
                            class = "col-md-6 col-lg-4",
                            plotlyOutput(ns("plot2"))
                        ),
                        tags$div(
                            class = "col-md-6 col-lg-4",
                            plotlyOutput(ns("plot3"))
                        )
                    )
                )
            )
        },

        # server
        server = function(input, output, session, props){
            observeEvent(input$param, {
                if(input$param == "lambda"){
                    output$`lambda-ui` = renderUI({
                        textInput(
                            session$ns("lambdas"),
                            "lambdas, separate by comma",
                            placeholder = "0.1,0.2,0.3,0.4"
                        )
                    })
                    output$`iter-ui` = renderUI({
                        numericInput(
                            session$ns("iter"), "Iter",
                            min = 1, max = 100, step = 1, value = 2
                        )
                    })
                } else {
                    output$`lambda-ui` = renderUI({
                        numericInput(
                            session$ns("lambda"), "lambda",
                            min = 0, max = 10, step = 0.01, value = 0.1
                        )
                    })
                    output$`iter-ui` = renderUI({
                        textInput(
                            session$ns("iters"),
                            "iters, separate by comma",
                            placeholder = "2,4,6,8"
                        )
                    })
                }
            })

            Data = reactive({
                apply(t(props$data()$conc_table), 2, scale)
            })

            observeEvent(input$submit, {
                showNotification(
                    "This could take a while..",
                    type = "warning"
                )
                if(input$param == "lambda"){
                    params = as.numeric(strsplit(input$lambdas, ",")[[1]])
                } else {
                    params = as.numeric(strsplit(input$iters, ",")[[1]])
                }
                if(!any(is.na(params))){
                    tuningRes = sapply(params, function(param){
                        args = list(Y.m = Data())
                        args$lam1 = ifelse(input$param == "lambda", param, input$lambda)
                        args$iter = ifelse(input$param == "lambda", input$iter, param)
                        spn = do.call(space.joint, args)
                        ParCor = spn$ParCor
                        for(i in seq_len(nrow(ParCor))){
                            ParCor[i,i] = 0
                        }
                        as.numeric(spn$ParCor)
                    }) %>% as.data.frame
                    colnames(tuningRes) = params
                    tuningRes = mutate(
                        tuningRes,
                        feat1 = rep(featureNames(props$data()), nfeatures(props$data())),
                        feat2 = rep(featureNames(props$data()), each = nfeatures(props$data()))
                    )
                    tuningRes = melt(tuningRes, id.vars = c("feat1", "feat2"))
                }
                output$plot1 = renderPlotly({
                    tuningRes %>%
                        ggplot(aes(x = variable, y = value)) +
                        geom_boxplot() +
                        geom_hline(yintercept = 1, color = "salmon", linetype = "dashed") +
                        geom_hline(yintercept = -1, color = "salmon", linetype = "dashed") +
                        labs(x = input$param, y = "parital correlation") +
                        theme_bw()
                })
                output$plot2 = renderPlotly({
                    tuningRes %>%
                        group_by(variable) %>%
                        summarize(filtered = mean(!between(value, -input$coef, input$coef))) %>%
                        ggplot() +
                        geom_col(aes(variable, filtered)) +
                        scale_y_continuous(limits = c(0,1)) +
                        labs(x = input$param, y = "%", title = glue("|coef| > {input$coef}")) +
                        theme_bw()
                })
                output$plot3 = renderPlotly({
                    tuningRes %>%
                        group_by(variable, feat1) %>%
                        summarize(filtered = sum(!between(value, -input$coef, input$coef)) > input$occur * 2) %>%
                        ungroup() %>% group_by(variable) %>%
                        summarize(num = sum(filtered)) %>%
                        ggplot() +
                        geom_col(aes(x = variable, y = num), width = 0.6) +
                        labs(x = input$param, y = "Number of features",
                             title = "Features selected") +
                        theme_bw()
                })
            })
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        }
    )
)
