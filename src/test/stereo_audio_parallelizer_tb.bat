@echo off
iverilog ../stereo_audio_parallelizer.v stereo_audio_parallelizer_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
