//
//  mosquittoLibrary.h
//  mosquittoLibrary
//
//  Created by GGYY on 15/2/16.
//  Copyright (c) 2015年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MqttClient.h"

#define CHAT_TYPE_TEXT @"text"
#define CHAT_TYPE_IMG @"image"
#define CHAT_TYPE_SOUND @"sound"  

@interface mosquittoLibrary : NSObject{

}

+ (mosquittoLibrary *) shareMosq;
+ (void)addConnections:(MqttClient*)mosq;
+ (NSArray*)getConnections;

- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
- (void)clearWill;

- (MqttClient*) getMQClient;
- (void)connectToServer:(NSString *)userName password:(NSString *)pass clientId:(NSString*)clientId delegate:(id)delegate;
- (BOOL)subscribe:(NSString*)topic withQos:(NSUInteger)qos;
- (void)sendMsg: (NSString *)msg toWhom:(NSString *)reciever chatType:(NSString *)chatType;

- (NSString*)getServerAddress;
- (void)setServerAddress:(NSString*)address;
- (void)setServerPort:(NSInteger)iPort;
- (NSInteger)getServerPort;

- (void)setUploadUrl:(NSString*)address;
- (void)setDownloadUrl:(NSString*)address;
- (NSString*)getUploadUrl;
- (NSString*)getDownloadUrl;

- (void)setQos:(NSInteger)iQos;
- (void)setKeepAliveTime:(NSInteger)time;
- (void)setSysName:(NSString*)strSysName;

- (void)uploadFile:(NSString*)fileDocumentPath delegate:(id)delegate;
- (void)downloadFile:(NSString*)fileName withType:(NSString*)type delegate:(id)delegate;

@end
