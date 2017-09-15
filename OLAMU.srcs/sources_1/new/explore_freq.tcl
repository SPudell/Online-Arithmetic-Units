# Retrieve Project Parameters
set TOP  dp_oladd_top
#set PART XC7Z045FFG900-2
set PART XC7K325TFFG900-2

# Exploration Parameters
set tm 1.0 ;    # Miminum possible Time
set tt 10.0 ;   # Time to Test
set ts 100.0 ;  # Succesful Time
# Assertion: tm <= tt <= ts

# read vhdl files
read_vhdl {
    functions.vhdl
    dp_oladd_top.vhdl    
    ds_oladd_r2.vhdl
    ds_oladd_rg2.vhdl
    cu.vhdl
    conv_res.vhdl
    tw_unit.vhdl
    signed_adder.vhdl
    full_adder.vhdl
    shift_reg.vhdl
    reg.vhdl
}

# -----------------------------------------------------------------------------
# Run Synthesis
synth_design -top $TOP -part $PART

# -----------------------------------------------------------------------------
# while loop, updating Clock
while {[expr $ts - $tm] > 0.1} {

  create_clock -name CLK -period $tt [get_port clk]

  # -----------------------------------------------------------------------------
  # Place & Route

  opt_design -retarget -propconst -sweep
  place_design -directive Explore
  report_utilization
  route_design -directive Explore
  report_drc
  report_utilization -hierarchical
  report_timing -setup -hold -max_paths 3 -nworst 3 -input_pins -sort_by group -file  $TOP.twr
  report_timing_summary -delay_type min_max -path_type full_clock_expanded -report_unconstrained -check_timing_verbose -max_paths 3 -nworst 3 -significant_digits 3 -input_pins -file $TOP.twr

  # -----------------------------------------------------------------------------
  # find maximum Data Path Delay and Slack
  set f [open $TOP.twr r]
  set file_data [read $f]
  close $f
  if {[regexp { +Data Path Delay: +(\d+\.\d+)} $file_data -> value]} {
    set tr $value
  } {
    error NOT FOUND
  }

  # -----------------------------------------------------------------------------
  # check if Timing was met
  if { $tt < $tr } {
    puts  {Timing was NOT met!}
    set tm $tt
    if { $tr < $ts } {
      set ts $tr
    }
  } else {
    set ts $tr
  }

  # -----------------------------------------------------------------------------
  # set new clock timing
  set tt [expr { ($ts + $tm)/2}]
}

set outfile [open RESULT w]
puts $outfile "$ts"
close $outfile

