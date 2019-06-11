//
//  test2.h
//  realmOrm
//
//  Created by ponted on 2019/6/10.
//Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import <Realm/Realm.h>

@interface test2 : RLMObject

@property NSString *testName;

@property NSString *age;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<test2 *><test2>
RLM_ARRAY_TYPE(test2)
