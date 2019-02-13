//
//  NSString+URLHelper.h
//  CommonKit
//
//  Created by YXLONG on 2019/2/13.
//  Copyright © 2019 yxlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLHelper)
- (NSArray<NSURLQueryItem *> *)parseURLQueryItems;
- (NSDictionary<NSString *, NSString *> *)parseURLQueries;
- (NSString *)stringByAppendingURLQueryItem:(NSURLQueryItem *)queryItem;
- (NSString *)stringByAppendingURLQueryItemWithName:(NSString *)name value:(NSString *)value;
- (NSString *)URLStringAddParamterWithName:(NSString *)name value:(NSString *)value;
@end
