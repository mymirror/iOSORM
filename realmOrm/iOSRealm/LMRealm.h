//
//  LMRealm.h
//  realmOrm
//
//  Created by ponted on 2019/6/6.
//  Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"

typedef enum : NSUInteger {
    FuzzyBeginSearch = 1,
    FuzzyEndSearch =2,
    FuzzyContainsearch = 3,
} FuzzySearch;



NS_ASSUME_NONNULL_BEGIN

@interface LMRealm : NSObject

//数据库是否是加密安全的 默认不加密：0  否则加密；1
//注意这个参数如果设置为1的时候，必须在APP使用的时候进行初始化 否则会发生不可预见的错误
@property (nonatomic, assign) BOOL isSecu;

//创建数据库 数据库基本操作:增删改查 数据库迁移

+(LMRealm *)shareRealm;

/**
 创建用户数据库(根据用户区分数据库)

 @param userName 数据库Name 
 */
- (void)setDefaultRealmForUser:(NSString *)userName;

//插入或者更新数据 当object主键存在，则更新object；否则直接增加object
- (void)realmAdd_UpdateObject:(id)object;

//delete object
- (void)realmDeleteObject:(id)object;

// delete all object
- (void)realmDeleteAllObject;

//查询数据 分为几种 精确查询和模糊查询
//query table all object  objectName: 类名
/**
 query data

 @param objectName tablename 
 @return           querydata
 */
- (RLMResults *)queryAllObject:(NSString *)objectName;

//fuzzysearch   当 fuzzysearch=0是精确查找；1-3是模糊查询，其中1匹配开头，2匹配结尾，3匹配中间
/**
 query action

 @param objectName tablename
 @param searchType query type
 @param attDic     query param
 @return            query data
 */
- (RLMResults *)queryFuzzyObjectName:(NSString *)objectName fuzzyType:(FuzzySearch)searchType att:(NSDictionary *)attDic;


/**
 条件排序

 @param objectName 查询的类
 @param name       排序的字段
 @param ascending  升序还是降序
 @return           RLMResults
 */
- (RLMResults *)queryAllObject:(NSString *)objectName sortKeyName:(NSString *)name cending:(BOOL)ascending;


/**
 数据库迁移

 @param version    数据库版本
 @param userName   数据库名称
 @param block      回调
 数据库迁移可以分为几种：
 1、值的更新  
 example:    [migration enumerateObjects:Person.className
                              block:^(RLMObject *oldObject, RLMObject *newObject) {

            // 将两个 name 合并到 fullName 当中
            newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
                                      oldObject[@"firstName"],
                                      oldObject[@"lastName"]];
            }];
 2、属性的重命名
 example:   if (oldSchemaVersion < 1) {
            // 重命名操作必须要在 `enumerateObjects:` 调用之外进行
            [migration renamePropertyForClass:Person.className oldName:@"yearsSinceBirth" newName:@"age"];
            }
 3、线性迁移
  example:  假如说，我们的应用有两个用户： JP 和 Tim。JP 经常更新应用，但 Tim 却经常跳过某些版本。所以 JP 可能下载过这个应用的每一个版本，并且一步一步地跟着更新构架：第一次下载更新后，数据库架构从 v0 更新到 v1；第二次架构从 v1 更新到 v2…以此类推，井然有序。相反，Tim 很有可能直接从 v0 版本直接跳到了 v2 版本。 因此，您应该使用非嵌套的 if (oldSchemaVersion < X) 结构来构造您的数据库迁移模块，以确保无论用户在使用哪个版本的架构，都能完成必需的更新。
 */
- (void)DatabaseMigration_CurrentVersion:(NSString *)version dbName:(NSString *)userName block:(void(^)(RLMMigration *migration,uint64_t oldSchemaVersion))block;


@end

NS_ASSUME_NONNULL_END
