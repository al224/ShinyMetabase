import $ from 'jquery';
import cytoscape from 'cytoscape';
import cola from 'cytoscape-cola';
import coseBilkent from 'cytoscape-cose-bilkent';
import palette from 'google-palette';

import { layoutCose, layoutCola, layourCoseBilkent, layoutCoseBilkent } from './layouts'

cytoscape.use( cola )
cytoscape.use( coseBilkent )

let cy, params

Shiny.addCustomMessageHandler("cyDataSubmited", function(data) {
    // Get the nodes
    const nodes = [];
    for(let i = 0; i < data.nodes.id.length; i++){
        const newNode = { id: data.nodes.id[i] }
        if(data.nodes.color){
            newNode.color = data.nodes.color[i]
        }
        nodes.push( { data: newNode } )
    }
    // Get the edges
    const edges = [];
    const edgeValues = data.edges.value
    for(let i = 0; i < data.edges.id.length; i++){
        edges.push({
            data: { 
                id: data.edges.id[i],
                source: data.edges.source[i],
                target: data.edges.target[i],
                sign: data.edges.sign[i],
                value: edgeValues[i],
                weight: (edgeValues[i] - Math.min(...edgeValues)) / (Math.max(...edgeValues) - Math.min(...edgeValues)) 
            }
        })
    }
    // Get the style
    params = data.params
    const style = [
        {
            selector: 'node',
            style: {
                'label': 'data(id)',
                'width': params['node-size'],
                'height': params['node-size']
            }
        },
        {
            selector: 'edge[sign="positive"]',
            style: {
                'line-color': '#1962c2'
            }
        },
        {
            selector: 'edge[sign="negative"]',
            style: {
                'line-color': '#cc4d2d'
            }
        },
        {
            selector: 'edge',
            style: {
                'width': function(ele){
                    return ele.data("weight") * params["edge-width-scale"] + 1
                }
            }
        }
    ]
    console.log("0")
    if(data.nodes.color){
        console.log("1")
        const colorLevels = [...new Set(data.nodes.color)]
        console.log("2")
        const colorPalette = palette(['mpn65'], colorLevels.length)
        console.log("3")
        style.push({
            selector: 'node',
            style: {
                'background-color': function(ele){
                    return '#' + colorPalette[colorLevels.indexOf(ele.data("color"))]
                }
            }
        })
        console.log(4)
    }

    // Get layout
    const layout = makeLayout()

    cy = cytoscape({
        container: $("#cy"),
        elements: {
            nodes,
            edges
        },
        layout,
        style
    });

    addNodeTooltips()
    addEdgeTooltips()
    console.log(cy.nodes()[0])
    console.log(cy.nodes()[0].data())
})

Shiny.addCustomMessageHandler("cyNodeColorUpdate", function(data){
    if(cy !== undefined){
        for(let i = 0; i < data.color.length; i++){
            cy.nodes()[i].data().color = data.color[i]
        }
        const colorLevels = [...new Set(data.color)]
        console.log(colorLevels)
        const colorPalette = palette(['mpn65'], colorLevels.length)
        cy.style()
            .selector('node')
            .style('background-color', function(ele){
                return '#' + colorPalette[colorLevels.indexOf(ele.data("color"))]
            })
            .update()

        console.log(cy.nodes()[0].data())
        addNodeTooltips()
    }
})

Shiny.addCustomMessageHandler("cyEdgeWidthUpdate", function(data){
    if(cy !== undefined){
        cy.style()
            .selector('edge')
            .style('width', function(ele){
                return ele.data("weight") * data["edge-width-scale"] + 1
            })
            .update()
    }
})

Shiny.addCustomMessageHandler("cyNodeSizeUpdate", function(data){
    if(cy !== undefined){
        cy.style()
            .selector('node')
            .style('width', data['node-size'])
            .style('height', data['node-size'])
            .update()
    }
})

Shiny.addCustomMessageHandler("cyLayoutTypeUpdate", function(data){
    if(cy !== undefined){
        params.layout = data.layout
        params['edge-length-scale'] = data['edge-length-scale']
        const layout = makeLayout()
        const ly = cy.layout(layout)
        ly.run()
    }
})

const addNodeTooltips = function(){
    cy.nodes().removeListener('mouseover')
    cy.nodes().removeListener('mouseout')
    cy.nodes().on('mouseover', function(e){
        const tooltip = $("#cy-tooltip")
        let tooltipContent = `<strong>id:</strong> ${e.target.id()} <br/>`
        //tooltip.css("height", "28px")
        if(e.target.data("color")){
            tooltipContent += `<strong>color:</strong> ${e.target.data("color")}`
            //tooltip.css("height", "48px")
        }
        tooltip.html(tooltipContent)
        tooltip.toggle()
        tooltip.css("left", `${e.target.renderedPosition().x + params["node-size"]/2}px`)
        tooltip.css("top", `${e.target.renderedPosition().y - params["node-size"]/2 - 20}px`)
    })
    cy.nodes().on('mouseout', function(e){
        $("#cy-tooltip").toggle()
    })
}

const addEdgeTooltips = function(){
    cy.edges().removeListener('mouseover')
    cy.edges().removeListener('mouseout')
    cy.edges().on('mouseover', function(e){
        const tooltip = $("#cy-tooltip")
        const sign = e.target.data("sign") === "positive" ? 1 : -1
        let tooltipContent = `
            <strong>source:</strong> ${e.target.data("source")} <br/>
            <strong>target:</strong> ${e.target.data("target")} <br/>
            <strong>value:</strong> ${e.target.data("value").toPrecision(5) * sign} <br/>
        `
        tooltip.html(tooltipContent)
        tooltip.toggle()
        tooltip.css("left", `${e.renderedPosition.x}px`)
        tooltip.css("top", `${e.renderedPosition.y - 20}px`)
        tooltip.css("height", "60px")
    })

    cy.edges().on('mouseout', function(e){
        $("#cy-tooltip").toggle()
    })
}

const makeLayout = function(){
    let layout
    if(params.layout === "cose"){
        layout = layoutCose
    } else if(params.layout === "cola"){
        layout = layoutCola
    } else if(params.layout === "cola-edge-weighted"){
        layout = layoutCola
        layout.edgeLength = function(edge){
            return params["edge-length-scale"] / edge.data("value")
        }
    } else if(params.layout === "cose-bilkent"){
        layout = layoutCoseBilkent
    }
    return layout
}