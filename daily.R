pack<-list("httr","rvest","jsonlite","lubridate","dplyr","tidyr")
lapply(pack,require, character.only = TRUE)

load("./auth.RData")
load("./use.RData")

strDate<-Sys.Date() %>%
  substr(1,8) %>%
  paste0("01") %>%
  as.Date
endDate<- strDate %m+% months(1)

thmonth <- usage %>%
  filter(as.Date(useDate) >= strDate, as.Date(useDate) < endDate)

totamt <- 
  thmonth %>%
  group_by(purpose) %>%
  summarise(sum=sum(amount))

totamt$sumc <- formatC(totamt$sum, format="d", big.mark=",")

warnpp <- thmonth[is.na(thmonth$purpose),"user"] %>% unique %>% as.character()

cont<-paste0("안녕하세요 금일의 예산 현황입니다.\n\n",
             "\t총 사용 금액: ", formatC(sum(totamt$sum), format="d", big.mark=","), "원\n",
             "\t접 대 비: ", totamt[totamt$purpose=="식대","sumc"] %>% as.character(), 
             "원 / 540,000원(", totamt[totamt$purpose=="식대","sum"]/540000*100 %>% round(2),"%)\n",
             "\t식음료대: ", totamt[totamt$purpose=="음료","sumc"] %>% as.character(), 
             "원 / 300,000원(", totamt[totamt$purpose=="음료","sum"]/540000*100 %>% round(2),"%)\n",
             "\t소모품비: ", totamt[totamt$purpose=="사무용품","sumc"] %>% as.character(), 
             "원 / 400,000원(", totamt[totamt$purpose=="사무용품","sum"]/540000*100 %>% round(2),"%)\n\n")
if(!identical(warnpp, character(0))){
  war<-paste0(paste0(warnpp, collapse = ", "),"님 께서는 영수증 메모를 입력해주세요.\n",
  "메모는 아래 3가지 중 하나를 사용해주세요.\n",
  "\t식대 : 접대비용입니다.\n",
  "\t음료 : 식음료 대 비용입니다.(카페는 모두 접대입니다!)\n",
  "\t사무용품 : 소모품 비용입니다.\n\n",
  "위 3가지 이외의 영수증은 입력하지 않으셔도 좋습니다.\n")
  cont<-paste0(cont, war)
}
end<-("감사합니다. 오늘도 좋은 하루되세요!")
cont<-paste0(cont, end)
cat(cont)

POST(incoming_webhook_url,body=list(text=iconv(cont,to="UTF-8")),encode="json")
