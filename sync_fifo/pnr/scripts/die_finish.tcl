# ----------------------------------------------------------
# Add filler
# ----------------------------------------------------------

addFiller -prefix FILLCAP -cell DECAP2 DECAP3 DECAP4 DECAP5 DECAP6 DECAP7 DECAP8 DECAP9 DECAP10
addFiller -prefix FILL -cell FILL32 FILL4 FILL16 FILL8 FILL64 FILL2 FILL1

# fix DRCs
ecoRoute -target

####################################################################################################
## Write design
####################################################################################################
saveDesign die_finish.enc
