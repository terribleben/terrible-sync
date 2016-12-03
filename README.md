# TerribleSync

iOS app that generates sync pulses over the audio output and supports tap tempo.

Tested working with:
- KORG units with 'sync' inputs such as SQ-1 and volca.
- Teenage Engineering Pocket Operator series.
- Moog synthesizers with "single clock advance" tempo mode.

TerribleSync also supports sending OSC messages to a specific host/port on your local
network, but only if you're building from source (for now). This can be configured in
the bundle's `info.plist`. Messages take the form `/ts/step {consecutive integer}`.
