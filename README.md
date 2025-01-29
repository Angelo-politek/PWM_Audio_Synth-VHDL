# 🎵 PWM Audio Synthesizer 🎵

This project is a PWM audio synthesizer described in VHDL. 
It is still in its early stages, with the goal of creating a complete monophonic AM synth capable of generating both melodic and percussive sounds. 
Currently, it has been tested on the Altera DE10-Lite board, but in the future, I will look for a more cost-effective FPGA that can support the project without compromising performance.

## 🏗️ Architecture

The synthesizer consists of the following main components:

### 🎹 WAVE_GEN
- Generates basic waveforms: square, sawtooth, and triangle
- 32-bit phase accumulator for frequency control
- 10-bit output resolution

### 🎛️ ENVELOPE_GEN
- ADSR-style envelope generator
- Configurable attack and decay times (8-bit resolution)
- Retrigger capability during any phase

### 🔊 AMP
- Volume control with 8-bit resolution
- Handles 10-bit audio signals
- Range from -64dB to 0dB

### ⚙️ PWM_GEN
- 10-bit PWM resolution
- Output frequency > 48.8 kHz
- Direct digital synthesis approach

### 🖥️ USER_INTERFACE
- Menu-driven parameter control
- LED display feedback
- Real-time parameter adjustment
- Supports multiple control parameters:
   - Waveform selection
   - Frequency
   - Attack time
   - Decay time
   - Volume

### 🔢 DECODER
- 7-segment display driver
- Converts 8-bit values to decimal display (0-255)
- Supports 3 digits with BCD conversion

## 🚀 Current Status

The synthesizer is currently functional with:
- 3 basic waveforms
- Working envelope generation
- Volume control
- PWM audio output
- Basic user interface with parameter control
- LED display feedback

## 🌟 Future Improvements

1. **Sound Features:**
    - Fix the frequency range
    - Add more waveforms (sine, noise)
    - Add filters (low-pass, high-pass)
    - Include modulation effects (LFO)

2. **Interface Enhancements:**
    - Add MIDI input support
    - Implement preset storage/recall
    - Add visual feedback for envelope shape

3. **Technical Improvements:**
    - Add anti-aliasing for waveforms
    - Implement higher resolution frequency control
    - Add stereo output capability

## 📖 Usage

1. Reset system using SW(9)
2. Navigate menu using KEY(1)
3. Adjust parameters using SW(7:0)
4. Set the parameter with SW(8)
5. Trigger notes using KEY(0)

## 📜 LICENSE

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
