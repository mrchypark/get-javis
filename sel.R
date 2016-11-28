devtools::install_github("hrbrmstr/slackr")
pack<-list("RSelenium","httr","rvest","jsonlite","slackr")
lapply(pack,require, character.only = TRUE)

# email  <- "XXXXXXXXX"
# passwd <- "XXXXXXXXX"
# incoming_webhook_url<-"XXXXXXX"
# api_token<-"XXXXXXXXXXX"
# save(email,passwd,incoming_webhook_url,api_token,file="auth.RData")

load("auth.RData")
remDr <- remoteDriver(remoteServerAddr = "192.168.99.100",
                                               port = 32768L)
remDr$open()
Sys.sleep(5)
remDr$navigate("https://manager.jobis.co/login")

webElem <- remDr$findElement(using = "xpath", "/html/body/div[2]/div/div/section/div/div/form/div/div/div[1]/div/input")
webElem$sendKeysToElement(list(email))
webElem <- remDr$findElement(using = "xpath", "/html/body/div[2]/div/div/section/div/div/form/div/div/div[2]/div/input")
webElem$sendKeysToElement(list(passwd))
webElem <- remDr$findElement(using = "xpath", "/html/body/div[2]/div/div/section/div/div/form/div/div/div[4]/input")
webElem$clickElement()
Sys.sleep(5)

remDr$navigate("https://manager.jobis.co/receipts#tab2")

remDr$navigate("https://manager.jobis.co/ajax_card/0?_=1479986686578")
tem <- remDr$getPageSource()[[1]]
tem <- tem %>% read_html() %>% html_node("pre") %>% html_text()
fromJSON(tem)

slackrSetup(channel="#teamroom", 
            incoming_webhook_url=incoming_webhook_url,
            api_token=api_token)

text_slackr(iconv("다",to="UTF-8"))


