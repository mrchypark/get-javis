# devtools::install_github("hadley/rvest")

pack<-list("httr","rvest","jsonlite","RPushbullet","lubridate")
lapply(pack,require, character.only = TRUE)

load("./auth.RData")

# email  <- "XXXXXXXXX"
# passwd <- "XXXXXXXXX"
# incoming_webhook_url <- "XXXXXXXXXXXXXXXXXXXX"
# save(email,passwd,incoming_webhook_url, file="auth.RData")

## pbSetup()

jobis <- html_session("https://manager.jobis.co/login")

login <- jobis %>%
  html_node("form") %>%
  html_form() %>%
  set_values(
    useremail = email,
    passwd = passwd
  )

logged_in <- jobis %>% submit_form(login)

chk_p <- logged_in %>%
  jump_to("/dashboard") %>%
  html_nodes(".badge-primary") %>%
  html_text()

if(length(chk_p)==3){chk_p<-chk_p[2]}

if(chk_p!="0"){
  cont<-paste0("개인 영수증이 ",chk_p,"건 확인되었습니다.\n https://manager.jobis.co/receipts#tab2")
  pbPost("note", title="개인 영수증 확인",body=cont, verbose = T)
}

if(chk_p=="0"){
  cont<-paste0("개인 영수증이 없습니다. 좋은 하루 되세요!")
  pbPost("note", title="개인 영수증 확인",body=cont, verbose = T)
}


usage <- logged_in %>%
  jump_to("/ajax_card/0")

usage <- usage$response$content %>% rawToChar() %>% fromJSON

usage <- data.frame(usage$data, stringsAsFactors = F)
names(usage)<-c("num","useDate","user","purpose","comName","submitDate","state","rejactRs","amount","tax")
usage$num <- as.numeric(usage$num)
usage$useDate<-ymd_hm(usage$useDate)
usage$user <- as.factor(usage$user)
usage$purpose <- factor(usage$purpose, levels = c("식대","음료","사무용품"))
usage$submitDate<-ymd_hm(usage$submitDate)
usage$state<-unlist(lapply(usage$state, function(x) html_text(read_html(x))))
usage$amount <- as.numeric(gsub(",","",usage$amount))
usage$tax <- as.numeric(gsub(",","",usage$tax))

save(usage,file="use.RData")

## rander()