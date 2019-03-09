$(document).on('shiny:connected',function(){
    Shiny.addCustomMessageHandler("dataNotLoaded", function(e){
        console.log(e)
        e.tabs.forEach(tab => {
            disableTab(tab)
        })
    })
    Shiny.addCustomMessageHandler("dataLoaded", function(e){
        e.tabs.forEach(tab => {
            enableTab(tab)
        })
    })
    Shiny.addCustomMessageHandler("fileInputInvalid", function(e){
        console.log(e)
        console.log("conc")
        $(`#overview-load-${e.table}-input input[type='text']`)
            .addClass('invalid')
        $(`#overview-load-${e.table}-input .input-group`)
            .addClass('invalid')
    })

    Shiny.addCustomMessageHandler("fileInputValid", function(e){
        $(`#overview-load-${e.table}-input input[type='text']`)
            .removeClass('invalid')
        $(`#overview-load-${e.table}-input .input-group`)
            .removeClass('invalid')
    })
})

const disableTab = function(name){
    const tab = $('a[data-value=' + name + ']');
    tab.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
    });
    tab.addClass('disabled');
}

const enableTab = function(name){
    const tab = $('a[data-value=' + name + ']');
    tab.unbind('click.tab');
    tab.removeClass('disabled');
}