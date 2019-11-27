//
//  ServiceListener.m
//  ScoketDemo
//
//  Created by 叶俊有 on 2019/11/27.
//  Copyright © 2019 you1024. All rights reserved.
//

#import "ServiceListener.h"
#import "GCDAsyncSocket.h"

@interface ServiceListener ()
///  服务器socket
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
///  保存客户端所有的Socket对象
@property (nonatomic, strong) NSMutableArray *clientSockets;

@end
@implementation ServiceListener

- (NSMutableArray *)clientSockets
{
    if (!_clientSockets) {
        _clientSockets = [[NSMutableArray alloc] init];
    }
    return _clientSockets;
}

/**

1. 服务器绑定端口
2. 监听客户端的连接
3. 允许客户端建立连接
4. 读取客户端的请求数据
5. 处理客户端的请求数据
6. 响应客户端的请求数据
 
*/


- (void)start
{
        // 1, 创建服务器的socket对象,serverSocket只会监听有没有客户端请求连接
       GCDAsyncSocket *serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];

       // 2, 绑定和监听客户端的连接
       NSError *error = nil;
       [serverSocket acceptOnPort:1688 error:&error];

       // 判断error是否有值,如果有值表示开启失败
       if (!error) {
           // 开启成功
           NSLog(@"10086服务器已开启");
       } else {
           // 开启失败
           NSLog(@"10086服务器开启失败 : %@",error);
       }

       // 保存服务器的Socket对象
       self.serverSocket = serverSocket;
}

// 需要监听服务器是否有连接到新的客户端,所以, 监听方法是属于协议中的方法,要遵守协议

/**
 * 只要有新的端口和服务器连接就会调用该方法.
 * 前面个sock是服务器的端口, 后面个newSocket是客户端的端口,可以自定义参数名
 */
- (void)socket:(GCDAsyncSocket *)serverSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket
{
    NSLog(@"有新客户端建立联系了");
    
    // 将连接进来的客户端的Socket对象保存到数组中
    [self.clientSockets addObject:clientSocket];

    // 只要开启服务就提示用户有什么类型的服务
    NSMutableString *promptStr = [NSMutableString string];
    [promptStr appendString:@"欢迎来到10086在线服务，请输入下面的数字选择服务\n"];
    [promptStr appendString:@"[0]在线充值\n"];
    [promptStr appendString:@"[1]在线投诉\n"];
    [promptStr appendString:@"[2]优惠信息\n"];
    [promptStr appendString:@"[3]special services\n"];
    [promptStr appendString:@"[4]退出\n"];

    // 客户端写入数据
    [clientSocket writeData:[promptStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

    // 监听客户端有没有上传数据
    [clientSocket readDataWithTimeout:-1 tag:0];
}

/**
 * 监听客户端有没有输入数据,只要客户端上传了数据,那么就一定会调用下面这个方法
 *
 */
- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag
{

    NSLog(@"客户端输入数据了");

    // 此时,服务器接收到的是一个NSData,我们需要将NSData转为一个字符串
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // 将字符串转为数字,使用switch输出对应的字符串
    NSInteger number = [str integerValue];
    NSString *responseStr = nil;
    switch (number) {
        case 0:
            responseStr = @"充值服务进行中...\n";
            break;
        case 1:
            responseStr = @"10086的投诉服务几乎零处理...\n";
            break;
        case 2:
            responseStr = @"几乎所有优惠信息都是骗人的...\n";
            break;
        case 3:
            responseStr = @"特殊服务倒是做的勤快...\n";
            break;
        case 4:
            responseStr = @"您已经退出了,并且扣了50块钱\n";
            break;
        default:
            responseStr = @"别乱来，要有规律的来...\n";
            break;
    }

    // 服务器读取客户端上传的数据
    [clientSocket writeData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

    // 当number = 4 说明用户需要退出,但是我们需要将客户端和服务器之间的连接断开
    if (number == 4) {
        // 将数组中的客户端全部移除掉
        [self.clientSockets removeObject: clientSocket];
    }

    // 只要客户端上传1次数据,服务器都需要监听它
    [clientSocket readDataWithTimeout:-1 tag:0];
}

@end
