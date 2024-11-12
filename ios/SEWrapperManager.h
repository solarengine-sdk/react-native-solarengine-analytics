//
//  SEWrapperManager.h
//  SolarEngineSDKSample
//
//  Created by zhanghulk on 2024/10/08.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SEWrapperManager : NSObject

@property (nonatomic,copy)NSString *sub_lib_version;
@property (nonatomic,copy)NSString *sdk_type;

+ (SEWrapperManager *)sharedInstance;

@end
NS_ASSUME_NONNULL_END