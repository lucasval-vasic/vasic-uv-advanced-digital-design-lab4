create_library_set -name max_timing -timing { /eda/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib /eda/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_multibitsDFF.lib /eda/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_extvdd1v0.lib /eda/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_extvdd1v2.lib }
create_library_set -name min_timing -timing { /eda/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v0_basicCells.lib /eda/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v0_multibitsDFF.lib /eda/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v0_extvdd1v0.lib /eda/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v0_extvdd1v2.lib }

create_rc_corner -name rcbest \
   -cap_table /eda/gpdk045_v_6_0/soce/gpdk045.extended.CapTbl \
   -qx_tech_file /eda/gpdk045_v_6_0/qrc/rcbest/qrcTechFile \
   -qrc_tech /eda/gsclib045_all_v4.4/gsclib045/qrc/qx/gpdk045.tch

create_rc_corner -name rcworst \
   -cap_table /eda/gpdk045_v_6_0/soce/gpdk045.extended.CapTbl \
   -qx_tech_file /eda/gpdk045_v_6_0/qrc/rcworst/qrcTechFile \
   -qrc_tech /eda/gsclib045_all_v4.4/gsclib045/qrc/qx/gpdk045.tch

create_delay_corner -name max_delay -library_set max_timing -rc_corner rcworst
create_delay_corner -name min_delay -library_set min_timing -rc_corner rcbest

create_constraint_mode -name sdc_tcons -sdc_files [list ../../tcons/$BLOCK_NAME.sdc]

create_analysis_view -name wc -constraint_mode sdc_tcons -delay_corner max_delay
create_analysis_view -name bc -constraint_mode sdc_tcons -delay_corner min_delay

set_analysis_view -setup wc -hold bc