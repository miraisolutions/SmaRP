#' @title withModalSpinner
#' 
#' @rdname withModalSpinner 
#'
#' @description Display a modal window with a spinning wheel and an information message
#' while a (time-consuming) expression is evaluated.
#'
#' @param expr The `expression` to be evaluated.
#' @param info The information message to be displayed.
#' @param spinner The spinning wheel icon.
#' @inheritParams shiny::modalDialog
#'
#' @example man-roxygen/ex-withModalSpinner.R
#'
#' @export
#'
#' @md
withModalSpinner <- function(expr, info,
                             spinner = icon("spinner", "fa-spin"),
                             size = "m") {
  showModal(
    modalDialog(
      h4(spinner, info),
      footer = NULL,
      size = size
    )
  )
  force(expr)
  removeModal()
}
