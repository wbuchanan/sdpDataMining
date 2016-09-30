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
"StatusDate": { "type": "date", "format": "yyyy-MM-dd HH:mm:ss" },
"UpdatedBy": { "type": "string", "index": "analyzed" },
"AssignedTo": { "type": "string", "index": "analyzed" },
"InternalExternal": { "type": "string", "index": "analyzed" },
"Title": { "type": "string", "index": "analyzed" },
"FName": { "type": "string", "index": "analyzed" },
"LName": { "type": "string", "index": "analyzed" },
"Address1": { "type": "string", "index": "analyzed" },
"Address2": { "type": "string", "index": "analyzed" },
"City": { "type": "string", "index": "analyzed" },
"State": { "type": "string", "index": "analyzed" },
"Zip": { "type": "string", "index": "analyzed" },
"Email": { "type": "string", "index": "analyzed" },
"Phone": { "type": "string", "index": "analyzed" },
"FCPSEmp": { "type": "string", "index": "analyzed" },
"FCPSPos": { "type": "string", "index": "analyzed" },
"FCPSLoc": { "type": "string", "index": "analyzed" },
"CollegeYN": { "type": "string", "index": "analyzed" },
"CollegeName": { "type": "string", "index": "analyzed" },
"IRBApproved": { "type": "string", "index": "analyzed" },
"IRBApprovalDep": { "type": "string", "index": "analyzed" },
"SponsorFName": { "type": "string", "index": "analyzed" },
"SponsorLName": { "type": "string", "index": "analyzed" },
"SponsorEmail": { "type": "string", "index": "analyzed" },
"OrgYN": { "type": "string", "index": "analyzed" },
"OrgName": { "type": "string", "index": "analyzed" },
"OrgContactFName": { "type": "string", "index": "analyzed" },
"OrgContactLName": { "type": "string", "index": "analyzed" },
"OrgContactEmail": { "type": "string", "index": "analyzed" },
"ResProblem": { "type": "string", "index": "analyzed", "analyzer": "english" },
"ResQuestions": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Hypothesis": { "type": "string", "index": "analyzed", "analyzer": "english" },
"ResDesign": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Methodology": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Materials": { "type": "string", "index": "analyzed", "analyzer": "english" },
"Schools": { "type": "string", "index": "analyzed" },
"ParticipantSample": { "type": "string", "index": "analyzed", "analyzer": "english" },
"FCPSGoals": { "type": "string", "index": "analyzed", "analyzer": "english" },
"DataCollected": { "type": "string", "index": "analyzed", "analyzer": "english" },
"StudentRecords": { "type": "string", "index": "analyzed", "analyzer": "english" },
"DataAnalysis": { "type": "string", "index": "analyzed", "analyzer": "english" },
"TimeFrame": { "type": "string", "index": "analyzed", "analyzer": "whitespace" },
"TimeRequired": { "type": "string", "index": "analyzed", "analyzer": "whitespace" },
"Confidentiality": { "type": "string", "index": "analyzed" },
"FileName1": { "type": "string", "index": "analyzed" },
"FileName2": { "type": "string", "index": "analyzed" },
"FileName3": { "type": "string", "index": "analyzed" },
"FileName4": { "type": "string", "index": "analyzed" },
"Agree": { "type": "string", "index": "analyzed" },
"DateNeeded": { "type": "date", "format": "yyyy-MM-dd HH:mm:ss" },
"DataUsedFor": { "type": "string", "index": "analyzed", "analyzer": "english" },
"DateSubmitted": { "type": "date", "format": "yyyy-MM-dd HH:mm:ss" },
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

# Creates the index with the settings in the requestIndex object
elastic::index_create("research_requests", body = requestIndex, raw = FALSE)

# Loads the documents into the index
elastic::docs_bulk(theData, index = "research_requests", type = "request",
           es_ids = TRUE, raw = FALSE)
