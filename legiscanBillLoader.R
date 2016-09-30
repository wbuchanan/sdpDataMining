library(magrittr)
library(doMC)
registerDoMC(cores = 8)
source('~/Desktop/msLegislation/legiscanR/R/fileStructures.R')
source('~/Desktop/msLegislation/legiscanR/R/fileLists.R')
httr::DELETE('127.0.0.1:9200/legiscan/')
files <- fileStructure("/Users/fcps/Desktop/kyLegislation/") %>% fileLists()
billDoc <- '
{
	"settings": {
		"index": {
			"integer_of_shards": 5,
			"integer_of_replicas": 1
		}
	},
	"mappings": {
		"bill_doc": {
			"properties": {
				"amendments": {
					"type": "nested",
					"properties": {
						"adopted": { "type": "long" },
						"amendment_id": { "type": "long" },
						"date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
						"description": { "type": "string", "index": "analyzed", "analyzer": "english" },
						"mime": { "type": "string", "index": "not_analyzed" },
						"state_link": { "type": "string", "index": "not_analyzed" },
						"title": { "type": "string", "index": "analyzed", "analyzer": "english" },
						"url": { "type": "string", "index": "not_analyzed" }
					}
				},
				"bill_id": { "type": "integer" },
				"bill_number": { "type": "string", "index": "not_analyzed" },
				"bill_type": { "type": "string", "index": "not_analyzed" },
				"body": { "type": "string", "index": "analyzed", "analyzer": "english" },
				"body_id": { "type": "integer" },
				"calendar": {
					"type": "nested",
					"properties": {
						"date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
						"description": { "type": "string", "index": "analyzed", "analyzer": "english" },
						"location": { "type": "string", "index": "not_analyzed" },
						"time": { "type": "string", "index": "not_analyzed" },
						"type": { "type": "string", "index": "not_analyzed" },
						"type_id": { "type": "long" }
					}
				},
				"change_hash": { "type": "string", "index": "not_analyzed" },
				"committee": {
					"type": "nested",
					"properties": {
						"chamber": { "type": "string", "index": "not_analyzed" },
						"committee_id": { "type": "long" },
						"name": { "type": "string", "index": "not_analyzed" }
					}
				},
				"completed": { "type": "integer" },
				"current_body": { "type": "string", "index": "not_analyzed" },
				"current_body_id": { "type": "integer" },
				"description": { "type": "string", "index": "analyzed", "analyzer": "english" },
				"history": {
					"type": "nested",
					"properties": {
						"action": { "type": "string", "index": "not_analyzed" },
						"chamber": { "type": "string", "index": "not_analyzed" },
						"chamber_id": { "type": "long" },
						"date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
						"importance": { "type": "integer" }
					}
				},
				"progress": {
					"type": "nested",
					"properties": {
						"date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
						"event": { "type": "string", "index": "not_analyzed" }
					}
				},
				"sasts": { "type": "nested" },
				"session": {
					"properties": {
						"session_id": { "type": "integer" },
						"session_name": { "type": "string", "index": "not_analyzed" },
						"session_title": { "type": "string", "index": "not_analyzed" }
					}
				},
				"sponsors": {
					"type": "nested",
					"properties": {
						"committee_id": { "type": "string", "index": "not_analyzed" },
						"committee_sponsor": { "type": "long" },
						"district": { "type": "string", "index": "not_analyzed" },
						"first_name": { "type": "string", "index": "not_analyzed" },
						"ftm_eid": { "type": "long" },
						"last_name": { "type": "string", "index": "not_analyzed" },
						"middle_name": { "type": "string", "index": "not_analyzed" },
						"name": { "type": "string", "index": "not_analyzed" },
						"nickname": { "type": "string", "index": "not_analyzed" },
						"party": { "type": "string", "index": "not_analyzed" },
						"party_id": { "type": "long" },
						"people_id": { "type": "long" },
						"role": { "type": "string", "index": "not_analyzed" },
						"role_id": { "type": "long" },
						"sponsor_order": { "type": "long" },
						"sponsor_type_id": { "type": "long" },
						"suffix": { "type": "string", "index": "not_analyzed" }
					}
				},
				"state": { "type": "string", "index": "no" },
				"state_id": { "type": "integer" },
				"state_link": { "type": "string", "index": "not_analyzed" },
				"status": { "type": "integer" },
				"status_date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
				"subjects": { "type": "nested" },
				"supplements": {
					"type": "nested",
					"properties": {
						"date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
						"description": { "type": "string", "index": "not_analyzed" },
						"mime": { "type": "string", "index": "not_analyzed" },
						"state_link": { "type": "string", "index": "not_analyzed" },
						"supplement_id": { "type": "long" },
						"title": { "type": "string", "index": "analyzed", "analyzer": "english" },
						"type": { "type": "string", "index": "not_analyzed" },
						"type_id": { "type": "string", "index": "not_analyzed" },
						"url": { "type": "string", "index": "not_analyzed" }
					}
				},
				"texts": {
					"type": "nested",
					"properties": {
						"date": { "type": "date", "format": "strict_date_optional_time||epoch_millis" },
						"doc_id": { "type" : "integer" },
						"mime": { "type": "string", "index" : "not_analyzed" },
						"state_link": { "type": "string", "index": "not_analyzed" },
						"text_size": { "type": "long" },
						"type": { "type": "string", "index": "not_analyzed" },
						"url": {  "type": "string", "index": "not_analyzed" }
					}
				},
				"title": { "type": "string", "index": "analyzed", "analyzer": "english" },
				"url": { "type": "string", "index": "not_analyzed" },
				"votes": { "type": "nested" }
			}
		}
	}
}'

listelems <- c("bill_id", "change_hash", "session", "url", "state_link", "completed", "status",
			   "status_date", "progress", "state", "state_id", "bill_number", "bill_type",
			   "body", "body_id", "current_body", "current_body_id", "title", "description",
			   "committee", "history", "sponsors", "sasts", "subjects", "texts", "votes",
			   "amendments", "supplements", "calendar")

httr::PUT('127.0.0.1:9200/legiscan', body = billDoc, encode = "json")
elastic::connect()
id <- 0

lev1nm <- names(files[["bills"]])

for (i in c(1:length(lev1nm))) {
	for (j in c(1:length(files[["bills"]][[i]]))) {
		id <<- id + 1
		doc <- jsonlite::fromJSON(files[["bills"]][[i]][[j]], simplifyVector = FALSE, flatten = FALSE) %>%
			unlist(recursive = FALSE, use.names = FALSE)
		names(doc) <- listelems
		subdate <- paste0(substring(doc[["session"]][["session_name"]], 1, 4), '-01-01')
		if (doc$status_date == '0000-00-00' || length(doc$status_date) == 0) doc$status_date <- subdate
		if (length(doc[["calendar"]]) >= 1 && "date" %in% names(doc[["calendar"]][[1]])) {
			for (w in c(1:length(doc[["calendar"]]))) {
				if (doc[["calendar"]][[w]][["date"]] == '0000-00-00') doc[["calendar"]][[w]][["date"]] <- subdate
			}
		}
		if (length(doc[["votes"]]) >= 1 && "date" %in% names(doc[["votes"]][[1]])) {
			for (w in c(1:length(doc[["votes"]]))) {
				if (doc[["votes"]][[w]][["date"]] == '0000-00-00') doc[["votes"]][[w]][["date"]] <- subdate
			}
		}
		if (length(doc[["supplements"]]) >= 1 && "date" %in% names(doc[["supplements"]][[1]])) {
			for (w in c(1:length(doc[["supplements"]]))) {
				if (doc[["supplements"]][[w]][["date"]] == '0000-00-00') doc[["supplements"]][[w]][["date"]] <- subdate
			}
		}
		if (length(doc[["amendments"]]) >= 1) {
			for (w in c(1:length(doc[["amendments"]]))) {
				if (doc[["amendments"]][[w]][["date"]] == '0000-00-00') doc[["amendments"]][[w]][["date"]] <- subdate
			}
		}

		if (length(doc[["progress"]]) >= 1) {
			for (x in c(1:length(doc[["progress"]]))) {
				if (doc[["progress"]][[x]][["date"]] == '0000-00-00') doc[["progress"]][[x]][["date"]] <- subdate
				doc[["progress"]][[x]][["event"]] <- factor(doc[["progress"]][[x]][["event"]],
															levels = c(1:12),
															labels = c("Introduced", "Engrossed", "Enrolled",
																	   "Passed", "Vetoed", "Failed", "Override",
																	   "Chaptered", "Refer", "Report Pass",
																	   "Report DNP", "Draft"))
			}
		}
		if (length(doc[["history"]]) >= 1) {
			for (y in c(1:length(doc[["history"]]))) {
				if (doc[["history"]][[y]][["date"]] == '0000-00-00') doc[["history"]][[y]][["date"]] <- subdate
			}
		}
		if (length(doc[["texts"]]) >= 1) {
			for (z in c(1:length(doc[["texts"]]))) {
				if (doc[["texts"]][[z]][["date"]] == '0000-00-00') doc[["texts"]][[z]][["date"]] <- subdate
			}
		}
		elastic::docs_create(index = "legiscan", type = "bill_doc", id = id, body = doc)
	}
}

