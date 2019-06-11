//
//  test.h
//  realmOrm
//
//  Created by ponted on 2019/6/5.
//Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import <Realm/Realm.h>

@interface test : RLMObject

@property NSString *name;

@property NSString *age;

@property NSString *idString;

@property NSString *email;
//
//@property NSString *uutest;
//////
@property NSString *me;
////
@property NSString *haha;
////
//@property NSString *haha1;
////
//@property NSString *haha4;



@end

// This protocol enables typed collections. i.e.:
// RLMArray<test *><test>
RLM_ARRAY_TYPE(test)
