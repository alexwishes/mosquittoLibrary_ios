//
//  MyMQTTDelegate.h
//  mosquittoLibrary
//
//  Created by GGYY on 15/3/16.
//  Copyright (c) 2015年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mqttDelegate.h"

@interface MyMQTTDelegate : NSObject<mqttDelegate>

+ (MyMQTTDelegate*) shareMQTTDelegate;

@end
