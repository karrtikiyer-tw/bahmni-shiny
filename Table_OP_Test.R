library(dplyr)
library(readr)
library(data.table)
library(purrr)

df_tmp <- data.frame(x=c("ab","adsb","cdfs"),y=c("1","2","3"))
col_bf <- c("x")
col_af <- c("x","y")
df_tmp[!col_af %in% col_bf]
df_tmp_1 <- as.data.frame(df_tmp %>% map(~ as.numeric(as.character(.)))) %>% 
  map_lgl(~sum(is.na(.)) ==0)
col_n <- names(df_tmp_1)[df_tmp_1]
df_tmp_2 <- df_tmp %>% mutate_each_(funs(as.numeric(as.character(.))), col_n)
numeric_cols <- obs_tod_pres %>% map_lgl(is.numeric)
names(obs_tod_pres)[obs_tod_pres %>% map_lgl(is.numeric)]
# %>% 
#   group_by(PatID,Gender,Age,ObsDate,Location) %>% 
#   summarise_each(funs(if(is.numeric(.)) mean(., na.rm = TRUE) else first(.)))
obs_tod_pres_2 <- as.data.frame(obs_tod_pres_1 %>% map(function(x){
  ifelse(is.na(x),"",x)
}))

obs_tod_pres <- read_csv("observations_fp_md.csv")
obs_tod_pres <- obs_tod_pres %>% mutate(Gender = as.factor(ifelse(Gender==F,"F","M")))
tableop <- ftable(obs_tod_pres[c("Gender","Delivery.Note..Method.of.Delivery","Delivery.Note..Fetal.Presentation")])

# obs_tod_pres_1 <- obs_tod_pres %>% rename(PatID = `Patient Identifier`,ObsDate = `Obs Date`) 
# 
# obs_tod_pres_1<-obs_tod_pres_1 %>% replace(is.na(obs_tod_pres_1),"")
# df <- data.table(obs_tod_pres_1)
# 
# df1 <- df[, lapply(.SD, paste0, collapse=" "), by=list(PatID,Gender,Age,ObsDate,Location)]
# df1 <- as.data.frame(df1)
# df1[, sapply(df1, is.character)] <-
#   sapply(df1[, sapply(df1, is.character)],
#          str_trim)
# grp_cols <- c("Delivery Note, Method of Delivery","Delivery Note, Fetal Presentation")
# dots <- lapply(grp_cols, as.symbol)
# tmp_0 <- table(df1[c("Delivery Note, Method of Delivery","Delivery Note, Fetal Presentation")])
# 
# 
# 
# 
# tmp1 <- ftable(df1[c("Delivery Note, Method of Delivery","Delivery Note, Fetal Presentation")], 
#                deparse.level = 1, exclude = c(0))
# tmp2 <- ftable(df1[c("Delivery Note, Method of Delivery","Delivery Note, Fetal Presentation", "Gender")])
# 
# ftable(df1[c("Delivery Note, Fetal Presentation")])


df_tmp <- read_csv("df_tmp.csv")
df_tmp_bf <- read_csv("df_tmp_before_spread.csv")

tableop <- table(df_tmp_bf[names(df_tmp_bf)[3:2]])
tableop
obs_4ANCComplete <- read_csv("observations_ANC4Completed.csv")
proper<-function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))
library(tidyr)
obs_4ANCComplete_spread <- obs_4ANCComplete %>% spread(Question, Answer)
with(obs_4ANCComplete_spread, table(ANC..Completed.4.ANC.visits, exclude = proper(as.character(FALSE))))
names(obs_4ANCComplete_spread) = make.names(names(obs_4ANCComplete_spread))
xtabs(~ANC..Completed.4.ANC.visits, data = obs_4ANCComplete_spread,exclude = c(F))

obs_anc <- read_csv("obs_anc.csv")
names(obs_anc) = make.names(names(obs_anc))
obs_anc <- obs_anc %>% select(Patient.Identifier, Obs.Date,Question, Answer)
obs_anc_1st_anytime <- obs_anc %>% filter(Answer=="ANC, 1st (any time)")
obs_anc <- obs_anc %>% filter(Answer!="ANC, 1st (any time)")
obs_anc_spread <- obs_anc %>% spread(Question, Answer) 
obs_anc_spread <- obs_anc_spread %>% mutate(ANC..Completed.4.ANC.visits = as.logical(ANC..Completed.4.ANC.visits))
names(obs_anc_spread) = make.names(names(obs_anc_spread))
# with(obs_anc_spread, table(ANC..ANC.Visit, 
#                            exclude = c(NA,proper(as.character(FALSE)))
#                            )
#      )

# x <- ftable(mtcars[c("cyl", "vs", "am", "gear")])
# x
# ftable(x, row.vars = c(2, 4))
ftable(obs_anc_spread[c("ANC..ANC.Visit","ANC..Completed.4.ANC.visits")], exclude = c(NA,proper(as.character(FALSE))))

#BAH265619
obs_anc_1st_anytime_spread <- obs_anc_1st_anytime %>% spread(Question, Answer)
names(obs_anc_1st_anytime_spread)[3] = "FirstAnyTime"
obs_anc_1st_anytime_spread <- obs_anc_1st_anytime_spread %>% 
  mutate(FirstAnyTime = T)
obs_anc_total_spread <- obs_anc_spread %>% 
  left_join(obs_anc_1st_anytime_spread) %>% 
  mutate(FirstAnyTime = replace(FirstAnyTime, 
                                which(is.na(FirstAnyTime)), 
                                F)
  )
ftable(obs_anc_total_spread[c("ANC..ANC.Visit","ANC..Completed.4.ANC.visits", "FirstAnyTime")], 
       row.vars  = c(1, 2, 3)
)

tmp1 <- ftable(obs_anc_total_spread[c("ANC..ANC.Visit")], exclude = c(NA,"ANC, 2nd (per protocol)",
                                                                      "ANC, 3rd (per protocol)", 
                                                                      "ANC, 4th (per protocol)",
                                                                      "ANC, ANC Visit, Other"),
               row.vars = c(1)
)
tmp2<-ftable(obs_anc_total_spread$ANC..Completed.4.ANC.visits, exclude = c(NA,FALSE), row.vars = c(1), 
             deparse.level = 1)

tmp3 <- ftable(obs_anc_total_spread$FirstAnyTime, exclude = c(NA,FALSE), row.vars = c(1),deparse.level = 1)

tab <- rbind(tmp1, tmp2, tmp3)
class(tab) <- "ftable"
names(tab) <- c("Count","","")
attr(tab, "col.vars") <- list("Count")
attr(tmp2, "row.vars") <- list("ANC 4 Visits completed")
attr(tmp3, "row.vars") <- list("ANC First Any Time")
attr(tab, "row.vars") <- list(Var = unlist(c(attr(tmp1, "row.vars"), 
                                             attr(tmp2, "row.vars"),
                                             attr(tmp3, "row.vars"))))


print(tab)

# obs_anc_total_long <- obs_anc_total_spread %>% gather(Key, Value, ANC..Completed.4.ANC.visits)

# if(length(grp_cols)==3){
#   index<-grep(grp_cols[3], colnames(obs))
#   colnames(obs)[index]="Answer_Unique"
#   df <- obs %>% 
#     group_by_(.dots=dots[1:2]) %>% 
#     summarise(Answer_Unique=toString(unique(Answer_Unique)))
#   col_df <- colnames(df)
#   df <- df %>% spread_(col_df[2],col_df[3])
#   tableop <- table(df[names(df)[3:2]])
#   tableop.df <- as.data.frame.matrix(tableop)
# }
# else if(length(grp_cols)==2){
#   df <- obs %>% 
#     group_by_(.dots=dots) %>% 
#     summarise(n = n()) %>% select(-n)
#   tableop <- table(df[names(df)[2]])
#   tableop.df <- as.data.frame(tableop)
# }
output <- 
  matrix(paste("Content", LETTERS[1:16]), 
         ncol=4, byrow = TRUE)

library(htmlTable)
htmlTable(output,
          header =  paste(c("1st", "2nd",
                            "3rd", "4th"), "header"),
          rnames = paste(c("1st", "2nd",
                           "3rd", "4th"), "row"),
          rgroup = c("Group A",
                     "Group B"),
          n.rgroup = c(2,2),
          cgroup = c("Cgroup 1", "Cgroup 2&dagger;"),
          n.cgroup = c(2,2), 
          caption="Basic table with both column spanners (groups) and row groups",
          tfoot="&dagger; A table footer commment")



library(ztable)
options(ztable.type="html")
zt <- ztable(output, 
             caption = "Average age in Sweden counties.",
             zebra.type = 1,
             zebra = "peach",
             align=paste(rep("r", ncol(output) + 1), collapse = ""))
# zt <- addcgroup(zt,
#                 cgroup = cgroup,
#                 n.cgroup = n.cgroup)
# Causes an error:
# Error in if (result <= length(vlines)) { : 
zt <- addrgroup(zt, 
                rgroup = c("1st&nbsp;period", 
                           "2nd&nbsp;period",
                           "3rd&nbsp;period"),
                n.rgroup = rep(5, 3))

print(zt)


fasting_sugar <- read_csv("obs_fast_sugar_1.csv")
fasting_sugar <- fasting_sugar %>% mutate(Gender = as.factor(Gender))
fast_table <- ftable(Gender + Age.Group ~  Obs.Date + Blood.Sugar.Fasting.Group, data = fasting_sugar)
  #ftable(fasting_sugar[c("Gender","Obs.Date","Age.Group","Blood.Sugar.Fasting.Group")])
fast_table

fasting_sugar_1 <- fasting_sugar %>% mutate(Gender = replace(Gender, which(Gender == "F" & Age.Group == "Elders"), "M"))
fast_table_1 <- ftable(Gender + Age.Group ~  Obs.Date + Blood.Sugar.Fasting.Group, data = fasting_sugar_1)

htmlTable(tableop, rnames = rep(unlist(attr(tableop, "row.vars")[2]), 3), 
          rgroup=unlist(attr(tableop, "row.vars")[1]), n.rgroup = c(1,1),
          cgroup = unlist(attr(tableop, "col.vars")[[1]]),n.cgroup = c(1,1), caption =  names(attr(tableop, "col.vars")) )