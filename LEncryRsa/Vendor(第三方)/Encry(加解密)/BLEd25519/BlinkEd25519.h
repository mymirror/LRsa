//
//  BlinkEd25519.h
//  BloodLink
//
//  Created by xuezhiyuan on 2019/1/3.
//  Copyright © 2019 Shenzhen Blood Link Medical Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Ed25519.h"

@interface Ed25519Keypair : NSObject

@property (nonatomic,strong) NSData *publickey;//公钥32位
@property (nonatomic,strong) NSData *privatekey;//私钥64位

@end
NS_ASSUME_NONNULL_BEGIN
@interface BlinkEd25519 : NSObject

/**
 生成ed25519密钥串

 @return Ed25519Keypair对象，保存一对密钥串
 */
+(Ed25519Keypair *)generateEd25519KeyPair;

/**
 签名数据

 @param ed25519keypair 密钥串
 @param content 需要签名的数据
 @return 签名后的数据
 */
+(NSData *)ed25519_Signature:(Ed25519Keypair *)ed25519keypair Content:(NSString *)content;

/**
 验证签名数据

 @param signatureData 签名数据
 @param contentData 签名前数据
 @param ed25519Publickey ed25519密钥串
 @return 返回是否
 */
+(BOOL)ed25519_Verify:(NSData *)signatureData content:(NSData *)contentData Ed25519Publickey:(NSData *)ed25519Publickey;


@end

NS_ASSUME_NONNULL_END
