# function to launch the SmaRP shiny app
#' @name launch_application
#' @examples
#' \dontrun{
#'   library(SmaRP); launch_application()
#' }
#' @export
launch_application <- function(...) {
  shiny::runApp(appDir = system.file("application", package = "SmaRP"),
                ...)
}
