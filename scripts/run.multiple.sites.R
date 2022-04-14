rm(list = ls())

library(PEcAn.ED2)
library(stringr)
library(dplyr)
library(SecondFor)
library(ED2scenarios)
library(purrr)

prefix <- "CRUNCEP"

met.folder <- "/data/gent/vo/000/gvo00074/ED_common_data/met/SecondFor/"
ref.dir <- "/user/scratchkyukon/gent/gvo000/gvo00074/felicien/SecondFor/"

years <- 2001:2010
rerun.download <- FALSE
rerun.convert <- FALSE
rerun.model <- TRUE

site.data <- read.csv("./data/41586_2016_Article_BFnature16512_Figa_ESM.csv")

lats <- site.data[["Lat"]]
lons <- site.data[["Lon"]]

list_dir <- list()

rundir <- file.path(ref.dir,"run")
outdir <- file.path(ref.dir,"out")

ed2in <- read_ed2in(file.path(rundir,"ED2IN"))

for (isite in seq(1,length(lats))){

  print(paste("Simulating site",site.data[["Site"]][isite]))

  lat <- lats[isite]
  lon <- lons[isite]

  run_name <- paste0("site.lat",abs(lat),ifelse(lat == abs(lat),"N","S"),".lon",abs(lon),ifelse(lon == abs(lon),"E","W"))

  ##################################################################################
  # Drivers

  years2download <-
    years[which(!file.exists(
      file.path(met.folder,
                run_name,
                paste(prefix,years,"nc",sep = "."))))]

  if (length(years2download)>0 | rerun.download){

    if (rerun.download){
      download.CRUNCEP(years,
                       lat,lon,
                       in.prefix = prefix,
                       met.folder)
    } else {
      download.CRUNCEP(years2download,
                       lat,lon,
                       in.prefix = prefix,
                       met.folder)
    }

  }

  years2convert <-
    years[which(! (file.exists(
      file.path(met.folder,
                run_name,
                paste0(years,"JAN.h5"))) &
        file.exists(
                  file.path(met.folder,
                            run_name,
                            paste0(years,"DEC.h5"))) ))]


  if (length(years2convert)>0 | rerun.convert){

    if (rerun.convert){

      # directory = met.folder
      # in.prefix = prefix
      # lat <- lats[isite]
      # lon <- lons[isite]
      # fileCO2 = "./data/CO2_1700_2019_TRENDYv2020.txt"

      convert.CRUNCEP(directory = met.folder,
                      lat,lon,
                      in.prefix = prefix,
                      years,
                      fileCO2 = "./data/CO2_1700_2019_TRENDYv2020.txt")
    } else {
      convert.CRUNCEP(directory = met.folder,
                      lat,lon,
                      in.prefix = prefix,
                      years2convert,
                      fileCO2 = "./data/CO2_1700_2019_TRENDYv2020.txt")

    }

  }



  #####################################################################
  # ED2IN file

  run_ref <- file.path(rundir,run_name)
  out_ref <- file.path(outdir,run_name)

  if(!dir.exists(run_ref)) dir.create(run_ref)
  if(!dir.exists(out_ref)) dir.create(out_ref)
  if(!dir.exists(file.path(out_ref,"analy"))) dir.create(file.path(out_ref,"analy"))
  if(!dir.exists(file.path(out_ref,"histo"))) dir.create(file.path(out_ref,"histo"))

  # ED2IN
  ed2in_scenar <- ed2in
  ed2in_scenar$IEDCNFGF <- file.path(run_ref,"config.xml")
  ed2in_scenar$FFILOUT = file.path(out_ref,"analy","analysis")
  ed2in_scenar$SFILOUT = file.path(out_ref,"histo","history")
  ed2in_scenar$POI_LAT <- lat
  ed2in_scenar$POI_LON <- lon

  ed2in_scenar$ED_MET_DRIVER_DB <- file.path(met.folder,run_name,"ED_MET_DRIVER_HEADER")
  ed2in_scenar$METCYC1 <- min(years)
  ed2in_scenar$METCYCF <- max(years)

  write_ed2in(ed2in_scenar,filename = file.path(run_ref,"ED2IN"))

  ####################################################################################
  # job file

  analy.file <- file.path(out_ref,"analy","analysis.RData")
  if (!file.exists(analy.file) | rerun.model){
    write_job(file = file.path(run_ref,"job.sh"),
              nodes = 1,ppn = 18,mem = 16,walltime = 24,
              prerun = "ml purge ; ml intel-compilers/2021.4.0 HDF5/1.12.1-iimpi-2021b UDUNITS/2.2.28-GCCcore-11.2.0; ulimit -s unlimited",
              CD = run_ref,
              ed_exec = "/user/scratchkyukon/gent/gvo000/gvo00074/felicien/ED2.2/ED2/ED/build/ed_2.2-opt-master-fa80dab",
              ED2IN = "ED2IN",
              Rplot_function = '/data/gent/vo/000/gvo00074/felicien/R/read_and_plot_ED2.2_all_tspft_yearly.r',
              clean = TRUE,
              in.line = "ml purge; ml R/4.1.2-foss-2021b")

    list_dir[[run_name]] <- run_ref
  }
}


dumb <- write_bash_submission(file = file.path(rundir,"all_jobs.sh"),
                              list_files = list_dir,
                              job_name = "job.sh")


# scp /home/femeunier/Documents/projects/SecondFor/data/41586_2016_Article_BFnature16512_Figa_ESM.csv hpc:/data/gent/vo/000/gvo00074/felicien/R/data
# scp /home/femeunier/Documents/projects/SecondFor/scripts/run.multiple.sites.R hpc:/data/gent/vo/000/gvo00074/felicien/R



