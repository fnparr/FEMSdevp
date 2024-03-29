# RiskFactor.R  FEMSdev version Francis Parr edits Mar 2022
#*************************************************************
# Copyright (c) 2020 by ZHAW.
# Please see accompanying distribution file for license.
#*************************************************************

##############################################################
# A Reference Class that represents all Risk Factor objects
#
# This class is only used in a virtual sense in that it is
# not intended to create instances of it. It's use is to
# serve as parent to various implementations of Risk Factor
# types such as  MarketIndex, YieldCurve .
#

setRefClass("RiskFactor",
            fields = list(label = "character",
                          base  = "numeric",
                          data = "timeSeries"
            ))

setGeneric(name = "RF",
           def = function(object){
             standardGeneric("RF")
           })

setMethod(f = "RF", signature = c("character"),
          definition = function(object) {
            return(new(object))
          })

setGeneric(name = "valueAt",
           def = function(object, at, ...){
             standardGeneric("valueAt")
           })

# setGeneric(name = "as.timeSeries",
#           def = function(x){
#             standardGeneric("as.timeSeries")
#           })

as.timeSeries.RiskFactor <- function(x) {return(x$data) }

# ************************************************************
# preJSONts(), preJSONrf(), preJSONrfc() these functions map
#     risk factor elements to a preJSON form where calling
#     jsonlite::toJSON(preJSONrfc(rfc) , dataframe = "rows")
#     will genertate valid Actus JSON for riskfactors; R dataframes
#     map to JSON [ ] sequences; R lists map to JSON { } records but
#     need unbox( ) for singleton values
#     timeSeries optimizes times, no renaming time col etc
#     time() extracts vector of times; format() converts to chars
#     paste0 to append T00:00:00 expected by Actus; risk factors organized
#     as list of names with unboxed values, embedded dataframe is allowed
#     a rFConn had to be a dataframe with unnamed column of risked factors
#        FNP Apr 2022
# ************************************************************

preJSONts <- function(ts) {
  return (data.frame(time = paste0(format(time(ts)),"T00:00:00"),
                     value = ts$value)
  )
}
# result should convert to JSON with toJSON(preJSONrf(rf),dataframe="rows")

preJSONrf <- function(rf) {
  return ( list(marketObjectCode= unbox(rf$label), base = unbox(rf$base),
                data = preJSONts(rf$data)
                )
  )
}

preJSONrfs <- function(rfs) {         # work directly on riskFactors list
  rfsl <- lapply(rfs, preJSONrf )
  names(rfsl) <- NULL  # must clear the list names
  return(rfsl)
}

