//
//  SCScrollViewController.h
//  SCScrollView
//
//  Created by 毛强 on 2016/12/1.
//  Copyright © 2016年 maoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height


@interface SCChooseButton : UIButton

+(instancetype)chooseButtonWithTitle:(NSString *)title frame:(CGRect)frame;

@end

@interface SCScrollViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *chooseViewArray;         //@[firstView,secondView,...];
@property (nonatomic, strong) NSMutableArray *chooseButtonArray;       //@[@"title1",@"title2",...];

@property (nonatomic, assign) CGFloat chooseButtonHeight;       //default 40
@property (nonatomic, assign) CGFloat chooseButtonWidth;        //default screenWidth / 2

@property (nonatomic, assign) NSInteger chooseIndex; //当前选中的item

+(instancetype)ScrollViewControllerWithViews:(NSMutableArray *)chooseViewArray buttonsTitle:(NSMutableArray *)chooseButtonArray;
//必须调用
-(void)refreshVC;
//滑动或者点击title之后调用
-(void)scrollToView;
@end
