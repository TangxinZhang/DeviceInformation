//
//  UIDevice+Hardware.m
//  DeviceInfomation
//
//  Created by 糖心儿 on 16/3/15.
//  Copyright © 2016年 糖心儿. All rights reserved.
//

#import "UIDevice+Hardware.h"


@implementation UIDevice (Hardware)

-(NSDictionary *)currentDeviceInfo{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:20];
    [dict setObject:[self getModel] forKey:@"model"];
    [dict setObject:[NSString stringWithFormat:@"%f",[self getCurrentBatteryLevel]] forKey:@"Battery"];
    [dict setObject:[self getCPUTypeWithPlatformString:[self platformString]] forKey:@"cpu"];
    [dict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self cpuCount]] forKey:@"cpuCount"];
    [dict setObject:[NSArray arrayWithArray:[self cpuUsage]] forKey:@"cpuUsage"];
    [dict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self totalMemoryBytes]] forKey:@"totalMemoryBytes"];
    [dict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self freeMemoryBytes]] forKey:@"freeMemoryBytes"];
    [dict setObject:[NSString stringWithFormat:@"%lld",[self freeDiskSpaceBytes]] forKey:@"freeDiskSpaceBytes"];
    [dict setObject:[NSString stringWithFormat:@"%lld",[self totalDiskSpaceBytes]] forKey:@"totalDiskSpaceBytes"];
    [dict setObject:[self getTimeZone] forKey:@"TimeZone"];
    [dict setObject:[self getModel] forKey:@"model"];
    [dict setObject:[self getMacID] forKey:@"MacID"];
    [dict setObject:[self getNetType] forKey:@"NetType"];
    [dict setObject:[self getOsVersion] forKey:@"OsVersion"];
    [dict setObject:[self getAppVersion] forKey:@"AppVersion"];
    [dict setObject:[self createUUID] forKey:@"UUID"];
    return dict;
}

#pragma mark-Platform
- (NSString *) platformString
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;

}

//Model ID        soc         ram         cpu              cpuArch       device
//iPad1,1         Apple A4    256         ARM Cortex-A8    ARMv7          iPad
//
//iPad2,1 2,2 2,3 Apple A5    512         ARM Cortex-A9    ARMv7          iPad 2
//iPad3,1 3,2 3,3	Apple A5X	1024        ARM Cortex-A9	 ARMv7	        iPad (3G)
//
//iPad3,4         Apple A6X	1024        Swift (Apple)    ARMv7s         iPad (4G)
//
//iPad4,1 4,2 4,3	Apple A7	1024        Cyclone (Apple)  ARMv8          iPad Air
//iPad4,4 4,5 4,6	Apple A7    1024        Cyclone (Apple)  ARMv8          iPad mini 2
//iPad4,7 4,8 4,9	Apple A7	1024        Cyclone (Apple)  ARMv8          iPad mini 3
//
//iPad5,3 5,4     Apple A8X	2048        Typhoon (Apple)  ARMv8          iPad Air 2
//iPad6,8         Apple A9X	4096        Twister (Apple)  ARMv8-A        iPad Pro

- (NSString *)getModel
{
    return [[UIDevice currentDevice] model];
}

//获取cpu&cpuArch
- (NSArray *)getCPUTypeWithPlatformString:(NSString *)platformString{

    NSMutableArray *cpuArray = [[NSMutableArray alloc]init];
    NSString *cpuType = [[NSString alloc]init];
    NSString *cpuArch = [[NSString alloc]init];
    
    if ([platformString isEqualToString:@"iPad1,1"]) {
        cpuType = @"ARM Cortex-A8";
        cpuArch = @"ARMv7";
        
        [cpuArray addObject:cpuType];
        [cpuArray addObject:cpuArch];
    }
    else if ([platformString hasPrefix:@"iPad2"]||
             [platformString isEqualToString:@"iPad3,1"]||
             [platformString isEqualToString:@"iPad3,2"]||
             [platformString isEqualToString:@"iPad3,3"]){
        cpuType = @"ARM Cortex-A9";
        cpuArch = @"ARMv7";
        [cpuArray addObject:cpuType];
        [cpuArray addObject:cpuArch];
    }
    else if([platformString isEqualToString:@"iPad3,4"]){
        cpuType = @"Swift (Apple)";
        cpuArch = @"ARMv7s";
        [cpuArray addObject:cpuType];
        [cpuArray addObject:cpuArch];
        
    }
    else if ([platformString hasPrefix:@"iPad4"]){
        cpuType = @"Cyclone (Apple)";
        cpuArch = @"ARMv8";
        [cpuArray addObject:cpuType];
        [cpuArray addObject:cpuArch];
    }
    else if ([platformString hasPrefix:@"iPad5"]){
        cpuType = @"Typhoon (Apple)";
        cpuArch = @"ARMv8";
        [cpuArray addObject:cpuType];
        [cpuArray addObject:cpuArch];
    }
    else if ([platformString isEqualToString:@"iPad6,8"]){
        cpuType = @"Twister (Apple)";
        cpuArch = @"ARMv8-A";
        [cpuArray addObject:cpuType];
        [cpuArray addObject:cpuArch];
    }
    
    return cpuArray;
}

#pragma mark-获取当前设备电量
-(double)getCurrentBatteryLevel
{
    
    //Returns a blob of Power Source information in an opaque CFTypeRef.
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    
    //Returns a CFArray of Power Source handles, each of type CFTypeRef.
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    
    CFDictionaryRef pSource = NULL;
    const void *psValue;
    
    //Returns the number of values currently in an array.
    long numOfSources = CFArrayGetCount(sources);
    
    //Error in CFArrayGetCount
    if (numOfSources == 0)
    {
        NSLog(@"Error in CFArrayGetCount");
        return -1.0f;
    }
    
    //Calculating the remaining energy
    for (int i = 0 ; i < numOfSources ; i++)
    {
        //Returns a CFDictionary with readable information about the specific power source.
        pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!pSource)
        {
            NSLog(@"Error in IOPSGetPowerSourceDescription");
            return -1.0f;
        }
        psValue = (CFStringRef)CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));
        
        int curCapacity = 0;
        int maxCapacity = 0;
        double percent;
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
        
        percent = ((double)curCapacity/(double)maxCapacity * 100.0f);
        
        return percent;
    }
    return -1.0f;
}

#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}
- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSArray *)cpuUsage
{
    NSMutableArray *usage = [NSMutableArray array];
    //    float usage = 0;
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if(_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if(err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        for(unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if(_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            //            NSLog(@"Core : %u, Usage: %.2f%%", i, _inUse / _total * 100.f);
            float u = _inUse / _total * 100.f;
            [usage addObject:[NSNumber numberWithFloat:u]];
        }
        
        [_cpuUsageLock unlock];
        
        if(_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        
        _prevCPUInfo = _cpuInfo;
        _numPrevCPUInfo = _numCPUInfo;
        
        _cpuInfo = nil;
        _numCPUInfo = 0U;
    } else {
        NSLog(@"Error!");
    }
    return usage;
}

#pragma mark memory information
- (NSUInteger) totalMemoryBytes
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) freeMemoryBytes
{
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    
    host_page_size(host_port, &pagesize);
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    
    //    natural_t   mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t   mem_free = vm_stat.free_count * pagesize;
    //    natural_t   mem_total = mem_used + mem_free;
    
    return mem_free;
}

#pragma mark disk information
- (long long) freeDiskSpaceBytes
{
    struct statfs buf;
    long long freespace;
    freespace = 0;
    if(statfs("/private/var", &buf) >= 0){
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    return freespace;
}

- (long long) totalDiskSpaceBytes
{
    struct statfs buf;
    long long totalspace;
    totalspace = 0;
    if(statfs("/private/var", &buf) >= 0){
        totalspace = (long long)buf.f_bsize * buf.f_blocks;
    }
    return totalspace;
}

#pragma mark-是否越狱
- (BOOL) isJailBreak
{
    int res = access("/var/mobile/Library/AddressBook/AddressBook.sqlitedb", F_OK);
    if (res != 0)
        return NO;
    return YES;
}

#pragma mark-获取时间区域
- (NSString *)getTimeZone{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    NSString *timeZoneString = [timeZone localizedName:NSTimeZoneNameStyleStandard locale:[NSLocale currentLocale]];
    if ([timeZone isDaylightSavingTimeForDate:[NSDate date]]) {
        timeZoneString = [timeZone localizedName:NSTimeZoneNameStyleDaylightSaving locale:[NSLocale currentLocale]];
    }
    
    return timeZoneString;
}

- (NSString*)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (NSString*)getAppStoreVersion
{
    NSString* sAppVersion = [self getAppVersion];
    NSArray* subVersionArr = [sAppVersion componentsSeparatedByString:@"."];
    if ([ subVersionArr count] >3)
    {
        sAppVersion = [NSString stringWithFormat:@"%@.%@.%@",[subVersionArr objectAtIndex:0]
                       ,[subVersionArr objectAtIndex:1]
                       ,[subVersionArr objectAtIndex:2]
                       ];
    }
    return sAppVersion;
}

- (NSString*)getAppBuildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleVersion"];
}

- (NSString*)getMacID
{
    return [self getMacaddress];
}

- (NSString*)getNetType
{
    return [UIDevice getNetWorkStates];
}

- (NSString*)getOsVersion
{
    return [self systemVersion];
}

+ (NSString *)getNetWorkStates
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *state = [[NSString alloc] init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"NoNet";
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                {
                    state = @"Wifi";
                }
                    break;
                default:
                {
                    state = @"UnknownNetName";
                }
                    break;
            }
        }
    }
    return state;
}

- (NSString *) getMacaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}

- (NSString *)createUUID{
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

//通过hostInfo来获取subCpuType
- (cpu_subtype_t)getSubCpuType
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo ,&infoCount);
    if (ret == KERN_SUCCESS) {
        NSLog(@"❤️the cpu_subType is :%d",hostInfo.cpu_subtype);
    }
    return  hostInfo.cpu_subtype;
}

//通过archInfo来获取cpuType
- (cpu_type_t)getCpuType{
    const NXArchInfo *archInfo = NXGetLocalArchInfo();
    NSLog(@"❤️the type is :%d",archInfo->cputype);
    return archInfo->cpusubtype;
}

@end
