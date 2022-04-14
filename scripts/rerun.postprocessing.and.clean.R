rm(list = ls())

source('/data/gent/vo/000/gvo00074/felicien/R/read_and_plot_ED2.2_all_tspft_yearly.r')

site.data <- read.csv("./data/41586_2016_Article_BFnature16512_Figa_ESM.csv")

lats <- site.data[["Lat"]]
lons <- site.data[["Lon"]]

for (isite in seq(1,length(lats))){

  print(paste("Simulating site",site.data[["Site"]][isite]))

  lat <- lats[isite]
  lon <- lons[isite]

  run_name <- paste0("site.lat",abs(lat),ifelse(lat == abs(lat),"N","S"),".lon",abs(lon),ifelse(lon == abs(lon),"E","W"))

  cdirectory <- file.path("/user/scratchkyukon/gent/gvo000/gvo00074/felicien/SecondFor/out",run_name,"analy")


  if (!file.exists(file.path(cdirectory,"analysis.RData"))){

    all.files <- list.files(cdirectory)

    file.prefix <- unlist(lapply(stringr::str_split(all.files,pattern = "-"),"[",1))
    file.year <- as.numeric(unlist(lapply(stringr::str_split(all.files,pattern = "-"),"[",3)))

    final.year <- max(file.year[file.prefix == "analysis"],na.rm = TRUE) - 1

    read_and_plot_ED2.2_all_tspft_yearly(cdirectory,'analysis','1900/01/01',paste0(final.year,'/01/01'))

  }
  arg <- paste("$(find",paste0(cdirectory,"/analysis-Q-*"),"-name '*' ! -name 'analysis-Q*-01-*')")
  system2("rm",arg)
}

# scp /home/femeunier/Documents/projects/SecondFor/scripts/rerun.postprocessing.and.clean.R hpc:/data/gent/vo/000/gvo00074/felicien/R
