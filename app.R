# chapter 1

library(shiny)
ui <- fluidPage(
  "Hello, world!"
)
server <- function(input, output, session) {
}
shinyApp(ui, server)
#  typing “shinyapp” and pressing Shift+Tab: gives the ui boilerplate



## 1.4 Adding UI control

ui <- fluidPage(
  selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  verbatimTextOutput("summary"),
  tableOutput("table")
)
# verbatimTextOutput() displays code and tableOutput() displays table

# tell Shiny how to fill in the summary and table outputs
server <- function(input, output, session) {
  output$summary <- renderPrint({
    dataset <- get(input$dataset, "package:datasets")
    summary(dataset)
  })
  
  output$table <- renderTable({
    dataset <- get(input$dataset, "package:datasets")
    dataset
  })
}
# `input$dataset` is populated with the current value of the UI component 
# with id `dataset`,and will cause the outputs to automatically update 
# whenever that value changes

shinyApp(ui, server)

# 1.6 Reducing duplication with reactive expressions
## duplicated code: the following line is present in both outputs.
## dataset <- get(input$dataset, "package:datasets")

## now create a reactive expression by wrapping a block of code in reactive({...}) 
## and assigning it to a variable, 
## and you use a reactive expression by calling it like a function. 

server <- function(input, output, session) {
  # Create a reactive expression
  dataset <- reactive({
    get(input$dataset, "package:datasets")
  })
  
  output$summary <- renderPrint({
    # Use a reactive expression by calling it like a function
    summary(dataset())
  })
  
  output$table <- renderTable({
    dataset()
  })
}

# here dataset is like a function

# 1.8 Excercise 

# 1. Create an app that greets the user by name. You don’t know all the functions 
# you need to do this yet, so I’ve included some lines of code below.
# Think about which lines you’ll use and then copy and paste them into the 
# right place in a Shiny app.

library(shiny)

ui <- fluidPage(
  numericInput("age", "How old are you?", value = NA),
  textInput("name", "What's your name?"),
  textOutput("greeting"),
)

server <- function(input, output, session) {
  output$greeting <- renderText({
    paste0("Hello ", input$name)
  })
}

shinyApp(ui, server)

# 2. Suppose your friend wants to design an app that allows the user to set 
# a number (x) between 1 and 50, and displays the result of multiplying 
# this number by 5.
library(shiny)

ui <- fluidPage(
  sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
  "then x times 5 is",
  textOutput("product")
)

server <- function(input, output, session) {
  output$product <- renderText({ 
    input$x * 5
  })
}

shinyApp(ui, server)

# 3. Extend the app from the previous exercise to allow the user to set 
# the value of the multiplier, y, so that the app yields the value of x * y

library(shiny)

ui <- fluidPage(
  sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
  sliderInput("y", label = "and y is", min = 1, max = 50, value = 30),
  "then x times y is",
  textOutput("product")
)

server <- function(input, output, session) {
  output$product <- renderText({ 
    input$x* input$y
  })
}

shinyApp(ui, server)

# 4. Take the following app which adds some additional functionality to the last app described in the last exercise. 
# What’s new? How could you reduce the amount of duplicated code in the app by using a reactive expression.
library(shiny)

ui <- fluidPage(
  sliderInput("x", "If x is", min = 1, max = 50, value = 30),
  sliderInput("y", "and y is", min = 1, max = 50, value = 5),
  "then, (x * y) is", textOutput("product"),
  "and, (x * y) + 5 is", textOutput("product_plus5"),
  "and (x * y) + 10 is", textOutput("product_plus10")
)

server <- function(input, output, session) {
  # output$product <- renderText({ 
  #   product <- input$x * input$y
  #   product
  # })
  product <- reactive({
    input$x * input$y
  })
  output$product_plus5 <- renderText({ 
    product <- input$x * input$y
    product + 5
  })
  output$product_plus10 <- renderText({ 
    product <- input$x * input$y
    product + 10
  })
}

shinyApp(ui, server)

# # 5. The following app is very similar to one you’ve seen earlier in the chapter: you select a dataset from a package 
# and the app prints out a summary and plot of the data. It also follows good practice and makes use of reactive expressions to avoid redundancy of code. 
# However there are three bugs in the code provided below. Can you find and fix them?

library(shiny)
library(ggplot2)

datasets <- c("economics", "faithfuld", "seals")
ui <- fluidPage(
  selectInput("dataset", "Dataset", choices = datasets),
  verbatimTextOutput("summary"),
  #tableOutput("plot") 
  plotOutput("plot")
)

server <- function(input, output, session) {
  dataset <- reactive({
    get(input$dataset, "package:ggplot2")
  })
  output$summmary <- renderPrint({
    summary(dataset())
  })
  output$plot <- renderPlot({
    plot(dataset())
  }, res = 96)
}

shinyApp(ui, server)

# chapter 2 Basic UI

# 2.2 Inputs 

## 2.2.1 common structure that underlies all input functions: `inputId`, `label`, value (default value appears on UI)

## 2.2.2free text
ui <- fluidPage(
  textInput("name", "What's your name?"),
  passwordInput("password", "What's your password?"),
  textAreaInput("story", "Tell me about yourself", rows = 3)
)

## 2.2.3 numeric text
ui <- fluidPage(
  numericInput("num", "Number one", value = 0, min = 0, max = 100),
  sliderInput("num2", "Number two", value = 50, min = 0, max = 100),
  sliderInput("rng", "Range", value = c(10, 20), min = 0, max = 100)
)

## 2.2.4 Dates

# Collect a single day with dateInput() or a range of two days with dateRangeInput().
ui <- fluidPage(
  dateInput("dob", "When were you born?"),
  dateRangeInput("holiday", "When do you want to go on vacation next?")
)

## 2.2.5 Limited choices
# allow the user to choose from a prespecified set of options: selectInput() and radioButtons().
animals <- c("dog", "cat", "mouse", "bird", "other", "I hate animals")

ui <- fluidPage(
  selectInput("state", "What's your favourite state?", state.name),
  radioButtons("animal", "What's your favourite animal?", animals)
)

### RadiButtons: `choiceNames/choiceValues` arguments
ui <- fluidPage(
  radioButtons("rb", "Choose one:",
               choiceNames = list(
                 icon("angry"),
                 icon("smile"),
                 icon("sad-tear")
               ),
               choiceValues = list("angry", "happy", "sad")
  )
)
#> This Font Awesome icon ('angry') does not exist:
#> * if providing a custom `html_dependency` these `name` checks can 
#>   be deactivated with `verify_fa = FALSE`
#> This Font Awesome icon ('smile') does not exist:
#> * if providing a custom `html_dependency` these `name` checks can 
#>   be deactivated with `verify_fa = FALSE`
#> This Font Awesome icon ('sad-tear') does not exist:
#> * if providing a custom `html_dependency` these `name` checks can 
#>   be deactivated with `verify_fa = FALSE`

### selectInput: create dropdowns
# set multiple = TRUE to allow the user to select multiple element

### RadioButtons cannot select multiple values but there’s an alternative that’s conceptually similar: checkboxGroupInput().
ui <- fluidPage(
  checkboxGroupInput("animal", "What animals do you like?", animals)
)

# If you want a single checkbox for a single yes/no question, use checkboxInput():
ui <- fluidPage(
  checkboxInput("cleanup", "Clean up?", value = TRUE),
  checkboxInput("shutdown", "Shutdown?")
)

## 2.2.6 File uploads
ui <- fluidPage(
  fileInput("upload", NULL)
)

## 2.2.7 Action buttons
## Let the user perform an action with actionButton() or actionLink():
ui <- fluidPage(
  actionButton("click", "Click me!"),
  actionButton("drink", "Drink me!", icon = icon("cocktail"))
)
## Actions links and buttons are most naturally paired with observeEvent() or 
## eventReactive() in your server function.

# You can customise the appearance using the class argument by using one of "btn-primary", "btn-success", "btn-info", "btn-warning", or "btn-danger". 
# You can also change the size with "btn-lg", "btn-sm", "btn-xs". Finally, you can make buttons span the entire width of the element they are embedded within using "btn-block".

## 2.2.8 Exercise
## 2. Carefully read the documentation for sliderInput() to figure out how to create a date slider 
library(shiny)

ui <- fluidPage(
  sliderInput(
    "dates",
    "When should we deliver?",
    min = as.Date("2019-08-09"),
    max = as.Date("2019-08-16"),
    value = as.Date("2019-08-10")
  )
  
)

server <- function(input, output, session) {}

shinyApp(ui, server)

## 3. 
library(shiny)

ui <- fluidPage(
  sliderInput(inputId = "user_input",
              label = "User Input", 
              value = 10,
              min = 0, max = 100,
              step = 5,
              # Added animation
              animate = animationOptions(
                interval = 1000,
                loop = TRUE,
                playButton = NULL,
                pauseButton = NULL
              )
  )
  
)

server <- function(input, output, session) {}

shinyApp(ui, server)


## 2.3 Outputs

# Each output function on the front end is coupled with a render function in the back end.
# The following sections show you the basics of the output functions on the front end, 
# along with the corresponding render functions in the back end.

## 2.3.1 Text

## In UI: output regular text with textOutput() and fixed code and console output with verbatimTextOutput().

ui <- fluidPage(
  textOutput("text"),
  verbatimTextOutput("code")
)
server <- function(input, output, session) {
  output$text <- renderText({ 
    "Hello friend!" 
  })
  output$code <- renderPrint({ 
    summary(1:10) 
  })
}
# In server:
# renderText() combines the result into a single string, and is usually paired with textOutput()
# renderPrint() prints the result, as if you were in an R console, and is usually paired with verbatimTextOutput().
## Note that the {} are only required in render functions if need to run multiple lines of code. 

## 2.3.2 Table
# two options for displaying data frames in tables:
#   
# tableOutput() and renderTable() render a static table of data, showing all the data at once.
# 
# dataTableOutput() and renderDataTable() render a dynamic table, showing a fixed number of rows along with controls to change which rows are visible.

ui <- fluidPage(
  tableOutput("static"),
  dataTableOutput("dynamic")
)
server <- function(input, output, session) {
  output$static <- renderTable(head(mtcars))
  output$dynamic <- renderDataTable(mtcars, options = list(pageLength = 5))
}

# tableOutput() is most useful for small, fixed summaries (e.g. model coefficients); 
# dataTableOutput() is most appropriate if you want to expose a complete data frame to the user. 
#  If you want greater control over the output of dataTableOutput(), use reactable package.


## 2.3.3 Plots
# can display any type of R graphic (base, ggplot2, or otherwise) with plotOutput() and renderPlot():
# DEFAULT: 400 pixels high
ui <- fluidPage(
  plotOutput("plot", width = "400px")
)
server <- function(input, output, session) {
  output$plot <- renderPlot(plot(1:5), res = 96)
}

# You can override these defaults with the height and width arguments.
# We recommend always setting res = 96 as that will make your Shiny plots
# match what you see in RStudio as closely as possible.

## 2.3.5 Exercises

# 2. 

library(shiny)

ui <- fluidPage(
  plotOutput("plot", width = "700px", height = "300px")
)

server <- function(input, output, session) {
  output$plot <- renderPlot(plot(1:5), res = 96, 
                            alt = "Scatterplot of 5 random numbers")
}

shinyApp(ui, server)

# 3. 
ui <- fluidPage(
  dataTableOutput("table")
)
server <- function(input, output, session) {
  output$table <- renderDataTable(mtcars, options = list(pageLength = 5,
                                  ordering = FALSE, 
                                  searching = FALSE))
}
shinyApp(ui, server)


# 4. Alternatively, read up on reactable, and convert the above app to use it instead. 
library(shiny)
library(reactable)

ui <- fluidPage(
  reactableOutput("table")
)

server <- function(input, output) {
  output$table <- renderReactable({
    reactable(mtcars)
  })
}

shinyApp(ui, server)




### Chapter 3: Basic reactivity

# 3.2 server function

## 3.2.1 input
# input objects are read only, don't try to modify an input inside the server function

# if your UI contains a numeric input control with an input ID of count, like so:
ui <- fluidPage(
  numericInput("count", label = "Number of values", value = 100)
)
# then you can access the value of that input with input$count in server function.
# It will initially contain the value 100, and it will be automatically updated 
# as the user changes the value in the browser.

# *** One more important thing about input: it’s selective about who is allowed to read it. 
# To read from an input, you must be in a reactive context created by a function like renderText() or reactive().

## 3.2.2 output
# always use the output object in concert with a render function

# 3.3 Reactive programming

## 3.3.1 Imperative vs declarative programming (shiny - declarative )

## 3.3.4 Reactive expressions

## 3.3.5 excution order
#  the order in which reactive code is run is determined only by the reactive graph, not by its layout in the server function.

## 3.3.6 excercise

# 3.4 reactive expressions:
# example

library(ggplot2)

freqpoly <- function(x1, x2, binwidth = 0.1, xlim = c(-3, 3)) {
  df <- data.frame(
    x = c(x1, x2),
    g = c(rep("x1", length(x1)), rep("x2", length(x2)))
  )
  
  ggplot(df, aes(x, colour = g)) +
    geom_freqpoly(binwidth = binwidth, size = 1) +
    coord_cartesian(xlim = xlim)
}

t_test <- function(x1, x2) {
  test <- t.test(x1, x2)
  
  # use sprintf() to format t.test() results compactly
  sprintf(
    "p value: %0.3f\n[%0.2f, %0.2f]",
    test$p.value, test$conf.int[1], test$conf.int[2]
  )
}
x1 <- rnorm(100, mean = 0, sd = 0.5)
x2 <- rnorm(200, mean = 0.15, sd = 0.9)

freqpoly(x1, x2)
cat(t_test(x1, x2))
#> p value: 0.005
#> [-0.39, -0.07]

# the shiny app
ui <- fluidPage(
  fluidRow(
    column(4, 
           "Distribution 1",
           numericInput("n1", label = "n", value = 1000, min = 1),
           numericInput("mean1", label = "µ", value = 0, step = 0.1),
           numericInput("sd1", label = "σ", value = 0.5, min = 0.1, step = 0.1)
    ),
    column(4, 
           "Distribution 2",
           numericInput("n2", label = "n", value = 1000, min = 1),
           numericInput("mean2", label = "µ", value = 0, step = 0.1),
           numericInput("sd2", label = "σ", value = 0.5, min = 0.1, step = 0.1)
    ),
    column(4,
           "Frequency polygon",
           numericInput("binwidth", label = "Bin width", value = 0.1, step = 0.1),
           sliderInput("range", label = "range", value = c(-3, 3), min = -5, max = 5)
    )
  ),
  fluidRow(
    column(9, plotOutput("hist")),
    column(3, verbatimTextOutput("ttest"))
  )
)

server <- function(input, output, session) {
  x1 <- reactive(rnorm(input$n1, input$mean1, input$sd1))
  x2 <- reactive(rnorm(input$n2, input$mean2, input$sd2))
  
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = input$binwidth, xlim = input$range)
  }, res = 96)
  
  output$ttest <- renderText({
    t_test(x1(), x2())
  })
}

shinyApp(ui, server)

## 3.5 controlling timing

ui <- fluidPage(
  fluidRow(
    column(3, 
           numericInput("lambda1", label = "lambda1", value = 3),
           numericInput("lambda2", label = "lambda2", value = 5),
           numericInput("n", label = "n", value = 1e4, min = 0)
    ),
    column(9, plotOutput("hist"))
  )
)

server <- function(input, output, session) {
  x1 <- reactive(rpois(input$n, input$lambda1))
  x2 <- reactive(rpois(input$n, input$lambda2))
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = 1, xlim = c(0, 40))
  }, res = 96)
}

## 3.5.1 timed invalidation
## We can increase the frequency of updates with a new function: reactiveTimer() in server

server <- function(input, output, session) {
  timer <- reactiveTimer(500)
  
  x1 <- reactive({
    timer()
    rpois(input$n, input$lambda1)
  })
  x2 <- reactive({
    timer()
    rpois(input$n, input$lambda2)
  })
  
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = 1, xlim = c(0, 40))
  }, res = 96)
}
## 3.5.2 on click

ui <- fluidPage(
  fluidRow(
    column(3, 
           numericInput("lambda1", label = "lambda1", value = 3),
           numericInput("lambda2", label = "lambda2", value = 5),
           numericInput("n", label = "n", value = 1e4, min = 0),
           actionButton("simulate", "Simulate!")
    ),
    column(9, plotOutput("hist"))
  )
)
server <- function(input, output, session) {
  x1 <- reactive({
    input$simulate
    rpois(input$n, input$lambda1)
  })
  x2 <- reactive({
    input$simulate
    rpois(input$n, input$lambda2)
  })
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = 1, xlim = c(0, 40))
  }, res = 96)
}

## To solve this problem we need a new tool: a way to use input values without 
## taking a reactive dependency on them. We need eventReactive(), which has two 
## arguments: the first argument specifies what to take a dependency on, and 
## the second argument specifies what to compute. 

server <- function(input, output, session) {
  x1 <- eventReactive(input$simulate, {
    rpois(input$n, input$lambda1)
  })
  x2 <- eventReactive(input$simulate, {
    rpois(input$n, input$lambda2)
  })
  
# 3.6 Observers
  
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = 1, xlim = c(0, 40))
  }, res = 96)
}

# observeEvent() is very similar to eventReactive(). It has two important arguments: eventExpr and handlerExpr. The first argument is 
# the input or expression to take a dependency on; the second argument is the code that will be run. 

ui <- fluidPage(
  textInput("name", "What's your name?"),
  textOutput("greeting")
)

server <- function(input, output, session) {
  string <- reactive(paste0("Hello ", input$name, "!"))
  
  output$greeting <- renderText(string())
  observeEvent(input$name, {
    message("Greeting performed")
  })
}

### Chapter 4 Case study: ER injuries
library(shiny)
library(vroom)
library(tidyverse)

