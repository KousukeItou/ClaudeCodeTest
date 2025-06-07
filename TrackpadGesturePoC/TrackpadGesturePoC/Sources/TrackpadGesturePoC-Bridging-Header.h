#ifndef TrackpadGesturePoC_Bridging_Header_h
#define TrackpadGesturePoC_Bridging_Header_h

#include <CoreFoundation/CoreFoundation.h>

typedef struct {
    float x, y;
    float size, angle;
    int identifier;
    int state;
    int foo, bar, baz;
} MultitouchFingerData;

typedef void* MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int, MultitouchFingerData*, int, double, int);

CFMutableArrayRef MTDeviceCreateList(void);
MTDeviceRef MTDeviceCreateDefault(void);
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int);
void MTDeviceStop(MTDeviceRef);
void MTDeviceRelease(MTDeviceRef);

#endif