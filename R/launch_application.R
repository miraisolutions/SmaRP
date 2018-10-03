#' SmaRP App Launcher
#' @description function to launch the SmaRP shiny app
#' @param ... additional arguments to be passed on to runApp
#' @return Side-effecting function. Launches SmaRP application.
#' @importFrom shiny runApp
#' @export
#' @examples
#' \dontrun{
#'   library(SmaRP); launch_application()
#' }
launch_application <- function(...) {
  runApp(appDir = system.file("application", package = "SmaRP"), ...)
}
