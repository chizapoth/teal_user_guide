# MVP for scatterplot, using IRIS data

library(teal)
library(teal.modules.general)

# create empty `teal_data` object
data <- teal_data()

# execute code within it
data <- within(data, {
  IRIS <- iris
})

# scatterplot ----
mod_scatter <- tm_g_scatterplot(
  label = "Single wide dataset",
  x = data_extract_spec(
    dataname = "IRIS",
    select = select_spec(
      label = "Select variable:",
      choices = variable_choices(
        data[["IRIS"]],
        c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
      ),
      selected = "Petal.Width",
      multiple = FALSE,
      fixed = FALSE
    )
  ),
  y = data_extract_spec(
    dataname = "IRIS",
    select = select_spec(
      label = "Select variable:",
      choices = variable_choices(
        data[["IRIS"]],
        c("Sepal.Length", "Sepal.Width", "Petal.Width", "Petal.Length")
      ),
      selected = "Petal.Length",
      multiple = FALSE,
      fixed = FALSE
    )
  ),
  color_by = data_extract_spec(
    dataname = "IRIS",
    select = select_spec(
      label = "Select variables:",
      choices = variable_choices(data[["IRIS"]], c("Species")),
      selected = NULL,
      multiple = TRUE,
      fixed = FALSE
    )
  )
)

app <- init(
  data = data,
  modules = list(
    mod_scatter
  )
)

if (Sys.getenv("QUARTO_ROOT") == "") {
  shinyApp(app$ui, app$server)
}
