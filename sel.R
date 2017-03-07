# devtools::install_github("hadley/rvest")
pack<-list("httr","rvest","jsonlite","slackr","lubridate")
lapply(pack,require, character.only = TRUE)
load("./auth.RData")

# email  <- "XXXXXXXXX"
# passwd <- "XXXXXXXXX"
# incoming_webhook_url<-"XXXXXXX"
# api_token<-"XXXXXXXXXXX"
# save(email,passwd,incoming_webhook_url,api_token,file="auth.RData")


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
  cont<-paste0("개인 영수증이 ",chk_p,"건 확인되었습니다. 수정해 주세요.")
  POST(incoming_webhook_url,body=list(text=iconv(cont,to="UTF-8")),encode="json")
  send_chk<-chk_p
}

usage <- logged_in %>%
  jump_to("/ajax_card/0") %>%
  read_html() %>%
  html_nodes("p") %>%
  html_text() %>%
  fromJSON()

usage <- as.data.frame(usage$data)
names(usage)<-c("num","useDate","user","purpose","comName","submitDate","state","rejactRs","amount","tax")

