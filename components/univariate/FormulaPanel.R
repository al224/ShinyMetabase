import::here(VarSelect, .from="./VarSelect.R")

FormulaPanel = R6Class(
    "FormulaPanel",
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
                    title = tags$span(icon("cogs"), "Model Builder"),
                    solidHeader = TRUE,
                    status = "primary",
                    tags$p(
                        class = "font-weight-bold d-inline-block",
                        "Variable List"
                    ),
                    tags$div(
                        class="d-inline-block float-right",
                        actionButton(
                            ns("add-var"), "Add", class="btn-primary btn-sm"
                        )
                    ),
                    uiOutput(ns("vars-trs")),
                    actionButton(ns("vars-confirm"), "Confirm", class="btn-primary"),

                    tags$hr(),

                    tags$p(class="font-weight-bold", "Input a fomula"),
                    tags$div(
                        class = "row",
                        column(
                            width = 9,
                            textInput(ns("formula"), NULL,
                                      placeholder = "~ var1 + var2")
                        ),
                        column(
                            width = 3,
                            actionButton(ns("formula-save"), "Save", class="btn-primary")
                        )
                    ),

                    tags$p(class="font-weight-bold", "Select coefficient"),
                    tags$div(
                        class = "row",
                        column(
                            width = 9,
                            uiOutput(ns("coef-ui"))
                        ),
                        column(
                            width = 3,
                            actionButton(ns("coef-save"), "Save", class="btn-primary")
                        )
                    )
                )
            )
        },

        # server
        server = function(input, output, session, props){

            emit = reactiveValues(
                formula = NULL,
                coef = NULL,
                design = NULL
            )

            states = reactiveValues(
                varNum = 0,
                varNames = list(),
                varTypes = list(),
                varSelect = list()
            )

            observeEvent(input$`add-var`, {
                states$varNum = states$varNum + 1
                states$varSelect[[glue("var{states$varNum}")]] = VarSelect$new(
                    id = glue("var{states$varNum}"),
                    parent_id = NS(self$parent_id)(self$id),
                    data = props$data(),
                    varName = states$varNames[[glue("var{states$varNum}")]],
                    varType = states$varType[[glue("var{states$varNum}")]]
                )
            })

            output$`vars-trs` = renderUI({
                tags$table(
                    class="table",
                    tags$thead(
                        tags$tr(
                            tags$th(scope = "col", "var name"),
                            tags$th(scope = "col", "data type"),
                            tags$th(scope = "col")
                        )
                    ),
                    tags$tbody(
                        lapply(seq_len(states$varNum), function(i) {
                            states$varSelect[[glue("var{i}")]]$ui()
                        })
                    )
                )
            })

            observeEvent(input$`vars-confirm`, {
                for(i in seq_len(states$varNum)){
                    emitData = states$varSelect[[glue("var{i}")]]$call()
                    states$varNames[[glue("var{i}")]] = emitData$varName
                    states$varTypes[[glue("type{i}")]] = emitData$varType
                    states$varSelect[[glue("var{i}")]]$varName = emitData$varName
                    states$varSelect[[glue("var{i}")]]$varType = emitData$varType
                }
                showNotification("Variables confirmed!", type = "message")
            })

            observeEvent(input$formula, {
                removeClass("formula", class = "invalid")
            })

            output$`coef-ui` = renderUI({
                selectInput(
                    session$ns("coef"), NULL,
                    choices = colnames(emit$design)
                )
            })

            observeEvent(input$`formula-save`, {
                if(!self$formulaValidator(input$formula)){
                    addClass("formula", class = "invalid")
                } else {
                    formula = as.formula(input$formula)
                    invalidVar = self$variableValidator(formula, states$varNames)
                    if(length(invalidVar) != 0){
                        showNotification(
                            glue("Variable not confirmed: {paste(invalidVar, collapse = ', ')}"),
                            type = "error"
                        )
                    } else {
                        emit$formula = formula
                        emit$design = self$getDesignMatrix(
                            props$data(), states$varNames,
                            states$varTypes, formula
                        )
                    }
                }
            })

            observeEvent(input$`coef-save`, {
                emit$coef = input$`coef`
            })

            return(emit)
        },

        call = function(input, output, session, props){
            callModule(self$server, self$id, props)
        },

        formulaValidator = function(x){
            f = tryCatch({
                as.formula(x)
            }, error = function(e){
                return(e)
            })
            if(is(f, "error")){
                return(FALSE)
            } else if(length(f) != 2 & as.character(f[[1]]) != "~"){
                return(FALSE)
            } else {
                return(TRUE)
            }
        },

        variableValidator = function(formula, varNames){
            getVarsFromFormula = function(f){
                if(length(f) == 1){
                    return(as.character(f))
                } else if(length(f) == 2){
                    return(getVarsFromFormula(f[[2]]))
                } else if(length(f[[2]]) == 1){
                    if(length(f[[3]]) == 1){
                        return(as.character(c(f[[2]], f[[3]])))
                    } else {
                        return(c(as.character(f[[2]]), getVarsFromFormula(f[[3]])))
                    }
                }  else {
                    return(c(getVarsFromFormula(f[[2]]), getVarsFromFormula(f[[3]])))
                }
            }
            vars = getVarsFromFormula(formula)
            return(vars[which(vars %!in% varNames)])
        },

        getDesignMatrix = function(data, varNames, varTypes, formula){
            pdata = sample_table(data)
            pdata = as(pdata, "data.frame")
            for(i in seq_along(varNames)){
                changeType = switch(
                    varTypes[[i]],
                    "numeric" = as.numeric,
                    "factor" = factor
                )
                pdata[,varNames[[i]]] = changeType(pdata[,varNames[[i]]])
            }
            return(model.matrix(data = pdata, formula))
        }
    )
)
