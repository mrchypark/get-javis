# devtools::install_github("hrbrmstr/slackr")
pack<-list("RSelenium","httr","rvest","jsonlite","slackr","lubridate")
lapply(pack,require, character.only = TRUE)
load("/home/auth.RData")

times<-1
bef<-""
to<-today()

while(times>0){
print(paste0(today()," / ",times))
#Sys.sleep(60)
times<-times+1
      if(today()!=to){times<-1}
      to<-today()

# email  <- "XXXXXXXXX"
# passwd <- "XXXXXXXXX"
# incoming_webhook_url<-"XXXXXXX"
# api_token<-"XXXXXXXXXXX"
# save(email,passwd,incoming_webhook_url,api_token,file="auth.RData")\
option(warn=-1)
pJS <- phantom()
remDr <- remoteDriver(browserName = "phantomjs")
remDr$open()
remDr$navigate("https://manager.jobis.co/login")

webElem <- remDr$findElement("name","useremail")
webElem$sendKeysToElement(list(email))
webElem <- remDr$findElement("name", "passwd")
webElem$sendKeysToElement(list(passwd))
webElem <- remDr$findElement("class","form-submit")
webElem$clickElement()

remDr$navigate("https://manager.jobis.co/receipts#tab2")
data <- remDr$getPageSource()[[1]]
remDr$close()
pJS$stop() 
chk<-read_html(data) %>% html_nodes("a.has-ul span span.badge") %>% html_text()
slackrSetup(channel="#test", 
            incoming_webhook_url=incoming_webhook_url,
            api_token=api_token)

if(chk[1]!="0"){
            text_slackr(iconv("개인 영수증이 확인되었습니다. 수정해 주세요.",to="UTF-8"), as_user=FALSE)
            send_chk<-chk
            }
      slackrSetup(channel="#jobisbotchk", 
            incoming_webhook_url=incoming_webhook_url,
            api_token=api_token)
      slackr_msg(paste0(today()," / ",times))
      # tem<-readLines("sel.Rout")
      # msg<-diff(tem,bef)
      # slackr_msg(msg)
      # bef<-tem

}
