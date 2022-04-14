rm(list = ls())

library(ncdf4)
library(reshape2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

ncfile <- "/home/femeunier/Documents/projects/SecondFor/CRUNCEP/cru_ts4.05.2001.2010.pet.dat.nc"

site.data <- read.csv("./data/Poorter2016/41586_2016_Article_BFnature16512_Figa_ESM.csv")

site.lats <- site.data[["Lat"]]
site.lons <- site.data[["Lon"]]

nc <- nc_open(ncfile)

lats <- ncvar_get(nc,"lat")
lons <- ncvar_get(nc,"lon")
months <- rep(1:12,10)
years <- sort(rep(2001:2010,12))
pet <- ncvar_get(nc,"pet")

nc_close(nc)

df.PET <- melt(pet) %>% rename(lon = Var1,
                               lat = Var2,
                               time = Var3,
                               PET = value) %>%
  mutate(lon = lons[lon],
         lat = lats[lat],
         year = years[time],
         month = months[time]) %>%
  filter(lat <= max(site.lats) & lat>=min(site.lats) & lon <= max(site.lons) & lon>=min(site.lons)) %>% filter(!is.na(PET))


saveRDS(object = df.PET,"./CRUNCEP/df.PET.RDS")

world <- ne_countries(scale = "medium", returnclass = "sf")

df.PET.sum <- df.PET %>%
  group_by(lat,lon) %>%
  summarise(PET.m = mean(PET),
            .groups = "keep")

ggplot(data = df.PET.sum) +
  geom_raster(aes(x=lon, y = lat, fill = PET.m),alpha = 0.3) +

  geom_point(data = site.data,
             aes(x = Lon,y = Lat)) +
  geom_point(data = site.data %>%  filter(Site %in% c("Providencia Island","Luguillo")),
             aes(x = Lon,y = Lat), color = "red") +

  geom_sf(data = world,fill = NA) +
  # coord_sf(xlim = c(min(-82), max(-81)), ylim = c(min(12),max(14)), expand = FALSE) +
  coord_sf(xlim = c(min(site.lons), max(site.lons)), ylim = c(min(site.lats),max(site.lats)), expand = FALSE) +
  scale_fill_gradient(low = "white",high = "darkred") +
  labs(x = "",y = "") +
  theme_bw()
