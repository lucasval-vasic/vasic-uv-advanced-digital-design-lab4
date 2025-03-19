# ----------------------------------------------------------
# Expand path groups
# ----------------------------------------------------------
createBasicPathGroups -expanded

# ----------------------------------------------------------
# Check timing constraints and design
# Check timing in preplace mode
# ----------------------------------------------------------
check_timing -verbose

# ----------------------------------------------------------
# Placement
# ----------------------------------------------------------
place_opt_design

# check placement
checkPlace -ignoreOutOfCore

# optimization
optDesign -preCTS

# report
timeDesign -preCTS -outDir ../rep

# ----------------------------------------------------------
# Save design
# ----------------------------------------------------------
saveDesign placement.enc
