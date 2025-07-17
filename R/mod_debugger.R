library(promises)
#' debugger UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom promises %...>% %...!%
mod_debugger_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinyjs::useShinyjs(),
    sidebarLayout(
      sidebarPanel(
        helpText("Paste your R code below. The app will provide debugging guidance."),
        textAreaInput(ns("code_input"), "Your R Code:", rows = 10),
        textAreaInput(ns("query"), "Your question about this code:", rows = 10),
        actionButton(ns("check_btn"), "Check My Code")
      ),
      mainPanel(
        h4("AI Debugging Guidance"),
        textOutput(ns("loading_status")),
        div(
          style = "
            max-width: 600px;
            overflow-y: auto;
            font-family: monospace;
            font-size: 14px;",
          pre(
            textOutput(ns("gpt_output")),
            style = "
              white-space: pre-wrap;
              word-break: break-word;
              overflow-wrap: break-word;
              word-wrap: break-word;
              margin: 0;"
          )
        )
      )
    )
  )
}

#' debugger Server Functions
#'
#' @noRd
mod_debugger_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    gpt_result <- reactiveVal("")
    output$loading_status <- renderText({ "" })

    observeEvent(input$check_btn, {
      req(input$code_input, input$query)

      shinyjs::disable("check_btn")
      output$gpt_output <- renderText({ "" })
      output$loading_status <- renderText({ "🧠 Thinking..." })

      # Delay to let the UI render the status
      shinyjs::delay(100, {
        code_val <- input$code_input
        query_val <- input$query
        api_key_val <- Sys.getenv("OPENAI_API_KEY")

        future::future({
          ask_gpt_debugger(code_val, query_val, api_key_val)
        }) %...>% {
          gpt_result(.)
          output$gpt_output <- renderText({ gpt_result() })
          output$loading_status <- renderText({ "" })
          shinyjs::enable("check_btn")
        } %...!% {
          output$gpt_output <- renderText({ "❌ There was an error contacting the AI." })
          output$loading_status <- renderText({ "" })
          shinyjs::enable("check_btn")
        }
      })
    })
  })
}

## To be copied in the UI
# mod_debugger_ui("debugger_1")

## To be copied in the server
# mod_debugger_server("debugger_1")
