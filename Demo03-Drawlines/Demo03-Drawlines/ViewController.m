//
//  ViewController.m
//  Demo03-Drawlines
//
//  Created by tarena on 15/12/17.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)startDrawLines:(id)sender {
    NSString *sourceStr = @"北京";
    NSString *targetStr = @"上海";
    
    //****设置代理
    self.mapView.delegate = self;
    
    //添加大头针对象(经纬度)
    self.geocoder = [CLGeocoder new];
    [self.geocoder geocodeAddressString:sourceStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //获取起始点的地标对象
        if (!error) {
            CLPlacemark *sourcePlacemark = [placemarks firstObject];
            //添加大头针(1,2,3)
            
            //对目标对象进行编码
            [self.geocoder geocodeAddressString:targetStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                //获取终点的地标对象
                if (!error) {
                    CLPlacemark *targetPlacemark = [placemarks firstObject];
                    //添加大头针(1,2,3)
                    
                    //进行导航
                    [self startRouteByStart:sourcePlacemark byEnd:targetPlacemark];
                }
            }];
        }
    }];
}


- (void)startRouteByStart:(CLPlacemark *)sourcePlacemark byEnd:(CLPlacemark *)targetPlacemark {
    
    MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:sourcePlacemark]];
    MKMapItem *targetItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:targetPlacemark]];
    //发送请求
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    //设定请求和起点/终点的关系
    request.source = sourceItem;
    request.destination = targetItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            //获取服务器返回的路径
            NSArray *routesArray = response.routes;
            for (MKRoute *route in routesArray) {
                //添加遮盖(添加路径的几何线到地图视图上)
                [self.mapView addOverlay:route.polyline];
                //获取每条路径的steps
                NSArray *stepsArray = route.steps;
                for (MKRouteStep *step in stepsArray) {
                    NSLog(@"描述:%@; 距离:%f",step.instructions, step.distance);
                }
            }
        }
    }];
}

//如何制定线的颜色/粗细
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    //颜色
    line.strokeColor = [UIColor redColor];
    //粗细
    line.lineWidth = 5;
    
    return line;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
