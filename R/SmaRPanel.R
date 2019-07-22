#' @title SmaRPanel
#'
#' @rdname SmaRPanel
#'
#' @description Custom collapsible panel for the SmaRP Shiny app.
#'
#' @param id The unique id of the panel.
#' @param ... UI elements to be displayed in the panel body.
#' @param title The title to be displayed in the panel heading.
#' @param collapsed Whether the panel should be created as collapsed or
#'   expanded. If `NA` (the default), a non-collapsible panel is created.
#'
#' @details All elements of the panel are specified with additional classes
#'   `"panel-smarp"`, `"panel-heading-smarp"`, `"panel-title-smarp"`,
#'   `"panel-body-smarp"`, used for CSS customization. Similarly, the collapse
#'   [actionButton()] is defined with no `label` nor `icon` and has a custom
#'   class `"btn-collapse-smarp"`, to be used for CSS customization via the
#'   `:after` pseudo-element.
#'
#' @return The UI definition of the panel.
#'
#' @example man-roxygen/ex-SmaRPanel.R
#'
#' @export
#'
#' @md
SmaRPanel <- function(id, ..., title = NULL, collapsed = NA) {
  # we can add footer if needed

  tags <- htmltools::tags

  # append -smarp to the first class
  .class <- function(x) paste(x, sub("^([^ ]+).*$", "\\1-smarp", x), sep = " ")
  # specific ids within the panel id
  .with_id <- function(x) paste(id, x, sep = "-")

  heading <- if (!is.null(title) || !is.na(collapsed)) {
    tags$div(
      id = .with_id("heading"),
      class = .class("panel-heading"),
      tags$div(
        class = .class("panel-title"),
        title,
        if (!is.na(collapsed)) {
          shiny::actionButton(.with_id("collapse"), NULL) %>%
            bsplus::bs_attach_collapse(.with_id("body")) %>%
            # class for styling expand / collapse button
            htmltools::tagAppendAttributes(class = paste(
              .class("btn-collapse"),
              if (isTRUE(collapsed)) "collapsed")
            )
        }
      )
    )
  }

  body <- tags$div(
    # div wrapper similar to bsplus::bs_collapse()
    id = .with_id("body"),
    class = paste(
      if (!is.na(collapsed)) "collapse",
      if (isTRUE(!collapsed)) "in"
    ),
    tags$div(
      class = .class("panel-body"),
      ...
    )
  )

  tags$div(
    id = id,
    class = .class("panel panel-default"),
    heading,
    body
  )

}
