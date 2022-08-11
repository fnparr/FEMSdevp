# ***************************************************************
# mainTest : test and development project started Feb 6th 2022
# bring in features from Portfolio.R and import.R in FEMS
# but put them in the correct files
# goal is to show how to
#  (1) create an empty portfolio by copy of segments from Portfolio.R import.R
#    (1.5) but Portfolio requires RiskFactorConnector and RFConn defined first
#  (2)  read a csv dataset into an example bond portfolio
#  (3)  validate using POST call to actus server generating cashflows
#  (4)  document noting the types required at each step
#  (5)  start providing API support for bwlfDemo Rshiny application
#    (5.1)  bond() provides user frinedly api for creating a PAM
#    (5.2)  EventSeries is dataframe for cashflow events from a single contract
#           singleContractPortfolio created on demand to generate these events
# ***************** this function  complete 13th April 2022 FNP
# RESULTS saved: http://github.com/fnparr/FEMSdev

# FEMS library must NOT be attached/loaded ( duplicate definitions )
# TimeSeries library required for Risk Factors
# issue: > library(TimeSeries) if not found

# initial test T1: clear R environment, load FEMSdev create sample Portfolio
# 1.  install required librries, clear environment, load all sourcefiles,
#     initialize  global constants  Actus Server URL, Date_Term_Names etc
rm(list= ls())
source("R/Initialize.R")
# load functions, setup the global environment , serverURL, Date_Term_Names, ..
env <- setup()   # all from Initialize.R

#  2.   Class and function definitions for FEMSdev environment
# can safely ignore WARNING RED text informing that new generic created

# 3. Build/view portfolios from Bond and Option data files
# 3.1  locate sample contract data files
optionsDataFile <- "data/OptionsPortfolio.csv"
bondDataFile <- "data/BondPortfolio.csv"
riskFactorsDataFile <-"data/RiskFactors.csv"
annuityDataFile <-"data/AnnuityPortfolio.csv"

# 3.2  read in sample data to create portfolios
ptf1 <- samplePortfolio(bondDataFile,riskFactorsDataFile)
ptf2 <- samplePortfolio(optionsDataFile,riskFactorsDataFile)
ptf3 <- samplePortfolio(annuityDataFile,riskFactorsDataFile)

# ************** Notes on Portfolio import function above *********
# validate Portfolio create and initialization using samplePortfolio()
# this function: (1) is defined in the devtest section of Portfolio.R
# (2) works with Bond and with Option sample contracts (3)creates a sample
# Portfolio with contracts from the named input csv file (3) also creates
# and sets at portfolio RFConnecter MOC time series data for Reference
# YC_EA_AAA (used by Bond contracts ) and AAPL used by Options Contracts
# ******************************  FNP 13th April 2022

# 3.3 Utilities to check our created sample portfolios
# quick checks on Options portfolio:
#   (1) the terms (2) isCompound (3) the legs (4) the riskFactors
unlist(ptf1$contracts[[1]]$contractTerms)
unlist(lapply(ptf1$contracts,function(x){return(x$isCompound)}))
unlist(ptf1$riskFactors)

unlist(ptf2$contracts[[5]]$contractTerms)
unlist(lapply(ptf2$contracts,function(x){return(x$isCompound)}))
ptf2$contracts[[1]]$contractStructure
ptf2$riskFactors

unlist(ptf3$contracts[[length(ptf3$contracts)]]$contractTerms)
unlist(lapply(ptf3$contracts,function(x){return(x$isCompound)}))
unlist(ptf3$riskFactors)
# 4. generate cashflow events and check success / view
# 4.1  actus core libraries server set in Initialize::Environment

# 4.2 Cash flow generation on bond portfolio
# Dates in terms are entered yyyy-mm-dd ; for JSON need yyyy-mm-ddT00:00:00
#  env["serverURL"] and env["Date_Term_Names"] are used from the envirponent

bond_cfl_rslts <- generateEvents(ptf1)
unlist(lapply(bond_cfl_rslts,function(x){return(x$status)}))

#4.3 Cash flow generation on options portfolio
option_cfl_rslts <- generateEvents(ptf2)
unlist(lapply(option_cfl_rslts,function(x){return(x$status)}))
unlist(option_cfl_rslts[[5]])

annuity_cfl_rslts <- generateEvents(ptf3)
unlist(lapply(annuity_cfl_rslts,function(x){return(x$status)}))

# 5. Developing FEMSdev support for ActusContract.rmd RShiny demo
# 5.1 create PAM bond with user friendly API
pam1 <- bond("2013-12-31", maturity = "5 years", nominal = 50000,
             coupon = 0.02, couponFreq = "1 years")
unlist(pam1$contractTerms)

#5.2 create null / uninitialized EventSeries
evs1 <- EventSeries(pam1, list())
unlist(list(contractID = evs1$contractID,
            contractType=evs1$contractType,
            statusDate= evs1$statusDate,
            riskFactors = evs1$riskFactors
            ))
evs1$events_df
plot(evs1)

