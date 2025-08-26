library(dplyr)
library(teal)
library(teal.modules.general)
library(teal.modules.clinical)

# data ----
# Prepare data object
# ? what does default_cdisc_join_keys do?
data <- teal_data()
data <- within(data, {
  ADSL <- rADSL
})
join_keys(data) <- default_cdisc_join_keys["ADSL"]


# define inputs ----
# Prepare module inputs
# this step is not strictly necessary, since only one dataset is involved
ADSL <- data[["ADSL"]]


# choices_selected is from teal.transform
# define arm 
# ARMCD: arm code (a, b, c)
# ARM: arm name (drug, placebo, combination)
# (probably always fixed)
cs_arm_var <- choices_selected(
  choices = variable_choices(ADSL, subset = c("ARMCD", "ARM")),
  selected = "ARM"
)


# demographic variables
# selected the numeric and factor variables
# i.e. date, dttm, chr are excluded
demog_vars_adsl <- ADSL |>
  select(where(is.numeric) | where(is.factor)) |>
  names()



# these are the excluded ones (study ID, subject ID, ...)
# ADSL |>
#   select(!(where(is.numeric) | where(is.factor))) |>
#   names()


# tm_data_table -----
mod_dt <- tm_data_table("Data Table")


# tm_t_summary -----
mod_summary <- tm_t_summary(
  label = "Demographic Table",
  
  # add which dataset to use
  dataname = "ADSL",
  arm_var = cs_arm_var,
  summarize_vars = choices_selected(
    choices = variable_choices(ADSL, demog_vars_adsl),
    selected = c("SEX", "AGE", "RACE")
  )
)


# _______ -----
# Create app -----
app <- init(
  # single data source: adsl
  data = data,
  modules = list(
    
    # module 1, display data
    mod_dt,
    
    # module 2, summary table
    mod_summary
  )
  # for medical history: use data 2
  # data = data2,
  #module = mod_mh
  
)


shinyApp(app$ui, app$server)
