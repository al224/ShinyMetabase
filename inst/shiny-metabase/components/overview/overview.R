import::here("SummaryPage", .from="./SummaryPage.R")
import::here("LoadDataPage", .from="./LoadDataPage.R")

TabOverview = R6Class(
    "TabOverview",
    inherit = ShinyModule,
    public = list(

        id = "overview",
        summaryPage = NULL,
        loadDataPage = NULL,

        initialize = function(){
            self$summaryPage = SummaryPage$new("summary", self$id)
            self$loadDataPage = LoadDataPage$new("load", self$id)
        },

        ui = function(){
            tagList(
                self$loadDataPage$ui(),
                self$summaryPage$ui()
            )
        },

        server = function(input, output, session){

            emit = reactiveValues(
                data = reactive({return(NULL)})
            )

            if("data" %in% ls(.GlobalEnv)){
                emit$data = reactive({ .GlobalEnv[["data"]] })
            } else {
                emit$data = reactive({return(NULL)})
            }

            #slogjs(outsideData)

            loadData = self$loadDataPage$call()

            observe({
                if(!is.null(loadData$data())){
                    emit$data = reactive({
                        loadData$data()
                    })
                }
            })

            observe({
                if(!is.null(emit$data())){
                    self$summaryPage$call(props = emit)
                }
            })

            return(emit)
        }
    )
)
