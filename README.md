you need import the frameworks when you use the demo
1.UIKit.framework
2.Foundation.framework
3.CoreLocation.framework
4.MapKit.framework

CoreLocation.framework and MapKit.framework make you find the location of your device

#import <CoreLocation/CoreLocation.h> and #improt"UIdevice+Hardware.h" and #import<MapKit/MapKit.h> in your program viewcontroller
and use 
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *dic = [device currentDeviceInfo];
    get your need informations.
