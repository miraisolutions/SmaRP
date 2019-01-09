#' @title get_SmaRP_version
#' 
#' @rdname get_SmaRP_version
#' 
#' @description Automatically update SmaRP version.
#' 
#' @return Current SmaRP version.
#' @export
get_SmaRP_version <- function() {
  as.character(utils::packageVersion("SmaRP"))
}