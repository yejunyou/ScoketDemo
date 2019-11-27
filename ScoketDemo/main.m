//
//  main.m
//  ScoketDemo
//
//  Created by 叶俊有 on 2019/11/27.
//  Copyright © 2019 you1024. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceListener.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"socket listen begin-------!");
        
        ServiceListener *service = [[ServiceListener alloc] init];
        [service start];
        [[NSRunLoop mainRunLoop] run];
        
        NSLog(@"socket listen end-------!");
    }
    return 0;
}
