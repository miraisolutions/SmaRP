#' @title SmaRP version
#'
#' @rdname get_SmaRP_version
#'
#' @description Returns the version of the installed SmaRP package and app.
#'
#' @return The version of SmaRP as character string.
#'
#' @export
get_SmaRP_version <- function() {
  as.character(utils::packageVersion("SmaRP"))
}
