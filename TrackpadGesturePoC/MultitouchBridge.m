#import "MultitouchBridge.h"
#import <AppKit/AppKit.h>

// MultitouchSupport.framework の非公開API宣言
typedef struct {
    float x, y;
    float size, angle, majorAxis, minorAxis;
    float pressure, density;
    int state, id, unknown1, unknown2;
} Finger;

typedef struct {
    int frame;
    double timestamp;
    int identifier, state, unknown1, unknown2;
    int unknown3, unknown4;
    float unknown5;
    int unknown6[2];
    float unknown7[16];
} Touch;

typedef int MTDeviceRef;

typedef int (*MTContactCallbackFunction)(int, Finger*, int, double, int);

// 非公開API関数の宣言
MTDeviceRef MTDeviceCreateDefault(void);
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTUnregisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int);
void MTDeviceStop(MTDeviceRef);
void MTDeviceRelease(MTDeviceRef);

@interface MultitouchBridge ()
@property (nonatomic, assign) MTDeviceRef device;
@property (nonatomic, assign) BOOL listening;
@property (nonatomic, copy) MultitouchCallback callback;
@end

static MultitouchBridge *sharedInstance = nil;

// コールバック関数
static int mtCallback(int device, Finger *data, int nFingers, double timestamp, int frame) {
    if (sharedInstance && sharedInstance.callback) {
        NSMutableArray<NSValue *> *fingers = [NSMutableArray array];
        
        for (int i = 0; i < nFingers; i++) {
            MultitouchFingerData fingerData = {
                .identifier = data[i].id,
                .x = data[i].x,
                .y = data[i].y,
                .pressure = data[i].pressure,
                .size = data[i].size
            };
            
            NSValue *value = [NSValue valueWithBytes:&fingerData objCType:@encode(MultitouchFingerData)];
            [fingers addObject:value];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sharedInstance.callback([fingers copy]);
        });
    }
    
    return 1;
}

@implementation MultitouchBridge

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _device = 0;
        _listening = NO;
    }
    return self;
}

- (BOOL)startListening:(MultitouchCallback)callback {
    if (self.listening) {
        return NO;
    }
    
    // デバイスの作成を試行
    self.device = MTDeviceCreateDefault();
    if (!self.device) {
        NSLog(@"MultitouchSupport.framework が利用できません（シミュレーション）");
        
        // シミュレーション用のテストデータを送信
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendSimulatedGesture];
        });
        
        self.listening = YES;
        self.callback = callback;
        return YES;
    }
    
    self.callback = callback;
    
    // コールバックの登録
    MTRegisterContactFrameCallback(self.device, mtCallback);
    
    // デバイスの開始
    MTDeviceStart(self.device, 0);
    
    self.listening = YES;
    NSLog(@"Multitouch listening started");
    
    return YES;
}

- (void)stopListening {
    if (!self.listening) {
        return;
    }
    
    if (self.device) {
        MTUnregisterContactFrameCallback(self.device, mtCallback);
        MTDeviceStop(self.device);
        MTDeviceRelease(self.device);
        self.device = 0;
    }
    
    self.listening = NO;
    self.callback = nil;
    NSLog(@"Multitouch listening stopped");
}

- (BOOL)isListening {
    return self.listening;
}

// シミュレーション用のテストジェスチャ送信
- (void)sendSimulatedGesture {
    if (!self.callback) return;
    
    // 3本指左スワイプのシミュレーション
    NSMutableArray<NSValue *> *fingers = [NSMutableArray array];
    
    for (int i = 0; i < 3; i++) {
        MultitouchFingerData fingerData = {
            .identifier = i,
            .x = 0.5f - (0.1f * i),
            .y = 0.5f,
            .pressure = 0.5f,
            .size = 0.1f
        };
        
        NSValue *value = [NSValue valueWithBytes:&fingerData objCType:@encode(MultitouchFingerData)];
        [fingers addObject:value];
    }
    
    self.callback([fingers copy]);
    
    // ジェスチャ終了のシミュレーション
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.callback(@[]);
    });
}

- (void)dealloc {
    [self stopListening];
}

@end