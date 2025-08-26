# this script contains a more typical shiny app


library(teal)

app <- init(
  # add data
  data = teal_data(iris = iris),
  
  # add modules (as a list)
  modules = list(
    module(
      label = "iris histogram",
      
      # server
      server = function(input, output, session, data) {
        
        
        updateSelectInput(session = session,
                          inputId =  "var",
                          choices = names(data()[["iris"]])[1:4])
        
        # plot
        output$hist <- renderPlot({
          req(input$var)
          hist(
            x = data()[["iris"]][[input$var]],
            main = sprintf("Histogram of %s", input$var),
            xlab = input$var
          )
        })
      },
      
      # ui
      ui = function(id) {
        ns <- NS(id)
        list(
          selectInput(inputId = ns("var"),
                      label =  "Column name",
                      choices = NULL),
          plotOutput(outputId = ns("hist"))
        )
      }
    )
  )
)



shinyApp(app$ui, app$server)
