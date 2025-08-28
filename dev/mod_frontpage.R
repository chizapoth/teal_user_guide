# MVP for scatterplot, using IRIS data

library(teal)
library(teal.modules.general)

# create empty `teal_data` object
data <- teal_data()

# execute code within it
data <- within(data, {
  IRIS <- iris
})

# create some table inputs, and put them in a list
table_1 <- data.frame(Info = c("A", "B"), Text = c("A", "B"))
table_2 <- data.frame(
  `Column 1` = c("C", "D"),
  `Column 2` = c(5.5, 6.6),
  `Column 3` = c("A", "B")
)

table_input <- list(
  "Table 1" = table_1,
  "Table 2" = table_2
)

# create front page module ----
mod_frontpage <- tm_front_page(
  header_text = c(
    "Important information" = "It can go here.",
    "Other information" = "Can go here."
  ),
  tables = table_input,
  additional_tags = HTML("Additional HTML or shiny tags go here <br>"),
  footnotes = c("X" = "is the first footnote", "Y is the second footnote")
)


app <- init(
  data = data,
  modules = list(
    mod_frontpage
  )
)

if (Sys.getenv("QUARTO_ROOT") == "") {
  shinyApp(app$ui, app$server)
}


# _______ -----
# anatomy -----

# create arguments ----

label = "Front page"
header_text = c(
  "Important information" = "It can go here.",
  "Other information" = "Can go here."
)
tables = table_input
additional_tags = HTML("Additional HTML or shiny tags go here <br>")
footnotes = c("X" = "is the first footnote", "Y is the second footnote")
datanames = "all"
# transformators = list()

# run UI part of tmg front page ----
# Start of assertions
checkmate::assert_string(label)
checkmate::assert_character(header_text, min.len = 0, any.missing = FALSE)
checkmate::assert_list(
  tables,
  types = "data.frame",
  names = "named",
  any.missing = FALSE
)
checkmate::assert_multi_class(
  additional_tags,
  classes = c("shiny.tag.list", "html")
)
checkmate::assert_character(footnotes, min.len = 0, any.missing = FALSE)
checkmate::assert_character(
  datanames,
  min.len = 0,
  min.chars = 1,
  null.ok = TRUE
)
# end of assertions
# Make UI args
# args <- as.list(environment())

# ans <- module(
#   label = label,
#   server = srv_front_page,
#   ui = ui_front_page,
#   ui_args = args,
#   server_args = list(tables = tables),
#   datanames = datanames,
#   ,
#   transformators = transformators
# )
# attr(ans, "teal_bookmarkable") <- TRUE

# server part ----

# render one table
renderTable(
  tables[[1]],
  bordered = TRUE,
  caption = names(tables)[1],
  caption.placement = "top"
)

# renders the whole list of the tables
lapply(seq_along(tables), function(idx) {
  output[[paste0("table_", idx)]] <- renderTable(
    tables[[idx]],
    bordered = TRUE,
    caption = names(tables)[idx],
    caption.placement = "top"
  )
})

# data is a S4 object
data |> str()

data@join_keys
data@verified
data@code
data@.xData

length(isolate(names(data()))) > 0L
