//
//  ViewController.m
//  realmOrm
//
//  Created by ponted on 2019/6/5.
//  Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "test.h"
#import "iOSRealm/LMRealm.h"
#import "test2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *dbPath = [docPath stringByAppendingPathComponent:@"db.realm"];
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    test *ss = [[test alloc]init];
//    ss.name = @"123234";
//    ss.age = @"23";
////    ss.idString = @"1444";
////    [realm beginWriteTransaction];
////       [realm addObject:ss];
//    ss = [test createOrUpdateInRealm:realm withValue:@{@"name":@"12323"}];
//      [realm deleteObject:ss];
//          ss = [test createOrUpdateInRealm:realm withValue:@{@"name":@"123"}];
//    [realm addOrUpdateObject:ss];
    
    [[LMRealm shareRealm] setDefaultRealmForUser:@"haha1"];
    for (NSInteger i = 0; i<10; i++) {
        test *aa = [[test alloc]init];
        aa.name = [NSString stringWithFormat:@"name%ld",i];
        aa.age = [NSString stringWithFormat:@"%ld",i];
        aa.idString = [NSString stringWithFormat:@"id%ld",(20-i)];
        [[LMRealm shareRealm] realmAdd_UpdateObject:aa];
    }
    
//    [realm commitWriteTransaction];
    
//    [realm transactionWithBlock:^{
//        [test createOrUpdateInRealm:realm withValue:@{@"name":@"12323"}];
//    }];
    
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",@"3"];
//    RLMResults *arr = [test objectsWithPredicate:pre];
//      RLMResults *arr = [[LMRealm shareRealm] queryFuzzyObjectName:@"test" fuzzyType:3 att:@{@"name":@"3"}];
//    NSLog(@"%@",arr);
      RLMResults *ss = [[LMRealm shareRealm] queryAllObject:@"test"]; 
         NSLog(@"ss := %@",ss);

    
//    NSPredicate *pre1 = [NSPredicate predicateWithFormat:@"age = %@",@"1"];
//    RLMResults *arr2 = [test objectsWithPredicate:pre1];
//    NSLog(@"%@",arr2);
    test2 *sds = [[test2 alloc]init];
    sds.testName = @"namere";
    sds.age = @"1";
    [[LMRealm shareRealm] realmAdd_UpdateObject:sds];
    RLMResults *ss1 = [[LMRealm shareRealm] queryAllObject:@"test2"]; 
    NSLog(@"ss1 := %@",ss1);
//    RLMResults *arr1 = [[LMRealm shareRealm] queryAllObject:@"test" sortKeyName:@"age" cending:1];
//    NSLog(@"arr1  = %@",arr1);
//    
//    RLMResults *arrss = [[LMRealm shareRealm] queryFuzzyObjectName:@"test" fuzzyType:1 att:@{@"name":@"name9"}];
//    NSLog(@"arrss %@",arrss);
}


@end
