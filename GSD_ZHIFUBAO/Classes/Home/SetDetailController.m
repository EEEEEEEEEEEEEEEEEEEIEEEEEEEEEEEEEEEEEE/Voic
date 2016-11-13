//
//  SetDetailController.m
//  GSD_ZHIFUBAO
//
//  Created by 杨京蕾 on 11/12/16.
//  Copyright © 2016 GSD. All rights reserved.
//

#import "SetDetailController.h"
#import "UIViewAdditions.h"
#import "SDGridItemCacheTool.h"
#import "DeviceInfo.h"

#define kUserDefaultDeviceTitleKey @"title"
#define kUserDefaultDeviceImageResStringKey @"imageResString"
#define KUserDefaultDeviceCurrentStatKey @"currentStat"

@interface SetDetailController ()

@property (nonatomic, strong) NSMutableArray *allVC;
@property (nonatomic, strong) SMPagerTabView *segmentView;
@property (nonatomic, strong) DeviceInfo* deviceInfo;
@property (nonatomic, strong) NSMutableDictionary* colorStatPair;
@property (nonatomic, strong) NSString* imgResString;

@end

@interface SetDetailController () {
    NSInteger _tabNum;
    NSString* _deviceName;
}

@end

@implementation SetDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor hexColor:@"ededed"];
    
    UIBarButtonItem * rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(didFinishSetting:)];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    self.colorStatPair = [NSMutableDictionary new];
    _allVC = [NSMutableArray array];
    
    for (int i = 0; i < (_tabNum+1); i++ ) {
        SetDetailTableViewController* vc = [[SetDetailTableViewController alloc]initWithNibName:nil bundle:nil];
        vc.tag = @(i);
        if (i == 0) {
            vc.title = [NSString stringWithFormat:@"状态%@（默认）", @(i+1)];
        }else {
            vc.title = [NSString stringWithFormat:@"状态%@", @(i+1)];
        }
        [_allVC addObject:vc];
    }
    
    self.segmentView.delegate = self;
    //可自定义背景色和tab button的文字颜色等
    //    self.segmentView.tabButtonTitleColorForSelected = kColorMainGreen;
    
    //开始构建UI
    [_segmentView buildUI];
    //起始选择一个tab
    [_segmentView selectTabWithIndex:0 animate:NO];
    //显示红点，点击消失
    //    [_segmentView showRedDotWithIndex:0];
}

- (void)setTabNumber:(NSInteger)tabNum {
    _tabNum = tabNum;
}

-(void)setDeviceName:(NSString *)deviceName {
    _deviceName = deviceName;
}

- (void)setImgResString:(NSString *)imgResString {
    _imgResString = imgResString;
}

#pragma mark - DBPagerTabView Delegate
- (NSUInteger)numberOfPagers:(SMPagerTabView *)view {
    return [_allVC count];
}
- (UIViewController *)pagerViewOfPagers:(SMPagerTabView *)view indexOfPagers:(NSUInteger)number {
    return _allVC[number];
}

- (void)whenSelectOnPager:(NSUInteger)number {
    NSLog(@"页面 %lu",(unsigned long)number);
}

#pragma mark - setter/getter
- (SMPagerTabView *)segmentView {
    if (!_segmentView) {
        self.segmentView = [[SMPagerTabView alloc]initWithFrame:CGRectMake(10, 10, self.view.width-20, 180)];
        [self.view addSubview:_segmentView];
    }
    return _segmentView;
}

- (void)didFinishSetting:(NSDictionary*)settings {
    
    _deviceInfo = [[DeviceInfo alloc] init];
    _deviceInfo.title = _deviceName;
    _deviceInfo.imageResString = _imgResString;
    _deviceInfo.currentStat = @(0);
    
    //    NSMutableDictionary* tempInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:kUserDefaultDeviceTitleKey, _deviceName,kUserDefaultDeviceImageResStringKey, _imgResString, KUserDefaultDeviceCurrentStatKey, @(0), nil];
    
    for (SetDetailTableViewController* tableVC in _allVC) {
        if ([tableVC check]) {
            NSArray* arr = [tableVC collectDetail];
            [self.colorStatPair setObject:arr forKey:tableVC.tag];
        }else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"设置未完成" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                return;
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
    _deviceInfo.colorStatPair = _colorStatPair;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_deviceInfo];
    
    NSMutableArray *temp = [NSMutableArray new];
    temp = [[SDGridItemCacheTool itemsArray] mutableCopy];
//    [temp addObject:[SDGridItemCacheTool itemsArray]];
    [temp addObject:data];
    NSArray* arr = [NSArray new];
    arr = [temp copy];
    [SDGridItemCacheTool saveItemsArray:arr];
    
    [self toast:@"添加成功" seconds:2];
    [self.navigationController performSelector:@selector(popToRootViewControllerAnimated:) withObject:nil afterDelay:2.0];
}

#pragma mark - delegate

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
