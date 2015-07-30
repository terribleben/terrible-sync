//
//  TSAudioDef.h
//

#ifndef __TS_AUDIO_DEF_H__
#define __TS_AUDIO_DEF_H__

#include <cstdlib>
#include <complex>

typedef float Sample; // 32 bit

typedef void (*AudioCallback)(Sample* buffer, unsigned int numFrames, void* userData);

#define TS_AUDIO_SAMPLE_RATE 44100.0
#define TS_AUDIO_BUFFER_SIZE 512
#define TS_AUDIO_MAX_BUFFER_SIZE 1024
#define TS_AUDIO_NUM_CHANNELS 2

typedef struct AudioSharedBuffer {
    Sample* buffer;
    size_t length;
} AudioSharedBuffer;

typedef std::complex<Sample> AudioComplex;

#endif
