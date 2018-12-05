#' SmaRP App Launcher
#'
#' Launch the SmaRP Shiny wep app.
#'
#' @param ... Additional arguments passed on to [runApp()]. Note that
#'   argument `launch.browser` is always passed as `TRUE`.
#'
#' @return Side-effecting function. Launches the SmaRP app.
#'
#' @examples
#' if (interactive()) {
#'   SmaRP::launch_application()
#' }
#' @importFrom shiny runApp
#' @export
launch_application <- function(...) {
  runApp(
    appDir = system.file("application", package = "SmaRP"),
    launch.browser = TRUE,
    ...
  )
}
