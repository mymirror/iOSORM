//
//  test.m
//  realmOrm
//
//  Created by ponted on 2019/6/5.
//Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import "test.h"

@implementation test

// Specify default values for properties
//
+ (NSString *)primaryKey {
    return @"name";
}

//+ (NSArray *)indexedProperties {
//
//    return @[@"name"];
//
//}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"idString":@""};
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[@"name"];
//}

@end
