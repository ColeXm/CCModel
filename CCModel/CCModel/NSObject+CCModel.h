//
//  NSObject+CCModel.h
//  CCModel
//
//  Created by ColeXm on 15/12/28.
//  Copyright © 2015年 ColeXm. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ModelMapProtocol <NSObject>


/**
 *  对象重名映射 （只支持数组或者字典映射）
 *
 *  key:      模型命名
 *  value:    Json命名
 */
@optional
+ (NSDictionary *)cc_modelMapFromJson;

@end


@interface NSObject (CCModel)<ModelMapProtocol>

/**
 *  json -> model
 *
 *  @param      jsonData 支持Str,Data,Dictionary等类型
 *  @return     模型对象
 */
+ (id)cc_modelFromJson:(id)jsonData;

/**
 *  model -> dictionary
 *
 *  @return     字典对象
 */
- (NSDictionary *)cc_modelToDictionary;

@end
