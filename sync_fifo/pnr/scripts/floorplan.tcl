# ----------------------------------------------------------
# Define floorplan
# ----------------------------------------------------------
set core_spacing 10

# aspect ratio + utilization
#set die_aspect_ratio 0.5
#set die_utilization 0.6
#floorPlan -r $die_aspect_ratio $die_utilization $core_spacing $core_spacing $core_spacing $core_spacing

# die size
#set die_width 400
#set die_height 600
#floorPlan -d $die_width $die_height $core_spacing $core_spacing $core_spacing $core_spacing

# ----------------------------------------------------------
# IO pin placement
# ----------------------------------------------------------
set pin_spacing 1

setPinAssignMode -pinEditInBatch true
#editPin -side N -layer 3 -fixedPin 1 -spreadType center -spacing $pin_spacing -pin {}
editPin -side W -layer 3 -fixedPin 1 -spreadType center -spacing $pin_spacing -pin {aclr clock data[*] rdreq wrreq}
editPin -side E -layer 3 -fixedPin 1 -spreadType center -spacing $pin_spacing -pin {q[*] empty almost_full full usedw[*]}
editPin -side S -layer 3 -fixedPin 1 -spreadType center -spacing $pin_spacing -pin {scan_*}
setPinAssignMode -pinEditInBatch false

#addIoFiller -cell {FILL32 FILL4 FILL16 FILL8 FILL64 FILL2 FILL1} -prefix IOFILLER

# ----------------------------------------------------------
# Add physical shapes to P/G pins
# ----------------------------------------------------------
createPGPin VSS -dir input -net VSS -geom {Metal1 60 65 61 66}
createPGPin VDD -dir input -net VDD -geom {Metal1 61 66 62 67}

# ----------------------------------------------------------
# Global P/G net connections
# ----------------------------------------------------------
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -all
globalNetConnect VSS -type pgpin -pin VSS -all

# ----------------------------------------------------------
# Power grid
# ----------------------------------------------------------
# power ring
addRing  -nets {VDD VSS} -type core_rings -center 1 -layer {top 6 bottom 6 right 5 left 5} -width 1 -spacing 1 

# power stripes
addStripe  -direction vertical   -nets {VDD VSS} -width 1 -spacing 1 -layer 5 -start_offset 25 -set_to_set_distance 25
addStripe  -direction horizontal -nets {VDD VSS} -width 1 -spacing 1 -layer 6 -start_offset 25 -set_to_set_distance 25

# power routing
sroute -connect { blockPin corePin padPin padRing floatingStripe } -layerChangeRange { Metal1 Metal11 } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { M1 M5 } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { Metal1 Metal11 }

# ----------------------------------------------------------
# Save floorplan
# ----------------------------------------------------------
saveDesign floorplan.enc
