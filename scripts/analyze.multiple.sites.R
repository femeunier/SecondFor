rm(list = ls())

library(PEcAn.ED2)
library(stringr)
library(dplyr)
library(SecondFor)
library(ED2scenarios)
library(purrr)

ref.dir <- "/user/scratchkyukon/gent/gvo000/gvo00074/felicien/SecondFor/"
rundir <- file.path(ref.dir,"run")
outdir <- file.path(ref.dir,"out")

site.data <- read.csv("./data/41586_2016_Article_BFnature16512_Figa_ESM.csv")

lats <- site.data[["Lat"]]
lons <- site.data[["Lon"]]

df.OP <- data.frame()

for (isite in seq(1,length(lats))){

  print(paste("Simulating site",site.data[["Site"]][isite]))

  clat <- lats[isite]
  clon <- lons[isite]

  run_name <- paste0("site.lat",abs(clat),ifelse(clat == abs(clat),"N","S"),".lon",abs(clon),ifelse(clon == abs(clon),"E","W"))
  run_ref <- file.path(rundir,run_name)
  out_ref <- file.path(outdir,run_name)


  analy.file <- file.path(out_ref,"analy","analysis.RData")

  if (file.exists(analy.file)){

    load(analy.file)
    df.OP <- bind_rows(list(df.OP,
                            data.frame(Site = site.data[["Site"]][isite],
                                       lat = clat,
                                       lon = clon,
                                       yr = datum$year,
                                       month = datum$month,
                                       agb = datum$emean$agb,
                                       agb.early = datum$szpft$agb[,12,2],
                                       agb.mid = datum$szpft$agb[,12,3],
                                       agb.lat = datum$szpft$agb[,12,4])))

  }
}

saveRDS(object = df.OP,
        file = "OP.SecondFor.RDS")

# scp /home/femeunier/Documents/projects/SecondFor/scripts/analyze.multiple.sites.R hpc:/data/gent/vo/000/gvo00074/felicien/R

