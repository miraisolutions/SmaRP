# TODO: document, including man-roxygen/ex-SmaRPanel.R
#' @export
SmaRPanel <- function(id, ..., title = NULL, collapsed = NA) {
  # we can add footer if needed

  # append -smarp to the first class
  .class <- function(x) paste(x, sub("^([^ ]+).*$", "\\1-smarp", x), sep = " ")
  # specific ids within the panel id
  .with_id <- function(x) paste(id, x, sep = "-")

  heading <- if (!is.null(title) || !is.na(collapsed)) {
    htmltools::tags$div(
      id = .with_id("heading"),
      class = .class("panel-heading"),
      htmltools::tags$div(
        class = .class("panel-title"),
        title,
        if (!is.na(collapsed)) {
          shiny::actionButton(.with_id("collapse"), NULL) %>%
            bsplus::bs_attach_collapse(.with_id("body")) %>%
            # class for styling expand / collapse button
            htmltools::tagAppendAttributes(class = paste(
              "btn-collapse",
              if (isTRUE(collapsed)) "collapsed")
            )
        }
      )
    )
  }

  body <-
    # div wrapper similar to bsplus::bs_collapse()
    htmltools::tags$div(
      id = .with_id("body"),
      class = paste(
        if (!is.na(collapsed)) "collapse",
        if (isTRUE(!collapsed)) "in"
      ),
      htmltools::tags$div(
        class = .class("panel-body"),
        ...
      )
    )

  htmltools::tags$div(
    id = id,
    class = .class("panel panel-default"),
    heading,
    body
  )

}
