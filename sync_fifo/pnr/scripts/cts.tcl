# ----------------------------------------------------------
# Clock tree specification
# ----------------------------------------------------------

delete_ccopt_clock_tree_spec
create_ccopt_clock_tree_spec -file ccopt.spec

source ccopt.spec

# ----------------------------------------------------------
# Clock tree parameters
# ----------------------------------------------------------

set_db cts_update_clock_latency false
set_db cts_inverter_cells {CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX6 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20}
set_db cts_buffer_cells {CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20}




#set_ccopt_property target_skew 0.1


# ----------------------------------------------------------
# Clock tree synthesis
# ----------------------------------------------------------

ccopt_design

# ----------------------------------------------------------
# Clock tree report
# ----------------------------------------------------------
report_ccopt_clock_tree_structure -file ../rep/${BLOCK_NAME}_cts_tree_structure.rpt
report_ccopt_clock_trees -file ../rep/${BLOCK_NAME}_cts_trees.rpt
report_ccopt_skew_groups -file ../rep/${BLOCK_NAME}_cts_skew_groups.rpt

####################################################################################################
## Optimization
####################################################################################################

# optimize
optDesign -postCTS

# report
timeDesign -postCTS -outDir ../rep

# ----------------------------------------------------------
# Save design
# ----------------------------------------------------------
saveDesign cts.enc
