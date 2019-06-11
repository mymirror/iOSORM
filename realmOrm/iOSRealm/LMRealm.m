//
//  LMRealm.m
//  realmOrm
//
//  Created by ponted on 2019/6/6.
//  Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import "LMRealm.h"
#import <objc/runtime.h>

@implementation LMRealm

static RLMRealm *realm  = nil;

+ (LMRealm *)shareRealm
{
    static LMRealm *lmRealm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lmRealm = [[LMRealm alloc]init];
    });
    return lmRealm;
}

//生成随机的加密密钥
- (NSData *)randomSec:(NSString *)indentify
{
    NSString *str =  [indentify stringByAppendingFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    const char *kKeychainIdentifier = [str UTF8String];
    NSData *tag = [[NSData alloc] initWithBytesNoCopy:(void *)kKeychainIdentifier
                                               length:sizeof(kKeychainIdentifier)
                                         freeWhenDone:NO];

    // First check in the keychain for an existing key
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecReturnData: @YES};

    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef);
    if (status == errSecSuccess) {
        return (__bridge NSData *)dataRef;
    }
    
    uint8_t buffer[64];
    status = SecRandomCopyBytes(kSecRandomDefault, 64, buffer);
    NSAssert(status == 0, @"Failed to generate random bytes for key");
    NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];

    // Store the key in the keychain
    query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrApplicationTag: tag,
              (__bridge id)kSecAttrKeySizeInBits: @512,
              (__bridge id)kSecValueData: keyData};

    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    NSAssert(status == errSecSuccess, @"Failed to insert new key in the keychain");

    return keyData;
}

- (void)setDefaultRealmForUser:(NSString *)userName{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    //使用默认的目录,使用用户名来替换默认的文件名
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]URLByAppendingPathComponent:userName]URLByAppendingPathExtension:@"realm"];
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@:%@",userName,@"ormVersion"]];
    if (version.integerValue) {
        config.schemaVersion = version.integerValue;
    }
    if (self.isSecu) {
        config.encryptionKey = [self randomSec:userName];
    }
    //将这个配置应用到默认的realm数据库中
    [RLMRealmConfiguration setDefaultConfiguration:config];
    if (realm == nil) {
        realm = [RLMRealm realmWithConfiguration:config error:nil];
    }
}

//新增或者更新
- (void)realmAdd_UpdateObject:(id)object
{
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:object];
    [realm commitWriteTransaction];
}

//删除
- (void)realmDeleteObject:(id)object
{
    [realm beginWriteTransaction];
    Class objectClass = [object class];
    object = [objectClass createOrUpdateInRealm:realm withValue:object];
    [realm deleteObject:object];
    [realm commitWriteTransaction];
}

- (void)realmDeleteAllObject
{
    if (![realm isEmpty]) {
        [realm deleteAllObjects]; 
    }
}

- (RLMResults *)queryAllObject:(NSString *)objectName sortKeyName:(NSString *)name cending:(BOOL)ascending
{
    Class object = NSClassFromString(objectName);
    NSArray *propertyArr = [self getObjectProperty:objectName];
    BOOL hasSortName = [propertyArr containsObject:name];
    if (!hasSortName) {
        NSString *msg = [NSString stringWithFormat:@"%@不存在%@",objectName,name];
        NSAssert(NO, msg);
        return nil;
    }
    RLMResults *arr = [[object allObjects] sortedResultsUsingKeyPath:name ascending:ascending];
    return arr;
}

//查询所有
- (RLMResults *)queryAllObject:(NSString *)objectName
{
    Class object = NSClassFromString(objectName);
    RLMResults *arr = [object allObjects];
    return arr;
}

// 查询 searchType = 0 精确查询 searchType = 1-3 模糊查询
- (RLMResults *)queryFuzzyObjectName:(NSString *)objectName 
                           fuzzyType:(FuzzySearch)searchType 
                                 att:(NSDictionary *)attDic
{
    Class object  = NSClassFromString(objectName);
    //获取查询类所有属性
    NSMutableArray *objectProArray = [self getObjectProperty:objectName];
    NSArray *attKeyArray = [attDic allKeys];
    BOOL hasAllKey = YES;
    NSString *existkey = nil;
    for (NSString *keyString in attKeyArray) {
        if (![objectProArray containsObject:keyString]) {
            hasAllKey = NO;
            existkey = keyString;
            break;
        }
    }
    if (!hasAllKey) {
        NSString *msg = [NSString stringWithFormat:@"%@不存在%@字段",objectName,existkey];
        NSAssert(NO,msg);
        return nil;
    }
    
    NSString *searchCompare = @"=";
    if (searchType == 0) {
        //精确查询
        searchCompare = @"=";
    }
    
    switch (searchType) {
        case FuzzyBeginSearch:
            searchCompare = @"BEGINSWITH";
            break;
            
        case FuzzyEndSearch:
            searchCompare = @"ENDSWITH";
            break;
            
        default:
            searchCompare = @"CONTAINS";
            break;
    }
    
    NSMutableString *sql = [NSMutableString string];
    for (NSInteger i = 0; i<attKeyArray.count;i++) {
        NSString *keyString = attKeyArray[i];
        if (i == attKeyArray.count-1) {
            [sql setString:[sql stringByAppendingFormat:@"%@ %@ '%@'",keyString,searchCompare,attDic[keyString]]];
        }else
        {
            [sql setString:[sql stringByAppendingFormat:@"%@ %@ '%@' and ",keyString,searchCompare,attDic[keyString]]];
        }
    }
    if (!sql.length) {
        return nil;
    }
    RLMResults *array = [object objectsWhere:sql];
    return array;     
}

- (NSMutableArray *)getObjectProperty:(NSString *)objectName
{
    Class object = NSClassFromString(objectName);
    //获取类的所有属性
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(object, &outCount);
    NSMutableArray *properArray = [NSMutableArray array];
    for (NSInteger i = 0; i<outCount; i++) {
        NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (propertyName && propertyName.length) {
            [properArray addObject:propertyName];
        }
    }
    free(properties);
    return properArray;
}

//数据库迁移
- (void)DatabaseMigration_CurrentVersion:(NSString *)version dbName:(NSString *)userName block:(void(^)(RLMMigration *migration,uint64_t oldSchemaVersion))block
{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];  
    if (self.isSecu) {
        config.encryptionKey = [self randomSec:userName];
    }  
    //使用默认的目录,使用用户名来替换默认的文件名
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]URLByAppendingPathComponent:userName]URLByAppendingPathExtension:@"realm"];
    // 1. 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
    NSInteger newVersion = version.integerValue;
    config.schemaVersion = newVersion;
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:[NSString stringWithFormat:@"%@:%@",userName,@"ormVersion"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 2. 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
    [config setMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion){
        if (oldSchemaVersion < newVersion) {
            if (block) {
                block(migration,oldSchemaVersion);
            }
        }
    }];
    
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    [RLMRealm defaultRealm];
}

@end
