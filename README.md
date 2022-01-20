# audio_echo_effect
(Japanese only)

- 入力したディジタルオーディオ信号に簡単なエフェクト(エコー)を加えて、S/PDIF で出力する実装です。
- 演算サンプルビット数と遅延時間はディレイバッファは [audio_echo_effect](https://github.com/ain1084/audio_echo_effect/blob/main/src/audio_echo_effect.v) モジュールのパラメータで指定できます。
  - ただ単に、パラメータで可変できる実装という意味です。
- 入力信号は一般的な I2S です。必要な信号は MCLK (x256Fs), LRCLK, SCLK, SDO です。
- 入力サンプリング周波数は 48KHz を想定しています。
- S/PDIF 出力は入力と同じサンプリング周波数です。 
- [src/](https://github.com/ain1084/audio_echo_effect/blob/main/src/) ディレクトリが verilog ソースコードです。
- Lattice ECP2 の Lattice diamond 用 Project を含んでいます。
  - ターゲットボードは自作のものですので、そのままでは使用できません。参考用です。 
- Lattice ECP2 および MachXO2 で動作を確認しています。
  - ただし、top モジュールを除いて固有プリミティブは使用していないため、他の FPGA で動作させる事は容易です。 
  - top モジュールは FPGA の種類等により異なるため、src/ ディレクトリには含まれていません。
  - (例えば) Lattice ECP2 用の top モジュールは [projects/LatticeDiamond/ECP2-12E-TEST-BOARD/src/](https://github.com/ain1084/audio_echo_effect/tree/main/projects/LatticeDiamond/ECP2-12E-TEST-BOARD/src) にあります。 
- top モジュールでは以下を実装する必要があります。具体的な実装例は Lattice ECP2 用の top モジュールを参照して下さい。
  - リセット(GSR 等)
  - エコー用ディレイバッファの深さ(48KHz の場合、4800 で 100msec 分)。
  - 演算サンプルビット数(16,24 等)。
  - 入力(Decoder)、audio_echo_effect、出力(Encoder)モジュールとの接続。
- ディレイバッファの深さはブロックRAMの大きさによって制限されます。演算サンプルビット数を 16、ディレイバッファの深さを 2048 とした場合 64Kbits を使用します。
