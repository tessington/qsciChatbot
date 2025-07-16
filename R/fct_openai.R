#' Call GPT API for debugging assistance
#' @param code The student's R code
#' @param query The user's question
#' @param api_key Your OpenAI key (fetched with Sys.getenv)
#' @return GPT's response text
ask_gpt_debugger <- function(code, query, api_key) {
  prompt <- paste(
    "You are an R programming tutor. A student wrote the following question:\n\n",
    query, "\n\n regarding the following code:",
    code,
    "\n\nYour job is not to write, fix or rewrite  code, but to support the student in learning and understanding how to code for quantitative ecology. If they share code, then:
1. First, run the code to see whether it returns errors or warnings.
2. If it is correct, acknowledge that it works, and offer professional congratulations.  Identify one or two ways where the student successefully coded things.
3. If the code has a potential issue, identify the problem and suggest a way to fix it.
4. Keep your tone friendly, encouraging, and curious — like a good teaching assistant."
    ,
    sep = ""
  )

  response <- httr::POST(
    url = "https://api.openai.com/v1/chat/completions",
    httr::add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = jsonlite::toJSON(list(
      model = "gpt-4o",
      messages = list(
        list(role = "system", content = "You are a helpful R programming tutor who never writes or fixes code. You give suggestions on lines of code and give minimal worked examples"),
        list(role = "user", content = prompt)
      ),
      temperature = 0.7
    ), auto_unbox = TRUE)
  )

  parsed <- httr::content(response, as = "parsed")
  if (!is.null(parsed$choices)) {
    return(parsed$choices[[1]]$message$content)
  } else {
    return("Sorry, I couldn't get a response from the AI.")
  }
}
