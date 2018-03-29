# function to launch the SmaRP shiny App
#' @name launch_application
#' @example library(SmaRP) launch_application(...)
#' @export

launch_application <- function(x, ...)
{
  shiny::runApp(appDir = system.file("application", package = "SmaRP"), 
                ...)
}