# this script does a simple data analysis on the NEISS data

library(dplyr)
library(forcats)
# download data

dir.create("data")
dir.create('data/neiss')

download <- function(name) {
  url <- "https://raw.github.com/hadley/mastering-shiny/main/neiss/"
  download.file(paste0(url, name), paste0("data/neiss/", name), quiet = TRUE)
}
download("injuries.tsv.gz")
download("population.tsv")
download("products.tsv")


# read data
injuries <- vroom::vroom("data/neiss/injuries.tsv.gz")
injuries
# injuries$narrative
# product code links to products data

products <- vroom::vroom('data/neiss/products.tsv')
products

population <- vroom::vroom('data/neiss/population.tsv')
population

# initial exploration -----

filter(products, prod_code == 649) # toilet related injuries
selected <- injuries |> filter(prod_code == 649)
selected |> head()

selected |> count(location, wt = weight, sort = T)
selected |> count(body_part, wt = weight, sort = T)
selected |> count(diag, wt = weight, sort = T)

# stratify by age and sex
summary <- selected |> count(age, sex, wt = weight)
summary |>
  ggplot(aes(x = age, y = n, colour = sex)) +
  geom_line() +
  labs(y = 'estimated number of injuries')

# compare with the population for each age group
summary <- selected %>%
  count(age, sex, wt = weight) %>%
  left_join(population, by = c("age", "sex")) %>%
  mutate(rate = n / population * 1e4)

summary %>%
  ggplot(aes(age, rate, colour = sex)) +
  geom_line(na.rm = TRUE) +
  labs(y = "Injuries per 10,000 people")

# check the narratives
selected %>%
  sample_n(10) %>%
  pull(narrative)

# start constructing an app -----

prod_codes <- setNames(products$prod_code, products$title)
# setNames(1:3, c("foo", "bar", "baz"))

ui <- fluidPage(
  # part 1, spans half (out of 12)
  fluidRow(
    column(6, selectInput("code", "Product", choices = prod_codes))
  ),

  # part 2, divides equally
  fluidRow(
    column(4, tableOutput("diag")),
    column(4, tableOutput("body_part")),
    column(4, tableOutput("location"))
  ),

  # part 3, spans entire space
  fluidRow(
    column(12, plotOutput("age_sex"))
  )
)

server_original <- function(input, output, session) {
  # convert to reactive expressions
  selected <- reactive(injuries %>% filter(prod_code == input$code))

  output$diag <- renderTable(
    selected() %>% count(diag, wt = weight, sort = TRUE)
  )
  output$body_part <- renderTable(
    selected() %>% count(body_part, wt = weight, sort = TRUE)
  )
  output$location <- renderTable(
    selected() %>% count(location, wt = weight, sort = TRUE)
  )

  summary <- reactive({
    selected() %>%
      count(age, sex, wt = weight) %>%
      left_join(population, by = c("age", "sex")) %>%
      mutate(rate = n / population * 1e4)
  })

  output$age_sex <- renderPlot(
    {
      summary() %>%
        ggplot(aes(age, n, colour = sex)) +
        geom_line() +
        labs(y = "Estimated number of injuries")
    },
    res = 96
  )
}

# shinyApp(ui = ui, server = server_original)

# an improvement ----
ui_2 <- fluidPage(
  # part 1, selections
  fluidRow(
    column(
      8,
      selectInput(
        "code",
        "Product",
        choices = setNames(products$prod_code, products$title),
        width = "100%"
      )
    ),
    # add input: for the plot to provide options between rate and count
    column(2, selectInput("y", "Y axis", c("rate", "count")))
  ),
  # part 2, divides equally
  fluidRow(
    column(4, tableOutput("diag")),
    column(4, tableOutput("body_part")),
    column(4, tableOutput("location"))
  ),

  # part 3, spans entire space
  fluidRow(
    column(12, plotOutput("age_sex")) # this is a figure
  )
)

# leave this utility function outside
# requires forcats
count_top <- function(df, var, n = 5) {
  df %>%
    mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
    group_by({{ var }}) %>%
    summarise(n = as.integer(sum(weight)))
}


server_2 <- function(input, output, session) {
  # create a utility that only shows the top 5 in each table
  # convert to reactive expressions
  selected <- reactive(injuries %>% filter(prod_code == input$code))

  output$diag <- renderTable(count_top(selected(), diag), width = "100%")
  output$body_part <- renderTable(
    count_top(selected(), body_part),
    width = "100%"
  )
  output$location <- renderTable(
    count_top(selected(), location),
    width = "100%"
  )

  summary <- reactive({
    selected() %>%
      count(age, sex, wt = weight) %>%
      left_join(population, by = c("age", "sex")) %>%
      mutate(rate = n / population * 1e4)
  })

  # allow users to visualize rate too
  output$age_sex <- renderPlot(
    {
      if (input$y == "count") {
        summary() %>%
          ggplot(aes(age, n, colour = sex)) +
          geom_line() +
          labs(y = "Estimated number of injuries")
      } else {
        summary() %>%
          ggplot(aes(age, rate, colour = sex)) +
          geom_line(na.rm = TRUE) +
          labs(y = "Injuries per 10,000 people")
      }
    },
    res = 96
  )
}
shinyApp(ui = ui_2, server = server_2)
