#ifndef MultitouchBridge_h
#define MultitouchBridge_h

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

MTDeviceRef MTDeviceCreateDefault(void);
CFMutableArrayRef MTDeviceCreateList(void);
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int);
void MTDeviceStop(MTDeviceRef);
void MTDeviceRelease(MTDeviceRef);

#endif