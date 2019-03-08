import $ from 'jquery';
import cytoscape from 'cytoscape';
import cola from 'cytoscape-cola';
import coseBilkent from 'cytoscape-cose-bilkent';
import palette from 'google-palette';

import { layoutCose, layoutCola, layourCoseBilkent, layoutCoseBilkent } from './layouts'

cytoscape.use( cola )
cytoscape.use( coseBilkent )

Shiny.addCustomMessageHandler("cy-data", function(data) {
    // Get the nodes
    const nodes = [];
    for(let i = 0; i < data.nodes.id.length; i++){
        const newNode = { id: data.nodes.id[i] }
        if(data.nodes.color){
            newNode.color = data.nodes.color[i]
        }
        nodes.push( { data: newNode } )
    }
    console.log(nodes)
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
    console.log(edges)
    Shiny.addCustomMessageHandler("cy-params", function(params){
        // Get the style
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

        if(data.nodes.color){
            const colorLevels = [...new Set(data.nodes.color)]
            const colorPalette = palette(['mpn65'], colorLevels.length)
            for(let i = 0; i < colorLevels.length; i++){
                style.push({
                    selector: `node[color='${colorLevels[i]}']`,
                    style: {
                        'background-color': `#${colorPalette[i]}`
                    }
                })
            }
        }

        // Get layout
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

        const cy = cytoscape({
            container: $("#cy"),
            elements: {
                nodes,
                edges
            },
            layout,
            style
        });

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
    })
})
