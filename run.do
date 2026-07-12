vlib work
vlog DSP48A1.v FF_MUX_BLK.v +cover -covercells
vsim -voptargs=+acc work.tb_mini_soc_no_cdc -cover 
add wave *
run -all

