@echo off
iverilog ../stereo_audio_serializer.v stereo_audio_serializer_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
