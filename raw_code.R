library(data.table)
library(dplyr)
library(naniar)
library(janitor)
library(ggplot2)
path <- './data-raw/'
#file_list <- dir(dir)

do.call_rbind_fread <- function(path, pattern = "*.csv") {
  files = list.files(path, pattern, full.names = TRUE)
  do.call(rbind, lapply(files, function(x) fread(x, stringsAsFactors = FALSE)))
}

x <- do.call_rbind_fread(path)

colnames <- c('Kod stacji','Nazwa stacji', 'Rok', 'Miesiac', 'Dzien', 'Godzina', 'Wysokosc podstawy chmur CL CM szyfrowana',
            'Status pomiaru HPOD', 'Wysokosc podstawy nizszej', 'Status pomiaru HPON', 'Wysokosc podstawy wyzszej', 'Status pomiaru HPOW',
            'Wysokosc podstawy tekstowy', 'Pomiar przyrzadem 1 (niższa)', 'Pomiar przyrzadem 2 (wyższa)',
            'Widzialnosc', 'Status pomiaru WID', 'Widzialnosc operatora', 'Status pomiaru WIDO',
            'Widzialnosc automat', 'Status pomiaru WIDA', 'Zachmurzenie ogólne', 'Status pomiaru NOG',
            'Kierunek wiatru', 'Status pomiaru KRWR', 'Prędkosc wiatru', 'Status pomiaru FWR ',
            'Poryw wiatru ', 'Status pomiaru PORW ', 'Temperatura powietrza', 'Status pomiaru TEMP',
            'Temperatura termometru zwilżonego', 'Status pomiaru TTZW', 'Wskaznik wentylacji',
            'Wskaznik lodu', 'Cisnienie pary wodnej', 'Status pomiaru CPW', 'Wilgotnosc względna',
            'Status pomiaru WLGW ', 'Temperatura punktu rosy', 'Status pomiaru TPTR', 'Cisnienie na pozimie stacji',
            'Status pomiaru PPPS ', 'Cisnienie na pozimie morza', 'Status pomiaru PPPM', 'Charakterystyka tendencji', 'Wartosc tendencji',
            'Status pomiaru APP', 'Opad za 6 godzin', 'Status pomiaru WO6G', 'Rodzaj opadu za 6 godzin',
            'Status pomiaru ROPT', 'Pogoda biezaca', 'Pogoda ubiegla', 'Zachmurzenie niskie', 'Status pomiaru CLCM',
            'Chmury CL', 'Status pomiaru CHCL', 'Chmury CL tekstem', 'Chmury CM', 'Status pomiaru CHCM',
            'Chmury CM tekstem', 'Chmury CH [kod]', 'Status pomiaru CHCH', 'Chmury CH tekstem', 'Stan gruntu',
            'Status pomiaru SGRN', 'Niedosyt wilgotnosci', 'Status pomiaru DEFI', 'Usłonecznienie', 'Status pomiaru USLN',
            'Wystapienie rosy', 'Status pomiaru ROSW', 'Poryw maksymalny za okres WW', 'Status pomiaru PORK',
            'Godzina wystapienia porywu', 'Minuta wystapienia porywu', 'Temperatura gruntu -5', 'Status pomiaru TG05',
            'Temperatura gruntu -10', 'Status pomiaru TG10','Temperatura gruntu -20', 'Status pomiaru TG20',
            'Temperatura gruntu -50', 'Status pomiaru TG50', 'Temperatura gruntu -100', 'Status pomiaru TG100',
            'Temperatura minimalna za 12 godzin', 'Status pomiaru TMIN ', 'Temperatura maksymalna za 12 godzin', 'Status pomiaru TMAX ',
            'Temperatura minimalna przy gruncie za 12 godzin', 'Status pomiaru TGMI',
            'Równoważnik wodny sniegu', 'Status pomiaru RWSN', 'Wysokosć pokrywy snieżnej', 'Status pomiaru PKSN',
            'Wysokosć swieżo spadłego sniegu', 'Status pomiaru HSS', 'Wysokosć sniegu na poletku', 'Status pomiaru GRSN',
            'Gatunek sniegu', 'Ukształtowanie pokrywy', 'Wysokosć próbki', 'Status pomiaru HPRO',
            'Ciężar próbki', 'Status pomiaru CIPR')
colnames(x) <- colnames

# TEMP
temp <- x %>% select('Rok', 'Miesiac', 'Dzien', 'Godzina', 'Temperatura powietrza')

temp %>%
  group_by(rok) %>%
  summarise(mean_year = mean(temperatura_powietrza),
            sd_year = sd(temperatura_powietrza)) %>%
  ggplot(aes(x = rok, y = mean_year))+
  geom_point()+
  geom_errorbar(aes(ymin = mean_year - sd_year,
                    ymax = mean_year + sd_year))

temp %>%
  ggplot(aes(x = rok, y = temperatura_powietrza, group = rok))+
  geom_boxplot()+
  geom_smooth(method = "lm")
temp %>%
  ggplot(aes(x = rok, y = temperatura_powietrza))+
  geom_jitter(alpha = .1)+
  geom_smooth(method = "lm")+
  facet_wrap(~miesiac)

temp_fct <- temp %>%
  mutate(rok = as.factor(rok),
         miesiac = as.factor(miesiac))

mod_lm <- lm(temperatura_powietrza ~ rok + miesiac, data = temp)

years <- unique(temp_fct$rok)
months <- unique(temp_fct$miesiac)
trends <- c()
for(month in seq_along(months)){
  x <- temp %>%
    filter(miesiac == month)
  mod_lm <- lm(temperatura_powietrza ~ rok, data = x)
  print(summary(mod_lm))
  print('###########################')

  slope <- mod_lm$coefficients[which(names(mod_lm$coefficients) == "rok")]
  trends[month] <- slope
}
temp %>%
  select(miesiac) %>%
  distinct() %>%
  mutate(trend = trends) %>%
  arrange(desc(trends)) %>%
  mutate(miesiac = factor(miesiac, ordered = TRUE, levels = miesiac)) %>%
  ggplot(aes(x = miesiac, y = trend))+
  geom_col()
# SNOW -------------------------------------------------------------------------
snow <- x %>% select('Rok', 'Miesiac', 'Dzien', 'Godzina',
                     'Wysokosć pokrywy snieżnej',
                     'Wysokosć swieżo spadłego sniegu',
                     'Wysokosć sniegu na poletku', 'Gatunek sniegu', 'Opad za 6 godzin',
                     'Rodzaj opadu za 6 godzin')
snow <- snow %>%
  #head(100) %>%
  dplyr::mutate(
    Miesiac = stringr::str_pad(string = Miesiac, width = 2, side = 'left', "0"),
    Dzien = stringr::str_pad(string = Dzien, width = 2, side = 'left', "0"),
    Godzina = stringr::str_pad(string = Godzina, width = 2, side = 'left', "0")
  ) %>%
  dplyr::group_by(Rok, Miesiac, Dzien, Godzina) %>%
  dplyr::do(.,
            mutate(.,
                   date_raw = paste0(
                     paste(Rok, Miesiac, Dzien, sep='-'),
                     " ", Godzina, ":00:00")
                   )
            ) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    ymd_h = lubridate::as_datetime(date_raw)
  )


usethis::use_data(snow)

snow %>%
  filter(`Wysokosć pokrywy snieżnej` != 998) %>%
  ggplot(aes(x = ymd_h, y = `Wysokosć pokrywy snieżnej`)) +
  geom_point()+
  geom_line()
snow %>%
  filter(`Wysokosć pokrywy snieżnej` != 0) %>%
  ggplot(aes(x = `Wysokosć pokrywy snieżnej`)) +
  geom_histogram()

snow %>%
  filter(`Wysokosć swieżo spadłego sniegu` != 0,
         `Wysokosć swieżo spadłego sniegu` < 250) %>%
  ggplot(aes(x= `Wysokosć swieżo spadłego sniegu`)) +
  geom_histogram()

snow %>%
  filter(`Wysokosć pokrywy snieżnej` != 998,
         `Rodzaj opadu za 6 godzin` %in% c(6,7),
         Rok %in% c(2017,2018)) %>%
  ggplot(aes(x = ymd_h, y = `Opad za 6 godzin`)) +
  geom_line()+
  facet_wrap(~`Rodzaj opadu za 6 godzin`,ncol = 1)


snow %>%
  filter(`Wysokosć pokrywy snieżnej` != 998,
         `Rodzaj opadu za 6 godzin` %in% c(6,7)
         #Rok %in% c(2017,2018)
         ) %>%
  mutate(r_m = paste(Rok, Miesiac, sep= '-')) %>%
  group_by(r_m,`Rodzaj opadu za 6 godzin`) %>%
  summarize(opad_suma = sum(`Opad za 6 godzin`)) %>%
  ggplot(aes(x = r_m, y = opad_suma)) +
  geom_col()+
  facet_wrap(~`Rodzaj opadu za 6 godzin`,ncol = 1)
