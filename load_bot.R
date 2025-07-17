#' Run the Shiny Application
#'
#' @param ... Additional arguments passed to shinyApp()
#' @export
load_bot <- function(...) {
  shiny::shinyApp(ui = app_ui, server = app_server, ...)
}
