
remDr$navigate("https://manager.jobis.co/company#tab2")

tem <- remDr$getPageSource()[[1]]
tem <- tem %>% read_html() %>% html_node("pre") %>% html_text()
fromJSON(tem)

slackrSetup(channel="#test", 
            incoming_webhook_url=incoming_webhook_url,
            api_token=api_token)

slackr_msg(iconv("테스트 중입니다.",to="UTF-8"))



library(MASS)
str(Cars93)
with(Cars93, cov(x=MPG.highway, 
                                   y=Weight, 
                                   use="complete.obs", 
                                   method=c("pearson")))
