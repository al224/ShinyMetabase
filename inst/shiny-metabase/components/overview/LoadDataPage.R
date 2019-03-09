LoadDataPage = R6Class(
    "LoadDataPage",
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
                tags$section(
                    class = "col",
                    tags$div(
                        class = "col-sm-12",
                        box(
                            width = NULL,
                            title = tags$span(icon("cloud-upload-alt"), "Load Data"),
                            solidHeader = TRUE,
                            status = "primary",

                            tags$div(
                                id=ns("data-loader"),
                                tags$div(
                                    id=ns("conc-input"),
                                    class="file-input-container",
                                    fileInput(
                                        ns("conc"), "Upload the conc data",
                                        width = "33%",
                                        accept = c(
                                            "text/csv",
                                            "text/comma-separated-values,text/plain",
                                            ".csv"
                                        )
                                    )
                                ),
                                tags$div(
                                    id=ns("feat-input"),
                                    class="file-input-container",
                                    fileInput(
                                        ns("feat"), "Upload the feature data",
                                        width = "33%",
                                        accept = c(
                                            "text/csv",
                                            "text/comma-separated-values,text/plain",
                                            ".csv"
                                        )
                                    )
                                ),
                                tags$div(
                                    id=ns("samp-input"),
                                    class="file-input-container",
                                    fileInput(
                                        ns("samp"), "Upload the sample data",
                                        width = "33%",
                                        accept = c(
                                            "text/csv",
                                            "text/comma-separated-values,text/plain",
                                            ".csv"
                                        )
                                    )
                                )
                            ),
                            checkboxInput(ns("feat-in-rows"), "Features are rows", value = TRUE),
                            actionButton(ns("save"), "Save", class = "btn-primary")
                        )
                    )
                )
            )
        },

        # server
        server = function(input, output, session){

            states = reactiveValues(
                conc_table = NULL,
                feature_data = NULL,
                sample_table = NULL
            )

            emit = reactiveValues(
                data = reactive({return(NULL)})
            )

            # FIXME the file type validation is not fully implemented
            observeEvent(input$conc,{
                if(!grepl("csv$", input$conc$name)) {
                    showNotification("Must be a csv file", type="error")
                    session$sendCustomMessage("fileInputInvalid", list(
                        table = "conc"
                    ))
                    #js$addInvalid("conc")
                } else {
                    tryCatch({
                        conc_table = read.csv(
                            input$conc$datapath, header = TRUE, row.names = 1
                        )
                        conc_table = as.matrix(conc_table)
                        if(!input$`feat-in-rows`){
                            conc_table = t(conc_table)
                        }
                        states$conc_table = conc_table
                        session$sendCustomMessage("fileInputValid", list(
                            table = "conc"
                        ))
                    }, error = function(e){
                        showNotification("Must be a csv file", type = "error")
                        session$sendCustomMessage("fileInputInvalid", list(
                            table = "conc"
                        ))
                    })
                }
            })

            observeEvent(input$feat, {
                if(!grepl("\\.csv$", input$feat$name)) {
                    showNotification("Must be a csv file", type = "error")
                    session$sendCustomMessage("fileInputInvalid", list(
                        table = "feat"
                    ))
                    #js$addInvalid("feat")
                } else {
                    tryCatch({
                        states$feature_data = read.csv(
                            input$feat$datapath, header = TRUE, row.names = 1
                        )
                        session$sendCustomMessage("fileInputValid", list(
                            table = "feat"
                        ))
                    }, error = function(e){
                        showNotification("Must be a csv file", type="error")
                        session$sendCustomMessage("fileInputInvalid", list(
                            table = "feat"
                        ))
                    })
                }
            })

            observeEvent(input$samp, {
                if(!grepl("\\.csv$", input$samp$name)) {
                    showNotification("Must be a csv file", type = "error")
                    session$sendCustomMessage("fileInputInvalid", list(
                        table = "samp"
                    ))
                    #js$addInvalid("samp")
                } else {
                    tryCatch({
                        states$sample_table = read.csv(
                            input$samp$datapath, header = TRUE, row.names = 1
                        )
                        session$sendCustomMessage("fileInputValid", list(
                            table = "samp"
                        ))
                    }, error = function(e){
                        showNotification("Must be a csv file", type = "error")
                        session$sendCustomMessage("fileInputInvalid", list(
                            table = "samp"
                        ))
                    })
                }
            })

            observe({
                if(!is.null(states$conc_table) & !is.null(states$sample_table) &
                   !is.null(states$feature_data)) {
                    enable("save")
                } else {
                    disable("save")
                }
            })

            observeEvent(input$save, {
                if(!is.numeric(states$conc_table)){
                    showNotification(
                        h5("conc_table is not pure numeric"),
                        type = "error"
                    )
                    return()
                }

                if(ncol(states$conc_table) != nrow(states$sample_table)) {
                    showNotification(
                        h5("Sample number must be consistent"),
                        type = "error"
                    )
                    return()
                }
                if(nrow(states$conc_table) != nrow(states$feature_data)) {
                    showNotification(
                        h5("Feature number must be consistent"),
                        type = "error"
                    )
                    return()
                }
                if(any(colnames(states$conc_table) != rownames(states$sample_table))) {
                    showNotification(
                        h5("Must have the same sample names"),
                        type = "error"
                    )
                    return()
                }
                if(any(rownames(states$conc_table) != rownames(states$feature_data))) {
                    showNotification(
                        h5("Must have the same feature names"),
                        type = "error"
                    )
                    return()
                }

                conc_table = conc_table(states$conc_table)
                sample_table = sample_table(states$sample_table)
                feature_data = feature_data(states$feature_data)
                mset = MetabolomicsSet(conc_table, sample_table, feature_data)

                emit$data = reactive({
                    mset
                })
            })

            return(emit)
        }
    )
)
