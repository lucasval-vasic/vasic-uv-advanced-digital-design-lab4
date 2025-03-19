####################################################################################################
## design setup
####################################################################################################

set BLOCK_NAME "sync_fifo"

set lib_name $BLOCK_NAME
set cell_name $BLOCK_NAME

set ref_libs { gsclib045_tech gsclib045 gpdk045 }
set init_verilog "../in/$BLOCK_NAME.vg"
set init_lef_file { \
  /eda/gsclib045_all_v4.4/gsclib045/lef/gsclib045_tech.lef \
  /eda/gsclib045_all_v4.4/gsclib045/lef/gsclib045_macro.lef \
}
set init_mmmc_file "../scripts/setup_mmmc.tcl"

set init_gnd_net {VSS}
set init_pwr_net {VDD}

#set lef_tech_file_map "/cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_Power_RefKit-cadence/v1_3_1/src/xx018_lef_qrc.map"
set lef_tech_file_map "/eda/ayudas/gpdkInnovus.map"
set stream_out_map "/eda/ayudas/gpdkInnovus.map"

#set power_nets { VDD }
#set ground_nets { GND }

####################################################################################################
## pnr setup
####################################################################################################

setDesignMode -process 45
setMultiCpuUsage -localCpu 2

setAnalysisMode -analysisType onChipVariation -cppr both

#setDontUse *XL true
#setDontUse *X1 true

#setPlaceMode -place_global_place_io_pins true
#setPlaceMode -place_global_ignore_scan false

setPlaceMode -reset
setPlaceMode -place_global_ignore_scan true
setPlaceMode -place_global_reorder_scan false
setPlaceMode -place_global_exp_allow_missing_scan_chain true
