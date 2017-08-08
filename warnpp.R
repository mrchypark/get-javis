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

warnpp <- thmonth[is.na(thmonth$purpose),"user"] %>% unique %>% as.character()

if(!identical(warnpp, character(0))){
  war<-paste0(paste0(warnpp, collapse = ", "),
              "님 께서는 영수증 메모를 입력해주세요.\n",
              "메모는 아래 3가지 중 하나를 사용해주세요.\n",
              "\t식대 : 접대비용입니다.\n",
              "\t음료 : 식음료 대 비용입니다.(카페는 모두 접대입니다!)\n",
              "\t사무용품 : 소모품 비용입니다.\n\n",
              "위 3가지 이외의 영수증은 입력하지 않으셔도 좋습니다.\n")
}

POST(incoming_webhook_url,body=list(text=iconv(war, to="UTF-8")),encode="json")