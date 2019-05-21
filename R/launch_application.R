#' @title launch_application
#'
#' @rdname launch_application
#'
#' @description Launch the SmaRP Shiny wep app.
#'
#' @inheritParams shiny::runApp
#' @param ... Additional arguments passed on to [runApp()].
#'
#' @return Side-effecting function. Launches the SmaRP app.
#'
#' @examples
#' if (interactive()) {
#'   SmaRP::launch_application()
#' }
#' @importFrom shiny runApp
#' @export
launch_application <- function(launch.browser = interactive(), ...) {
  runApp(
    appDir = system.file("application", package = "SmaRP"),
    launch.browser = launch.browser,
    ...
  )
}
