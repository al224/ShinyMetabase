const path = require('path');

module.exports = {
    entry: './srcjs/index.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'inst/shiny-metabase/www/cytoscape')
    }
}