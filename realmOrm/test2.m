//
//  test2.m
//  realmOrm
//
//  Created by ponted on 2019/6/10.
//Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import "test2.h"

@implementation test2

+ (NSString *)primaryKey {
    return @"testName";
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
