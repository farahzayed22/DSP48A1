vlib work
vlog DSP48A1.v FF_MUX_BLK.v DSP48A1_tb.V +cover -covercells
vsim -voptargs=+acc work.DSP48A1_tb -cover 
add wave *
run -all

