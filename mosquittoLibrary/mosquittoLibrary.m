//
//  mosquittoLibrary.m
//  mosquittoLibrary
//
//  Created by GGYY on 15/2/16.
//  Copyright (c) 2015年 com.pingan. All rights reserved.
//

#import "mosquittoLibrary.h"
#import "MqttClient.h"
#import "MyMQTTDelegate.h"

#define CHAT_TYPE_TEXT_FLG @"0"                                 
#define CHAT_TYPE_IMG_FLG @"1"                                  
#define CHAT_TYPE_SOUND_FLG @"2"                                

#define MSG_PACK_TYPE_CHAT @"0"

#define TWITTERFON_FORM_BOUNDARY @"--FileUpload"
#define UPLOAD_FILE_URL @"http://localhost/upload"
#define DOWNLOAD_FILE_URL @"http://localhost"

#define UPLOAD_SUCCESS @"Upload Success"

@interface mosquittoLibrary()
{
    NSString *sysName;
    NSInteger qos;
    NSInteger keepAliveTime;
    NSInteger port;
    NSString *host;
    NSString *uploadUrl;
    NSString *downloadUrl;
    
    MqttClient *mqClient;
}
@end

@implementation mosquittoLibrary
static NSMutableArray *mosqClients;
static mosquittoLibrary *mosq;

+ (mosquittoLibrary*)shareMosq{
    if (!mosq) {
        mosq = [[mosquittoLibrary alloc] init];
    }
    return mosq;
}

- (id)init{
    if (mosq) {
        [NSException raise:NSInternalInconsistencyException format:@"Can not init mosquittoLibrary"];
    } else {
        qos = 0;
        keepAliveTime = 300;

        return [super init];
    }
    
    return 0;
}

- (MqttClient*) getMQClient{
    return mqClient;
}

- (void)connectToServer:(NSString *)userName password:(NSString *)pass clientId:(NSString*)clientId delegate:(id)delegate{
    
    MqttClient *mosq = [[MqttClient alloc] initWithClientId:clientId];
    mosq.username = userName;
    mosq.password = pass;
    mosq.cleanSession = NO;
    mosq.port = port;
    mosq.keepAlive = keepAliveTime;
    [mosq connectToHost:host];
    
    [mosq setDelegate:delegate];
    
    mqClient = mosq;
}

- (BOOL)subscribe:(NSString*)topic withQos:(NSUInteger)qos{
    if(mqClient == nil){
        NSLog(@"There's no connections for mqtt now. Please connect to mqtt server first.");
        return NO;
    }else{
        [mqClient subscribe:topic withQos:qos];
        return YES;
    }
}

- (void)sendMsg:(NSString *)msg toWhom:(NSString *)reciever chatType:(NSString *)chatType{
    if(mqClient == nil){
        NSLog(@"There's no connections for mqtt now. Please connect to mqtt server first.");
        return;
    }else{
        NSString *strChatType;
        NSString *sender;
        
        if([chatType isEqualToString:CHAT_TYPE_IMG]){
            strChatType = CHAT_TYPE_IMG_FLG;
        }else if([chatType isEqualToString:CHAT_TYPE_SOUND]){
            strChatType = CHAT_TYPE_SOUND_FLG;
        }else if([chatType isEqualToString:CHAT_TYPE_TEXT]){
            strChatType = CHAT_TYPE_TEXT_FLG;
        }
        
        NSString *localTime = [self getCurrentTime];
        
        sender = mqClient.username;
        
        NSString *jsonPayload = [NSString stringWithFormat:@"{\"type\":\"%@\",\"chat\":{\"type\":\"%@\",\"from\":\"%@\",\"to\":\"%@\",\"date\":\"%@\",\"msg\":\"%@\"}}",MSG_PACK_TYPE_CHAT, strChatType,[sender uppercaseString],[reciever uppercaseString],localTime,msg];
        
        NSLog(@"Payload = %@",jsonPayload);
        
        [mqClient publishString:jsonPayload toTopic:[reciever uppercaseString] withQos:qos retain:NO];
    }
}

- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain{
    
    if(mqClient == nil){
        NSLog(@"There's no connections for mqtt now. Please connect to mqtt server first.");
        return;
    }else{
        [mqClient setWill:payload toTopic:willTopic withQos:willQos retain:retain];
    }
}

- (void)clearWill{
    if(mqClient == nil){
        NSLog(@"There's no connections for mqtt now. Please connect to mqtt server first.");
        return;
    }else{
        [mqClient clearWill];
    }
}

- (void)uploadFile:(NSString*)fileDocumentPath delegate:(id)delegate{
    NSString *upUrl;
    if([mosq getUploadUrl] == nil){
        upUrl = UPLOAD_FILE_URL;
    }else{
        upUrl = [mosq getUploadUrl];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:upUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSString *MPboundary = [[NSString alloc] initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary = [[NSString alloc] initWithFormat:@"%@--",MPboundary];
    
    NSString* fileName;
    NSString* type;
    
    if([fileDocumentPath rangeOfString:@"/"].location == NSNotFound){
        fileName = [NSString stringWithFormat:@"/%@",fileDocumentPath];
        NSLog(@"Warning: your fileDocumentPath may be wrong, please check.");
    }else{
        fileName = [fileDocumentPath substringFromIndex:[fileDocumentPath rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
    }
    
    if([fileName rangeOfString:@"."].location == NSNotFound){
        type = [NSString stringWithFormat:@"%@.jpg",fileName];
        NSLog(@"Warning: your file may be wrong, use jpg as file's extension name ,please check.");
    }else{
        type = [fileName substringFromIndex:[fileName rangeOfString:@"."].location + 1];
    }
    
    NSString* fileType;
    if([type isEqualToString:@"png"]){
        fileType = @"image/png";
    }else if([type isEqualToString:@"jpg"]){
        fileType = @"image/jpg";
    }else if([type isEqualToString:@"wav"]){
        fileType = @"audio/wav";
    }else if([type isEqualToString:@"amr"]){
        fileType = @"audio/amr";
    }
    
    NSData *data = [NSData dataWithContentsOfFile:fileDocumentPath];
    
    NSMutableString *body = [NSMutableString new];
    [body appendFormat:@"%@\r\n",MPboundary];
    [body appendFormat:@"Content-Disposition: form-data;name=\"title\"\r\n\r\n\r\n"];
    [body appendFormat:@""];
    
    [body appendFormat:@"%@\r\n",MPboundary];
    [body appendFormat:@"Content-Disposition: form-data;name=\"upload\";filename=\"%@\"\r\n",fileName];
    [body appendFormat:@"Content-Type: %@\r\n\r\n",fileType];
    
    NSString *end = [[NSString alloc] initWithFormat:@"\r\n%@",endMPboundary];
    NSMutableData *myRequestData = [NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData appendData:data];
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d",[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
}

- (void)downloadFile:(NSString*)fileName withType:(NSString*)type delegate:(id)delegate{
    NSString *downUrl;
    if([mosq getDownloadUrl] == nil){
        downUrl = DOWNLOAD_FILE_URL;
    }else{
        downUrl = [mosq getDownloadUrl];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",downUrl,type,fileName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
}

- (NSString*)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *localTime = [formatter stringFromDate:[NSDate date]];
    
    return localTime;
}

- (NSString*)getServerAddress{
    return host;
}

- (void)setServerPort:(NSInteger)iPort{
    port = iPort;
}

- (void)setServerAddress:(NSString*)address{
    host = address;
}

- (void)setUploadUrl:(NSString*)address{
    uploadUrl = address;
}

- (void)setDownloadUrl:(NSString*)address{
    downloadUrl = address;
}

- (NSString*) getUploadUrl{
    return uploadUrl;
}

- (NSString*) getDownloadUrl{
    return downloadUrl;
}

- (NSInteger)getServerPort{
    return port;
}

- (void)setQos:(NSInteger)iQos{
    qos = iQos;
}

- (void)setKeepAliveTime:(NSInteger)time{
    keepAliveTime = time;
}

- (void)setSysName:(NSString *)strSysName{
    sysName = strSysName;
}

@end
