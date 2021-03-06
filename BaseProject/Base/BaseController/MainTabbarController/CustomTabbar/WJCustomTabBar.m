//
//  WJCustomTabBar.m
//  BaseProject
//
//  Created by JerryWang on 2018/6/5.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

#import "WJCustomTabBar.h"

@interface WJCustomTabBar()<UITabBarDelegate>
@property (nonatomic,weak) UIButton *centerBtn;

@end

@implementation WJCustomTabBar

- (instancetype)init{
    if (self = [super init]) {
        self.delegate = self;
        
        [self setupCustomView];
    }
    return self;
}

- (void)setupCustomView{

    // 添加自定义按钮
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _centerBtn = centerBtn;
    
    [centerBtn setImage:[UIImage imageNamed:@"add_tabbar_icon"] forState:UIControlStateNormal];
    centerBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:centerBtn];
    
    [centerBtn addTarget:self action:@selector(centerBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 把 tabBarButton 取出来（把 tabBar 的 subViews 打印出来就明白了）
    NSMutableArray *tabBarButtonArray = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButtonArray addObject:view];
        }
    }
    
    CGFloat barWidth = self.bounds.size.width;
//    CGFloat barHeight = self.bounds.size.height;
    
    // 设置中间按钮的位置，及偏移量
    
    CGFloat offsetY = 3;
    CGFloat centerBtnWidth = barWidth / (tabBarButtonArray.count + 1);
    CGFloat centerBtnHeight = 44;
    
    self.centerBtn.frame = CGRectMake(0, offsetY, centerBtnWidth, centerBtnHeight);
    self.centerBtn.centerX = barWidth/2;

    // 重新布局其他 tabBarItem
    // 平均分配其他 tabBarItem 的宽度
    
    CGFloat barItemWidth = (barWidth-centerBtnWidth) / tabBarButtonArray.count;

    // 逐个布局 tabBarItem，修改 UITabBarButton 的 frame
    [tabBarButtonArray enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect frame = view.frame;
        
        if (idx >= tabBarButtonArray.count / 2) {
            // 重新设置 x 坐标，如果排在中间按钮的右边需要加上中间按钮的宽度
            frame.origin.x = idx * barItemWidth + centerBtnWidth;
        } else {
            frame.origin.x = idx * barItemWidth;
        }
        
        frame.origin.y -= 2;    // 微调item，向上偏移2个点
        
        // 重新设置宽度
        frame.size.width = barItemWidth;
        view.frame = frame;
    }];
}

// 重写系统的hitTest方法，解决按钮突出部分无法响应点击事件的问题

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.isHidden == NO) { // 当前界面 tabBar显示
        
        CGPoint newPoint = [self convertPoint:point toView:self.centerBtn];
        
        if ([self.centerBtn pointInside:newPoint withEvent:event]) { // 点 属于按钮范围
            return self.centerBtn;
        }else{
            return [super hitTest:point withEvent:event];
        }
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

#pragma mark - action

- (void)centerBtnDidClick:(UIButton *)btn{
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(customTabBar:didClickCenterItem:)]) {
        [self.customDelegate customTabBar:self didClickCenterItem:btn];
    }
}

#pragma mark - tabbar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(customTabBar:didClickItem:)]) {
        [self.customDelegate customTabBar:self didClickItem:item];
    }
}

@end
