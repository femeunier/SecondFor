rm(list = ls())

library(PEcAn.ED2)
library(stringr)
library(dplyr)
library(SecondFor)
library(ED2scenarios)

outfolder <- "/data/gent/vo/000/gvo00074/ED_common_data/met/SecondFor/"
prefix <- "CRUNCEP"

met.folder <- "/data/gent/vo/000/gvo00074/ED_common_data/met/SecondFor/"
ref.dir <- "/user/scratchkyukon/gent/gvo000/gvo00074/felicien/SecondFor/"

years <- 2001:2010

lat <- -11.44
lon <- -69.16

##################################################################################
# Drivers
download.CRUNCEP(years,
                 lat,lon,
                 in.prefix = prefix,
                 outfolder)

convert.CRUNCEP(outfolder,
                lat,lon,
                in.prefix = prefix,
                years,
                fileCO2 = "./data/CO2_1700_2019_TRENDYv2020.txt")

#####################################################################
# ED2IN file

rundir <- file.path(ref.dir,"run")
outdir <- file.path(ref.dir,"out")

ed2in <- read_ed2in(file.path(rundir,"ED2IN"))

run_name <- paste0("site.lat",abs(lat),ifelse(lat == abs(lat),"N","S"),".lon",abs(lon),ifelse(lon == abs(lon),"E","W"))

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
ed2in_scenar$METCYC1 <- min(years)
ed2in_scenar$METCYCF <- max(years)

write_ed2in(ed2in_scenar,filename = file.path(run_ref,"ED2IN"))

####################################################################################
# job file

write_job(file = file.path(run_ref,"job.sh"),
          nodes = 1,ppn = 18,mem = 16,walltime = 24,
          prerun = "ml purge ; ml intel-compilers/2021.4.0 HDF5/1.12.1-iimpi-2021b UDUNITS/2.2.28-GCCcore-11.2.0; ulimit -s unlimited",
          CD = run_ref,
          ed_exec = "/user/scratchkyukon/gent/gvo000/gvo00074/felicien/ED2.2/ED2/ED/build/ed_2.2-opt-master-fa80dab",
          ED2IN = "ED2IN",
          Rplot_function = '/data/gent/vo/000/gvo00074/felicien/R/read_and_plot_ED2_Q2R_tspft_yearly.r',
          clean = TRUE,
          in.line = "ml purge; ml R/4.1.2-foss-2021b")

# scp /home/femeunier/Documents/projects/SecondFor/scripts/run.single.site.R hpc:/data/gent/vo/000/gvo00074/felicien/R

