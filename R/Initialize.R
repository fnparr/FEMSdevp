# *****************************************
# Initialize.R   utilities to set up  maintest environment
# libraries
library(timeSeries)
library(jsonlite)
library(httr)

# mainTest setup() defined here
setup<- function(){
  # rm(list= ls()) was cleared outside will blow away loadDefs() here
  loadDefs()
  # initialize globalenvironment
  print (paste0("*** Setting Actus Server URL to ","http://ractus.ch:8080/"))
  print ("*** Initializing  Date_Term_Names and Event_Field_Names")
  outenv <- Environment()
  return(outenv)
}
# ************** the Environment object with global constants
# initialized by setup()
setRefClass("Environment",
            fields = list(
              serverURL = "character",
              Date_Term_Names = "character",  # a vector of names
              Event_Field_Names = "character"
            )
)
# *********************
#  constructors:  Environment() : (), (serverURL, Date_Term_Names )

setGeneric(name = "Environment",
           def = function(...){
             standardGeneric("Environment")
           })

setMethod(f = "Environment", signature = c(),
          definition = function(){
              outenv <- new("Environment")
              outenv$serverURL <- "https://demo.actusfrf.org:8080/"
              #  could also be
                # outenv$serverURL <- "http://ractus.ch:8080/"
              Date_Term_Names <- c(
                  "statusDate","contractDealDate","initialExchangeDate",
                  "maturityDate","cycleAnchorDateOfInterestCalculationBase",
                  "amortizationDate","contractDealDate","cycleAnchorDateOfPrincipalRedemption",
                  "arrayCycleAnchorDateOfPrincipalRedemption","purchaseDate",
                  "terminationDate","cycleAnchorDateOfScalingIndex",
                  "cycleAnchorDateOfRateReset","cycleAnchorDateOfInterestPayment",
                  "capitalizationEndDate")
              outenv$Date_Term_Names <- Date_Term_Names
              Event_Field_Names <- c("type","time","payoff","currency","nominalValue","nominalRate","nominalAccrued")
              # each is actually prefixed by events.  complete field name = events.<fieldname>
              outenv$Event_Field_Names <- Event_Field_Names
              return(outenv)
            })

loadDefs <- function() {
  source("R/ContractABC.R")         # defs: ContractABC may not need
  source("R/RiskFactorConnector.R") # used ContractType, RFConn()
  source("R/ContractModel.R")    # defs:  ContractModel, set() get() generic
  source("R/ContractType.R") # defs: ContractType<-ContractABC, CT()
  source("R/PrincipalAtMaturity.R") # defs: PAM class and Pam()
  source("R/util.R")         # defs: longName()
  source("R/Portfolio.R")    # defs Portfolio refClass Portfolio()
  # samplePortfolio_1() initializes a portfolio pre cashflow gen
  source("R/import.R")       # tested working segments of import.R
  source("R/RiskFactor.R")   #  defs RiskFactor RF() used MarketIndex
  source("R/ReferenceIndex.R") # Index riskFactor used variable rate cashflows
  source("R/ContractLeg.R")    # attributes of a leg of a Structured Contract
  source("R/Option.R")       # structure UDL MOC option contracts
  source("R/bond.R")         # user friendly api to create a Pam()
  source ("R/EventSeries.R") # dataframe with cashflow events from a contract
  source ("R/ContractPlot.R") # the plot(<EventSeries>) and contractPlot(functions)
  source ("R/Annuity.R")      # defines ANN class and Annuity ann() constructors
}
