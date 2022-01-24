@echo off
iverilog ../sample_delay_buffer.v ../audio_echo_processor.v ../single_port_ram.v audio_echo_processor_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
