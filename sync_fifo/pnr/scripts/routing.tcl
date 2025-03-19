####################################################################################################
## Routing
####################################################################################################

# Enable antenna diode insertion
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeAntennaCellName ANTENNA

routeDesign

####################################################################################################
## Optimization
####################################################################################################

setExtractRCMode -engine postRoute
setExtractRCMode -effortLevel medium

# optimize
optDesign -postRoute -setup -hold

# report
timeDesign -postRoute -outDir ../rep
timeDesign -postRoute -hold  -outDir ../rep

# wire report
reportWire ../rep/$BLOCK_NAME.wirerpt

####################################################################################################
## Save design
####################################################################################################
saveDesign routing.enc
