# Lab 4 - Place and Route (PnR)

## Introduction
On this lab we will get acquainted with the place and route tool from Cadence: Innovus.

The lab includes files for the sync_fifo design, for the Cadence generic 45nm process. You will need to add the tcons files and the synthesis outputs files from Lab 3 (essentially the gates netlist).

For simplicity, we will not be implementing a full chip (including IO pads, corner cells) but a simple block. This will allow us to focus on the internals of the PNR process.

## Innovus start
As usual, we will source the cdsenv.sh script to set up the paths for Cadence flow:

```console
> source /eda/cdsenv.sh
```

Now we can ensure that Innovus works by invoking it:

```console
> innovus
```

On this lab unlike the previous ones it is recommended to leave the tool GUI open, so you can see how the design is modified with each of the steps on the PnR flow.

## Place and Route flow scripts

Start by opening up pnr.tcl. Examine it and notice how different sub-scripts are called for each of the PnR steps like floorplanning, placement or routing. During the lab we will experiment with different options so it is suggested to make use of the snapshots stored at the end of each stage to retrieve the original design state. These snapshots are stored in the pnr/run directory and they can be read sourcing the .enc script named after the respective stage we want to load. For instance, in order to load the floorplan snapshot we will do:

```console
> source floorplan.enc
```

The recommended way to run the lab is to do an initial run executing each of the PNR stages manually (by executing each of the lines in pnr/scripts/pnr.tcl) and observing the effect of each command and stage on the chip view of the GUI.

## Init design
Here the synthesis netlist is loaded together with all the referenced standard cell and technology libraries.

## Floorplanning

### Boundary definition
Once design and constraints are loaded in memory we can being creating the physical definition of our design. The first step will be to define the design boundary with the floorPlan command.

Open up scripts/floorplan.tcl and check out the first commands. We have two main options when defining the boundary: we can either specify the boundary width and height or set both an aspect ratio, and a utilization value. Experiment with both commands and decide on one.

Notice that the floorPlan command will automatically create the site rows, filling up the die area completely.

### Pin definition
Plan the IO pin placement by splitting the design pins across the 4 sides, deciding on a splitting strategy following the guideline of keeping all pins for a bus on the same side. Group the design pins accordingly to your mapping and edit the editPin commands for each of the 4 die borders (North, East, South or West) to reflect your mapping. Ensure that all pins for each border may be adequately spread across that border.

### Power grid
Now we will create new pins in the design for the power supply and grounds, and later a power ring and some sets of strips to distribute the supply current across the design.

You will need to identify the locations for the supply and ground pins and then get the coordinates for the lower left and upper right vertices of the pin. As a suggestion use the ruler to measure the distance between the lower left corner of the die which server as coordinates origin (press key k in the GUI window to start the ruler and left click to start a new ruler segment).

Once the power pins have been created they will be connected to the supply and ground nets, and the power mesh structure will be built. Feel free to experiment with the stripe spacing or ring width and observe their effect on the die appearance.

## Placement
Once the design boundary has been defined we can invoke the place_opt_design to place the standard cells. After this we will verify the placement with checkPlace to ensure that all standard cells could be placed in the site rows.

Examine the design and notice how related cells have been placed close to each other. Notice the blank space left along the site rows. Some of this blank space will be later filled up by clock tree buffers.

### Optimization
After every major PNR process like placement, CTS or routing it is advised to run an optimization cycle. This is done with the optDesign command which depending on the flow stage where we invoke it will try to optimized both setup and hold timing (after CTS and routing), or only setup timing (after placement). Also the command will fix design rule violations and optimize performance parameters such as skew, area or power.

### Timing report
Like we did on the synthesis we will produce multiple timing reports along the different PNR stages. These reports will allow us to gauge the health of the design implementation, and assist with debugging in case timing issues are seen during any of the stages.

On Innovus the timing reports are created with timeDesign. This command will infer the appropriate settings for timing analysis, including parasitic extraction when invoked after design has been routed. The reports produced by timeDesign are compressed with gzip but any modern text editor should be able to decompress the file automatically.

Record the timing figures such as TNS, WNS in each of the flow stages where timeDesign is executed so you can later compare how the design timing is modified with each new step.

## Clock Tree Synthesis
On this stage we will create a clock tree to distribute the clock signals to all sequential cells in the design. This used to be a very complicated process with old PNR tools as a very detailed clock tree specification had to be manually crafted. While this is somehow attainable on a small design like sync_fifo the task could easily become too large in complex designs with multiple clock domains where some of the domains transfer data between them.

### Clock tree specification
As mentioned in the theory section modern PNR tools are able to infer most of the clock tree specification automatically. In Innovus command create_ccopt_clock_tree_spec will automatically create a detailed clock tree specification from the timing constraints and the design structure.

Review the file run/ccopt.spec where the clock tree specification is created.

### Clock tree parameters
We can adjust some of the clock tree parameters like the lists of buffers and inverters allowed to be used in clock tree construction. You can also modify the target skew to an specific value.

### Clock tree insertion
Examine how ccopt_design creates the clock tree, and analyze the multiple reports (placed in rep/$BLOCK_NAME_cts_*.rpt) created afterwise. We will report in detail both the tree structure and the skew with the ccopt report commands. If you set a target skew confirm whether this constraint could be honoured.

### Optimization
After the clock tree has been built a new round of optimization and timing report is executed. Since the clock tree is in place the timing analysis will be more accurate, especially in the reg2reg paths.

## Routing
Now we will make use of the routeDesign command to route the non clock nets in the design. As you can see the output of this command is very verbose and provides lots of information on the tracks traced by Innovus, like their length, via count.


### Optimization
Like after placement and CTS we will trigger an optimization cycle. This is especially important after routing lots of wires since high congestion areas may experience timing or power issues. However optimization is not a silver bullet and can only fix moderate issues. If the design really suffers from congestion only a floorplan modification like area increase or moving macros may fix a complicated design.

### Routing report
A report after routing stage is produced on rep/$BLOCK_NAME.wirerpt. On it we can see multiple figures per routed net like ratio, wire length, Manhattan distance covered by the wire, vias and connectivity counts. The ratio relates to the relation between total net routing length and the perimter of the rectangle around all the components connected by the net. This measures the routing efficiency as an elevated ratio indicates that routing had to perform multiple detours to reach all the required points.

### Timing report
Now that the design is routed an estimate of parasitic extraction will be produced. This is a quicker extraction than the one done after design is completed to sign off timing, but it is accurate enough to evalute the status of timing after routing.

Experiment rerunning the PNR flow forcing a die size or utilization that causes congestion and check whether the tool is able to work around this congestion or ends up breaking the design timing.

## Die finishing

Once the functional design has been fully implemented physically after completing the net routing we must complete the PNR process by adding physical only cell such as decoupling and filler cells. The most optimized way to do it is to first insert decoupling cells that due to the metal components also serve as filler cells.

Once the decoupling cells have been inserted filler cells will be added to the design in case some free space has been left out by the decoupling cells.

## Writing output files

As you can expect we will be producing many different output files after the complex PNR process. First of all we will produce different gates netlists for use with different flow stages such as STA, BEQ or IR drop analysis.

Then we will also write the design layout in 2 different formats: a DEF text format and the binary GDS format. This will allow us to open the design from multiple tools.

# Final checks

Now we will run different checks on our implemented design to ensure it is ready for manufacturing. More specifically we will perform DRC checks to ensure that the design complies with silicon foundry rules, then we will run extract parasitics for a posterior Static Timing Analysis.

## DRC checks
This section will perform design rule checks (DRC) on our design following the rules set by the manufacturing process provider (Cadence for the 45nm process). 

### Connectivity checks
Here we will check whether all the nets and pins have proper connectivity. More specifically we will check whether some nets are floating, pins are shorted or open, or some nets were not routed. We can run these checks with the Innovus command:
```console
> verifyConnectivity
```

Since we have a completely routed and finalized design it is not expected that we see any of these violations.

### Geometry checks

Here multiple geometrical aspects of the design layout like shape width or spacing will be checked. The following Innovus command will perform this verification:

```console
> verify_drc
```

It is probable that you see multiple violations. At the moment of running the lab these have not beed fully explained but at least some seem to be caused by the cap and filler cells inserted in die finish stage. You can confirm this fact by loading the post-routing snapshot (source routing.enc) and rerunning the verify_drc command.

### Antenna checks
On this section we will check whether some metal tracks are long enough to be vulnerable to the antenna effect. Antenna rules in the runset file set constraints on the maximum track length per each of the metal layers. This command will check whether some of these rules are violated in our design:
```console
> verifyProcessAntenna
```

It is probable that you see some of these violations on your design (if you don't see any make sure you re-loaded the final PnR snapshot with source final.enc command). If this is the case you can use the GUI to observe the trace using the violation browser window. Click on an antenna violation and the GUI will automatically zoom to the affected track.

We can trigger a round of routing to try to remove these antenna violations. The Innovus router will initially attempt to perform layer hopping to remove the violations and if this is not possible attempt to insert antenna diodes on the affected metal track.

Use the following commands to run the router enabling options to solve the antenna issues:

```console
> setNanoRouteMode -drouteFixAntenna true
> setNanoRouteMode -routeInsertAntennaDiode true
> setNanoRouteMode -routeAntennaCellName ""
> globalDetailRoute
```

These commands instruct the router to try to fix the antenna violations with both metal hopping and antenna diodes insertion if required. Now run antenna checks again and confirm whether the violations are gone.

### Parasitic extraction

In order to perform an accurate analysis we need to run an initial parasitic extraction on our design. Innovus has the capability to perform signoff level parasitic extraction with these commands in order to produce an SPEF parasitic annotation file per timing corner:

```console
# configure RC extraction to use postRoute engine and apply maximum effort level for timing signoff
setExtractRCMode -engine postRoute

# set signoff effort level for maximum parasitic extraction accuracy
# this is disable for now since PDK seems to be incorrect as some layers are not properly mapped
#setExtractRCMode -effortLevel signoff

# run RC extraction
extractRC

# write out SPEF files
foreach corner [all_rc_corners] {
    puts "writing SPEF for corner $corner"
    rcOut -rc_corner $corner -spef ../out/${BLOCK_NAME}_${corner}.spef
}
```

You can execute these commands in the extract/scripts/extract.tcl script. After they execute check out the pnr/out directory to find the 2 SPEF files produced by Innovus, one per each manufacturing process corner. When running STA you will read these files to characterize the parasitic components present in your design.
