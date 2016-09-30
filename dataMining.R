library(magrittr)

# Defines the research request index...since this is small it won't be sharded too much
requestIndex <- '
{
"settings" : {
"index" : {
"number_of_shards" : 3,
"number_of_replicas" : 1
},
"mappings": {
"request" : {
"properties": {
"id": { "type": "integer" },
"Status": { "type": "string", "index": "not_analyzed" },
"StatusDate": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
"UpdatedBy": { "type": "string", "index": "not_analyzed" },
"AssignedTo": { "type": "string", "index": "not_analyzed" },
"InternalExternal": { "type": "string", "index": "not_analyzed" },
"Title": { "type": "string", "index": "analyzed", "analyzer": "english" },
"FName": { "type": "string", "index": "not_analyzed" },
"LName": { "type": "string", "index": "not_analyzed" },
"Address1": { "type": "string", "index": "not_analyzed" },
"Address2": { "type": "string", "index": "not_analyzed" },
"City": { "type": "string", "index": "not_analyzed" },
"State": { "type": "string", "index": "not_analyzed" },
"Zip": { "type": "string", "index": "not_analyzed" },
"Email": { "type": "string", "index": "not_analyzed" },
"Phone": { "type": "string", "index": "not_analyzed" },
"FCPSEmp": { "type": "string", "index": "not_analyzed" },
"FCPSPos": { "type": "string", "index": "not_analyzed" },
"FCPSLoc": { "type": "string", "index": "not_analyzed" },
"CollegeYN": { "type": "string", "index": "not_analyzed" },
"CollegeName": { "type": "string", "index": "not_analyzed" },
"IRBApproved": { "type": "string", "index": "not_analyzed" },
"IRBApprovalDep": { "type": "string", "index": "not_analyzed" },
"SponsorFName": { "type": "string", "index": "not_analyzed" },
"SponsorLName": { "type": "string", "index": "not_analyzed" },
"SponsorEmail": { "type": "string", "index": "not_analyzed" },
"OrgYN": { "type": "string", "index": "not_analyzed" },
"OrgName": { "type": "string", "index": "not_analyzed" },
"OrgContactFName": { "type": "string", "index": "not_analyzed" },
"OrgContactLName": { "type": "string", "index": "not_analyzed" },
"OrgContactEmail": { "type": "string", "index": "not_analyzed" },
"ResProblem": { "type": "string", "index": "analyzed", "analyzer": "english" },
"ResQuestions": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Hypothesis": { "type": "string", "index": "analyzed", "analyzer": "english" },
"ResDesign": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Methodology": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Materials": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Schools": { "type": "string", "index": "analyzed", "analyzer": "whitespace" },
"ParticipantSample": { "type": "string", "index": "analyzed", "analyzer": "english" },
"FCPSGoals": { "type": "string", "index": "analyzed", "analyzer": "english" },
"DataCollected": { "type": "string", "index": "analyzed", "analyzer": "english" },
"StudentRecords": { "type": "string", "index": "analyzed", "analyzer": "english" },
"DataAnalysis": { "type": "string", "index": "analyzed", "analyzer": "english" },
"TimeFrame": { "type": "string", "index": "analyzed", "analyzer": "whitespace" },
"TimeRequired": { "type": "string", "index": "analyzed", "analyzer": "whitespace" },
"Confidentiality": { "type": "string", "index": "not_analyzed" },
"FileName1": { "type": "string", "index": "not_analyzed" },
"FileName2": { "type": "string", "index": "not_analyzed" },
"FileName3": { "type": "string", "index": "not_analyzed" },
"FileName4": { "type": "string", "index": "not_analyzed" },
"Agree": { "type": "string", "index": "not_analyzed" },
"DateNeeded": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
"DataUsedFor": { "type": "string", "index": "analyzed", "analyzer": "english" },
"DateSubmitted": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
"Comments": { "type": "string", "index": "analyzed", "analyzer": "english" },
"RequestType": { "type": "string", "index": "analyzed" },
"TypeStudent": { "type": "string", "index": "analyzed" },
"TypeFinance": { "type": "string", "index": "analyzed" },
"TypePersonnel": { "type": "string", "index": "analyzed" },
"FileType": { "type": "string", "index": "analyzed" }
}
}
}
}
}'

# Reads the data from an HTML table
theData <- xml2::read_html("~/Desktop/researchRequestData.html") %>% rvest::html_table()

# Gets the data frame element out of the list object
theData <- theData[[1]]

# Establishes connection to elasticsearch database locally
elastic::connect("localhost")
httr::DELETE('localhost:9200/research_requests')

theData$StatusDate <- lubridate::as_date(theData$StatusDate)
theData$DateSubmitted <- lubridate::as_date(theData$DateSubmitted)
theData$DateNeeded <- lubridate::as_date(theData$DateNeeded)

# Creates the index with the settings in the requestIndex object
elastic::index_create("research_requests", body = requestIndex, raw = FALSE)

# Loads the documents into the index
elastic::docs_bulk(theData, index = "research_requests", type = "request", es_ids = TRUE, raw = FALSE)
