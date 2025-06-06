#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    int32_t identifier;
    float x;
    float y;
    float pressure;
    float size;
} MultitouchFingerData;

typedef void (^MultitouchCallback)(NSArray<NSValue *> *fingers);

@interface MultitouchBridge : NSObject

+ (instancetype)shared;
- (BOOL)startListening:(MultitouchCallback)callback;
- (void)stopListening;
- (BOOL)isListening;

@end

NS_ASSUME_NONNULL_END