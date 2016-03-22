//
//  UIDevice+Addition.m
//  DeviceInfomation
//
//  Created by 糖心儿 on 16/3/15.
//  Copyright © 2016年 糖心儿. All rights reserved.
//

#import "UIDevice+Addition.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+Hardware.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice (Addition)

#pragma mark Public Methods

- (NSString *) uniqueDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] getMacaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash stringFromMD5];
    
    return uniqueIdentifier;
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] getMacaddress];
    NSString *uniqueIdentifier = [macaddress stringFromMD5];
    
    return uniqueIdentifier;
}
@end
