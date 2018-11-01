
//
//  Created by YXLONG on 2017/4/14.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "SingletonObject.h"
#import <objc/runtime.h>

static void* singletonInstance = &singletonInstance;

@implementation SingletonObject
+ (instancetype)sharedInstance
{
    Class selfClass = [self class];
    id _instance = objc_getAssociatedObject(selfClass, singletonInstance);
    if(!_instance){
        _instance = [[selfClass alloc] init];
        objc_setAssociatedObject(selfClass, singletonInstance, _instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _instance;
}
@end
