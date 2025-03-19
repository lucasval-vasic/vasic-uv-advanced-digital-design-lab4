####################################################################################################
## Export data
####################################################################################################

# netlists
saveNetlist ../out/$BLOCK_NAME.vg -excludeLeafCell 

saveNetlist ../out/${BLOCK_NAME}_phys.vg -excludeLeafCell \
    -includePhysicalCell { ANTENNA DECAP2 DECAP3 DECAP4 DECAP5 DECAP6 DECAP7 DECAP8 DECAP9 DECAP10 }

saveNetlist ../out/${BLOCK_NAME}_phys_pg.vg -excludeLeafCell -includePowerGround\
    -excludeCellInst { FILL32 FILL4 FILL16 FILL8 FILL64 FILL2 FILL1 }  \
    -includePhysicalCell { ANTENNA DECAP2 DECAP3 DECAP4 DECAP5 DECAP6 DECAP7 DECAP8 DECAP9 DECAP10 }

# DEF
saveModel -dir ../out/final_model

# GDS layout
streamOut ../out/${BLOCK_NAME}.gds.gz -mapFile $stream_out_map -dieAreaAsBoundary -outputMacros \
    -merge { /eda/gsclib045_all_v4.4/gsclib045/gds/gsclib045.gds }

####################################################################################################
## Write design
####################################################################################################
saveDesign final.enc
