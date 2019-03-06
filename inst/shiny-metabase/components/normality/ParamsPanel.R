ParamsPanel = R6Class(
    "ParamsPanel",
    inherit = ShinyModule,
    public = list(
        id = NULL,
        parent_id = NULL,
        initialize = function(id, parent_id = NULL){
            self$id = id
            self$parent_id = parent_id
        },
        ui = function(){
            ns = NS(NS(self$parent_id)(self$id))
            tagList(
                box(
                    width = NULL, status = "primary",
                    solidHeader = TRUE,
                    title = tags$span(icon("list-alt"), "Normalization Parameters"),

                    radioButtons(
                        ns("normal"),
                        "Normalization Method:",
                        inline = TRUE,
                        choices = c(
                            "none",
                            "log2",
                            "log10",
                            "log2(x + 1)",
                            "log10(x + 1)"
                        ),
                        selected = "none"
                    ),

                    tags$hr(),
                    radioButtons(
                        ns("transform"),
                        "Data Transformation",
                        inline = TRUE,
                        choices = c(
                            "none",
                            "percentage",
                            "feature-wise z-score transformation",
                            "sample-wise z-score transformation"
                        ),
                        selected = "none"
                    ),

                    tags$hr(),
                    actionButton(ns("save"), "Save", class="btn-primary")
                )
            )
        },
        server = function(input, output, session, props){
            emit = reactiveValues(
                data = reactive({
                    props$data()
                })
            )

            observeEvent(input$save, {
                transform_func = switch(
                    input$transform,
                    "none" = self$getUnchanged,
                    "percentage" = self$getPercentage,
                    "feature-wise z-score transformation" = self$getZScored("feature"),
                    "sample-wise z-score transformation" = self$getZScored("sample")
                )
                normal_func = switch(
                    input$normal,
                    "none" = self$getUnchanged,
                    "log2" = log2,
                    "log10" = log10,
                    "log2(x + 1)" = function(x) {log2(x + 1)},
                    "log10(x + 1" = function(x) {log10(x + 1)}
                )
                norm_data = transform_func(props$data())
                norm_data$conc_table = normal_func(norm_data$conc_table)
                emit$data = reactive({ norm_data })
                showNotification("Normalization saved", type = "message")
            })

            return(emit)
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        },

        getUnchanged = function(x){
            return (x)
        },
        getPercentage = function(object){
            transform_by_sample(object, function(col){
                col / sum(col)
            })
        },
        getZScored = function(dim){
            dim = switch(
                dim,
                "feature" = 1,
                "sample" = 2
            )
            function(object){
                conc_table = object$conc_table
                conc_table = apply(conc_table, dim, scale)
                if(dim == 1){
                    conc_table = t(conc_table)
                }
                rownames(conc_table) = featureNames(object)
                colnames(conc_table) = sampleNames(object)
                conc_table = conc_table(conc_table)
                object$conc_table = conc_table
                return(object)
            }
        }
    )
)
