.onLoad <- function(libname, pkgname) {
  # https://github.com/ebailey78/shinyBS/issues/100
  shiny::addResourcePath("sbs", system.file("www", package = "shinyBS"))
}
