//
//  MyMQTTDelegate.m
//  mosquittoLibrary
//
//  Created by GGYY on 15/3/16.
//  Copyright (c) 2015年 com.test. All rights reserved.
//

#import "MyMQTTDelegate.h"

@implementation MyMQTTDelegate

static MyMQTTDelegate *instance;

+ (MyMQTTDelegate*)shareMQTTDelegate{
    @synchronized(self) {
        
        if(!instance) {
            instance = [[MyMQTTDelegate alloc] init];
        }
        
    }
    return instance;
}

-(id)init {
    if (instance) {
        [NSException raise:NSInternalInconsistencyException format:@"Can not init MyMQTTDelegate"];
    } else {
        return [super init];
    }
    
    return 0;
}

- (void) didConnect: (NSUInteger)code ipAddr:(NSString*)IPAddrString{
    
}

- (void) didDisconnect{
    
}

- (void) didPublish: (NSUInteger)messageId{

}

- (void) didReceiveMessage: (MqttMessage*)mosq_msg{
    
}

- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos{
    
}

- (void) didUnsubscribe: (NSUInteger)messageId{
    
}

@end
