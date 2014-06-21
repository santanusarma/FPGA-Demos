
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name LCD -dir "/home/hessam/LCD/LCD/planAhead_run_5" -part xc5vlx110tff1136-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/hessam/LCD/LCD/lcd2x16.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/hessam/LCD/LCD} }
set_param project.pinAheadLayout  yes
set_param project.paUcfFile  "lcd2x16.ucf"
add_files "lcd2x16.ucf" -fileset [get_property constrset [current_run]]
open_netlist_design
