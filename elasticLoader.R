library(magrittr)
library(doMC)
source('~/Desktop/msLegislation/legiscanR/R/fileStructures.R')
source('~/Desktop/msLegislation/legiscanR/R/fileLists.R')
registerDoMC(cores = 16)

# Builds object with file list structure
files <- fileStructure("/Users/fcps/Desktop/kyLegislation/") %>% fileLists()

# Defines the legislation index settings
legiscan <- '{
"settings": {
"index": {
"number_of_shards" : 3,
"number_of_replicas" : 1
}
}
}'

httr::DELETE('127.0.0.1:9200/legislation')
httr::PUT('127.0.0.1:9200/legislation', body = legiscan, encode = "json")

# Handles munging all of the people data files
peeps <- plyr::ldply(as.list(unlist(files[["people"]])), .parallel = FALSE, .fun = function(x) {
	jsonlite::fromJSON(x, simplifyVector = TRUE, flatten = TRUE)[[1]] %>%
				dplyr::as_data_frame()
})

names(peeps) <- c("session_name", "people_id", "role_id", "role", "party_id", "party",
				 "committee_id", "name", "first_name", "middle_name", "last_name", "suffix",
				 "nickname", "ftm_eid", "district", "committee_sponsor")


# Establish connection to elasticsearch
elastic::connect("localhost")

# Loads the people into the index
elastic::docs_bulk(peeps, index = "legislation", type = "people",
				   es_ids = TRUE, raw = FALSE)

# Defines function for handling the data
nlegiBillJSON <- function(x) {
	billob <- jsonlite::fromJSON(x, simplifyVector = TRUE, flatten = TRUE)[["bill"]]
	billob <- c(billob, "session_id" = billob[["session"]][["session_id"]],
						"session_name" = billob[["session"]][["session_name"]])
	billob[["session"]] <- NULL
	billIDs <- billob[c("bill_id", "session_id")] %>% as.data.frame(stringsAsFactors = FALSE)

	if (length(billob[["progress"]]) != 0) progress <- as.data.frame(billob[["progress"]], stringsAsFactors = FALSE)
	else progress <- data.frame()


	if (length(billob[["committee"]]) != 0) committee <- as.data.frame(billob[["committee"]], stringsAsFactors = FALSE)
	else committee <- data.frame()

	if (length(billob[["history"]]) != 0) history <- as.data.frame(billob[["history"]], stringsAsFactors = FALSE)
	else history <- data.frame()

	if (length(billob[["sponsors"]]) != 0) sponsors <- as.data.frame(billob[["sponsors"]], stringsAsFactors = FALSE)
	else sponsors <- data.frame()

	if (length(billob[["sasts"]]) != 0) sasts <- as.data.frame(billob[["sasts"]], stringsAsFactors = FALSE)
	else sasts <- data.frame()

	if (length(billob[["subjects"]]) != 0) subjects <- as.data.frame(billob[["subjects"]], stringsAsFactors = FALSE)
	else subjects <- data.frame()

	if (length(billob[["texts"]]) != 0) texts <- as.data.frame(billob[["texts"]], stringsAsFactors = FALSE)
	else texts <- data.frame()

	if (length(billob[["votes"]]) != 0) votes <- as.data.frame(billob[["votes"]], stringsAsFactors = FALSE)
	else votes <- data.frame()

	if (length(billob[["amendments"]]) != 0) amendments <- as.data.frame(billob[["amendments"]], stringsAsFactors = FALSE)
	else amendments <- data.frame()

	if (length(billob[["supplements"]]) != 0) supplements <- as.data.frame(billob[["supplements"]], stringsAsFactors = FALSE)
	else supplements <- data.frame()

	if (length(billob[["calendar"]]) != 0) calendar <- as.data.frame(billob[["calendar"]], stringsAsFactors = FALSE)
	else calendar <- data.frame()

	if ("event" %in% names(progress)) {
		progress$event <- factor(progress$event,
							 levels = c(1:12),
							 labels = c("Introduced", "Engrossed", "Enrolled",
							 		   "Passed", "Vetoed", "Failed", "Override",
							 		   "Chaptered", "Refer", "Report Pass",
							 		   "Report DNP", "Draft"))
	}

	forDF <- c("bill_id", "session_id", "session_name", "change_hash", "url", "state_link",
			   "completed", "status", "status_date", "state", "state_id", "bill_number",
			   "bill_type", "body", "body_id", "current_body", "current_body_id", "title",
			   "description")

	plyr::l_ply(as.list(forDF), .fun = function(x) {
		if (is.null(billob[[x]])) billob[[x]] <<- NA
	})

	retval <- list("bill" = as.data.frame(billob[forDF], stringsAsFactors = FALSE),
				   "progress" = progress, "committee" = committee, "history" = history,
				   "sponsors" = sponsors, "sasts" = sasts, "subjects" = subjects,
				   "texts" = texts, "votes" = votes, "amendments" = amendments,
				   "supplements" = supplements, "calendar" = calendar)

	return(retval)
}

# Creates an empty bills object
bills <- list()

# loads all of the documents into the bills object
for (i in names(files[["bills"]])) {
	bills[[i]] <- plyr::llply(files[["bills"]][[i]], nlegiBillJSON, .parallel = TRUE)
}

# Removes top layer of the list
bills2 <- plyr::llply(bills, unlist, recursive = FALSE, .parallel = TRUE)

# Creates a series of empty list objects for containers
legislation <- list(); progress <- list(); committee <- list(); history <- list()
sponsors <- list(); sasts <- list(); subjects <- list(); texts <- list()
votes <- list(); amendments <- list(); supplements <- list(); calendar <- list()

# pulls out the individual tables of data from the bills files
for(i in names(bills2)) {
	legislation[[i]] <-	plyr::ldply(bills2[[i]][names(bills2[[i]]) == "bill"],
									dplyr::bind_rows, .parallel = TRUE)
	progress <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "progress"],
							dplyr::bind_rows, .parallel = TRUE)
	committee <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "committee"],
							 dplyr::bind_rows, .parallel = TRUE)
	history <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "history"],
						   dplyr::bind_rows, .parallel = TRUE)
	sponsors <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "sponsors"],
							dplyr::bind_rows, .parallel = TRUE)
	sasts <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "sasts"],
						 dplyr::bind_rows, .parallel = TRUE)
	subjects <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "subjects"],
							dplyr::bind_rows, .parallel = TRUE)
	texts <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "texts"],
						 dplyr::bind_rows, .parallel = TRUE)
	votes <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "votes"],
						 dplyr::bind_rows, .parallel = TRUE)
	amendments <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "amendments"],
							  dplyr::bind_rows, .parallel = TRUE)
	supplements <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "supplements"],
							   dplyr::bind_rows, .parallel = TRUE)
	calendar <- plyr::ldply(bills2[[i]][names(bills2[[i]]) == "calendar"],
							dplyr::bind_rows, .parallel = TRUE)
}

# Modifies the variable names in the data frames
legislation %<>% plyr::ldply(.id = "session_name", .parallel = TRUE, dplyr::bind_rows)
names(amendments) <- c("id", "amendment_id", "adopted", "date", "title", "description", "mime", "url", "state_link")
names(calendar) <- c("id", "type_id", "type", "date", "time", "location", "description")
names(committee) <- c("id", "committee_id", "chamber", "name")
names(history) <- c("id", "date", "action", "chamber", "chamber_id", "importance")
names(legislation) <- c("id", "bill_id", "session_id", "session_name", "change_hash", "url",
						"state_link", "completed", "status", "status_date", "state", "state_id",
						"bill_number", "bill_type", "body", "body_id", "current_body",
						"current_body_id", "title", "description")
names(progress) <- c("id", "date", "event")
names(sponsors) <- c("id", "people_id", "party_id", "party", "role_id", "role", "name", "first_name",
					 "middle_name", "last_name", "suffix", "nickname", "district", "ftm_eid",
					 "sponsor_type_id", "sponsor_order", "committee_sponsor", "committee_id")
names(supplements) <- c("id", "supplement_id", "date", "type_id", "type", "title", "description", "mime",
						"url", "state_link")
names(texts) <- c("id", "doc_id", "date", "type", "mime", "url", "state_link", "text_size")

# Loads the different types into the index
elastic::docs_bulk(amendments, index = "legislation", type = "amendments",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(calendar, index = "legislation", type = "calendar",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(committee, index = "legislation", type = "committee",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(history, index = "legislation", type = "history",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(legislation, index = "legislation", type = "bill",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(progress, index = "legislation", type = "progress",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(sponsors, index = "legislation", type = "sponsors",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(supplements, index = "legislation", type = "supplements",
				   es_ids = TRUE, raw = FALSE)
elastic::docs_bulk(texts, index = "legislation", type = "texts",
				   es_ids = TRUE, raw = FALSE)

