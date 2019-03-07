//
//  NSString+URLHelper.m
//  CommonKit
//
//  Created by YXLONG on 2019/2/13.
//  Copyright © 2019 yxlong. All rights reserved.
//

#import "NSString+URLHelper.h"

@implementation NSString (URLHelper)
- (NSArray<NSURLQueryItem *> *)parseURLQueryItems
{
    NSURLComponents *tmpURLComp = [NSURLComponents componentsWithString:self];
    if(!tmpURLComp){
        return nil;
    }
    return tmpURLComp.queryItems;
}

- (NSDictionary<NSString *, NSString *> *)parseURLQueries
{
    NSArray<NSURLQueryItem *> *tmpURLQueryItems = [self parseURLQueryItems];
    if(tmpURLQueryItems){
        NSMutableDictionary *result = [NSMutableDictionary new];
        for(NSURLQueryItem *item in tmpURLQueryItems){
            if(item.value){
                [result setObject:item.value forKey:item.name];
            }
        }
        return result;
    }
    return nil;
}

- (NSString *)stringByAppendingURLQueryItem:(NSURLQueryItem *)queryItem
{
    NSURLComponents *tmpURLComp = [NSURLComponents componentsWithString:self];
    NSMutableArray<NSURLQueryItem *> *tmpURLQueryItems = tmpURLComp.queryItems.mutableCopy;
    NSURLQueryItem *exsitingItem = nil;
    for(NSURLQueryItem *item in tmpURLQueryItems){
        if([item.name isEqualToString:queryItem.name]){
            exsitingItem = item;
            break;
        }
    }
    if(exsitingItem){
        [tmpURLQueryItems removeObject:exsitingItem];
    }
    [tmpURLQueryItems addObject:queryItem];
    tmpURLComp.queryItems = tmpURLQueryItems;
    return tmpURLComp.string;
}

- (NSString *)stringByAppendingURLQueryItemWithName:(NSString *)name value:(NSString *)value
{
    NSURLQueryItem *tmpQueryItem = [NSURLQueryItem queryItemWithName:name value:value];
    return [self stringByAppendingURLQueryItem:tmpQueryItem];
}

- (NSString *)URLStringAddParamterWithName:(NSString *)name value:(NSString *)value
{
    return [self stringByAppendingURLQueryItemWithName:name value:value];
}

@end
