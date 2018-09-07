# launch SmaRP directly in the browser

library(SmaRP)
launch_application(launch.browser = TRUE)

# launch SmaRP from computer (to check changes before reloading the package)
# file.path(getwd(), "inst", "application") = "/home/mirai_user/RStudioProjects/SmaRP/inst/application"
runApp(appDir = file.path(getwd(), "inst", "application"), launch.browser = TRUE)

#to compare changes
compareWith:::compare_with_repo()

#to build and install vignettes
devtools::use_vignette("name")
devtools::install(build_vignettes = TRUE)