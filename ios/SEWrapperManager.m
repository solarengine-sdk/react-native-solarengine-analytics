#import "SEWrapperManager.h"

@implementation SEWrapperManager

+ (SEWrapperManager *)sharedInstance {
    static SEWrapperManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sdk_type = @"reactnative";
    }
    return self;
}

@end
