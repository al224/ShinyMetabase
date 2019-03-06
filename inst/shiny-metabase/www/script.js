$(document).on('shiny:connected',function(){
    console.log("Hello")
    $("#normality-msg-foo").change(function(){
        console.log(Shiny.shinyapp.$inputValues)
    })
})
