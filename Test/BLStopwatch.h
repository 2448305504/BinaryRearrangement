

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BLStopwatchSplitType) {
    BLStopwatchSplitTypeMedian = 0, // 记录中间值.
    BLStopwatchSplitTypeContinuous // 记录连续值.
};

NS_ASSUME_NONNULL_BEGIN

@interface BLStopwatch : NSObject

+ (instancetype)sharedStopwatch;

@property (nonatomic, readonly) NSArray<NSDictionary<NSString *, NSNumber *> *> *splits;
@property (nonatomic, readonly) NSString *prettyPrintedSplits;
@property (nonatomic, readonly) NSTimeInterval elapseTimeInterval;

- (void)start;

/**
 * 打点(默认记录中间值).
 *
 * @param description 描述信息.
 */
- (void)splitWithDescription:(NSString * _Nullable)description;

/**
 * 打点.
 * 
 * @param type 记录的类型.
 * @param description 描述信息.
 */
- (void)splitWithType:(BLStopwatchSplitType)type description:(NSString * _Nullable)description;

/**
 * 刷新中间值.
 */
- (void)refreshMedianTime;

- (void)stop;
- (void)reset;

- (void)stopAndPresentResultsThenReset;

@end

NS_ASSUME_NONNULL_END
