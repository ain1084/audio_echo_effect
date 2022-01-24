@echo off
iverilog ../sample_delay_buffer.v sample_delay_buffer_tb.v ../single_port_ram.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
