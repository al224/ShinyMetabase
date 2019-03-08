SideBar = R6Class(
    "SideBar",
    inherit = ShinyModule,
    list(
        ui = function(){
            dashboardSidebar(
                sidebarMenu(
                    id = "tabs",
                    menuItem(
                        "Overview", tabName = "tab_overview", icon = icon("tachometer-alt")
                    ),
                    menuItem(
                        "Normality", tabName = "tab_normality", icon = icon("balance-scale")
                    ),
                    menuItem(
                        "Univariate", tabName = "tab_univariate", icon = icon("cube")
                    ),
                    menuItem(
                        "Multivariate", tabName = "tab_multivariate", icon = icon("cubes")
                    ),
                    menuItem(
                        "Network", icon = icon("wifi"),
                        menuSubItem(
                            "Parameter Tuning", tabName = "tab_network_tuning"
                        ),
                        menuSubItem(
                            "Network Visualization", tabName = "tab_network_visual"
                        )
                    )
                )
            )
        }
    )
)
