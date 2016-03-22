//
//  UIDevice+Hardware.h
//  DeviceInfomation
//
//  Created by 糖心儿 on 16/3/15.
//  Copyright © 2016年 糖心儿. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <mach/processor_info.h>
#include <sys/stat.h>
#import "IOPSKeys.h"
#import "IOPowerSources.h"
#import "UIDevice+Addition.h"
#import <mach-o/arch.h>


@interface UIDevice (Hardware)

- (NSString *) platformString;      //平台信息
- (double)getCurrentBatteryLevel;    //获取当前设备电量

- (NSUInteger) cpuCount;            //cpu核数
- (NSArray *) cpuUsage;             //cpu利用率

- (NSUInteger) totalMemoryBytes;    //获取手机内存总量,返回的是字节数
- (NSUInteger) freeMemoryBytes;     //获取手机可用内存,返回的是字节数

- (long long) freeDiskSpaceBytes;   //获取手机硬盘空闲空间,返回的是字节数
- (long long) totalDiskSpaceBytes;  //获取手机硬盘总空间,返回的是字节数

- (BOOL) isJailBreak;               //是否越狱

- (NSString *)getAppVersion;        //App版本
- (NSString *)getAppStoreVersion;
- (NSString *)getAppBuildVersion;
- (NSString *)getMacID;
- (NSString *)getNetType;
- (NSString *)getOsVersion;
- (NSString *)getTimeZone;
- (NSString *)getMacaddress;
- (NSString *)createUUID;
- (cpu_subtype_t)getSubCpuType;
- (cpu_type_t)getCpuType;

- (NSArray *)getCPUTypeWithPlatformString:(NSString *)platformString;//cpu型号
- (NSDictionary *)currentDeviceInfo;  //汇总获取
@end
