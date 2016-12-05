//
//  SCScrollViewController.m
//  SCScrollView
//
//  Created by 毛强 on 2016/12/1.
//  Copyright © 2016年 maoqiang. All rights reserved.
//

#import "SCScrollViewController.h"


#define CHOOSEBUTTONFEFAULTHEIGHT 49
#define LINEHEIGHT 2

@implementation SCChooseButton
+(instancetype)chooseButtonWithTitle:(NSString *)title frame:(CGRect)frame{
    SCChooseButton *button = [[SCChooseButton alloc]initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    return button;
}

@end

@interface SCScrollViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *chooseButtonBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *lineView;


@property (nonatomic, assign) CGPoint chooseButtonBarContentOffsetBefore;
@property (nonatomic, assign) CGPoint scrollViewContentOffsetBefore;

@property (nonatomic, strong) SCChooseButton *currentButton;

-(void)refreshVC;
@end

@implementation SCScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)) {
        
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark factory method
+(instancetype)ScrollViewControllerWithViews:(NSArray *)chooseViewArray buttonsTitle:(NSArray *)chooseButtonArray{
    
    SCScrollViewController *scrollVc = [[SCScrollViewController alloc]init];
    
    scrollVc.chooseViewArray = chooseViewArray;
    scrollVc.chooseButtonArray = chooseButtonArray;
    
//    NSAssert(chooseButtonArray.count != 0 , @"chooseButtonArray.count = %lu", chooseButtonArray.count);
//    NSAssert(chooseViewArray.count != 0 , @"chooseViewArray.count = %lu", chooseViewArray.count);
    NSAssert(chooseButtonArray.count == chooseViewArray.count , @"chooseButtonArray.count != chooseViewArray.count");

    return scrollVc;
}

#pragma mark refreshVC
-(void)refreshVC{

        [_chooseButtonBar removeFromSuperview];
        [_scrollView removeFromSuperview];
    
        _chooseButtonBar = nil;
        _scrollView = nil;
    
        self.chooseButtonBar.frame = CGRectMake(0, 64, SCREENWIDTH, (self.chooseButtonHeight)+LINEHEIGHT);
        
        self.scrollView.frame = CGRectMake(0, (self.chooseButtonHeight) + LINEHEIGHT+64, SCREENWIDTH, SCREENHEIGHT-LINEHEIGHT-(self.chooseButtonHeight)-64);
}

#pragma mark 点击button
-(void)clickButton:(SCChooseButton *)button{
    
    self.currentButton.selected = NO;
    button.selected = YES;
    self.currentButton = button;

    [self.chooseButtonArray enumerateObjectsUsingBlock:^(NSString * title, NSUInteger index, BOOL * _Nonnull stop) {
        if ([title isEqualToString:button.titleLabel.text]) {

            //line滚动
            [UIView animateWithDuration:0.25 animations:^{
                self.lineView.frame = CGRectMake(button.frame.origin.x, self.lineView.frame.origin.y, self.lineView.frame.size.width, self.lineView.frame.size.height);
            }];
            //scrollView滚动
            [self.scrollView setContentOffset:CGPointMake(index*SCREENWIDTH, 0) animated:NO];
            self.chooseIndex = index;
            [self scrollToView];
        }
    }];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.x);
    
    if (scrollView == self.scrollView) {
        self.scrollViewContentOffsetBefore = scrollView.contentOffset;
        self.chooseButtonBarContentOffsetBefore = self.chooseButtonBar.contentOffset;;
        
        CGFloat offset = scrollView.contentOffset.x / SCREENWIDTH;
        NSInteger page = (NSInteger)offset;
        
        if ((offset - page) == 0) {
            NSLog(@"%lu", page);
            
            //button最大x值超过屏幕一半width
            if (page*(self.chooseButtonWidth)>SCREENWIDTH*0.5) {
                //右翻
                if (page > self.chooseIndex) {
                    [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonBar.contentOffset.x + (self.chooseButtonWidth), 0) animated:NO];
                    
                    //右边最长偏移
                    if (self.chooseButtonBar.contentOffset.x > self.chooseButtonArray.count * self.chooseButtonWidth-SCREENWIDTH) {
                        [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonArray.count * self.chooseButtonWidth-SCREENWIDTH, 0) animated:NO];
                    }
                    
                }else if (page < self.chooseIndex){//左翻
                    [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonBar.contentOffset.x - (self.chooseButtonWidth), 0) animated:NO];
                    
                    //左翻是否需要偏移
                    CGFloat pageMinX = page*(self.chooseButtonWidth);
                    
                    NSInteger multipleScreen = pageMinX / SCREENWIDTH;
                    if ((pageMinX - multipleScreen*SCREENWIDTH - self.chooseButtonBarContentOffsetBefore.x <= SCREENWIDTH*0.5) && self.chooseButtonWidth != SCREENWIDTH * 0.5) {
                        [self.chooseButtonBar setContentOffset:CGPointMake(self.chooseButtonBar.contentOffset.x + (self.chooseButtonWidth), 0) animated:NO];
                    }
                    
                }
                
            }else if (page*(self.chooseButtonWidth)<SCREENWIDTH*0.5){
                [self.chooseButtonBar setContentOffset:CGPointMake(0, 0) animated:NO];
                
            }
            
            [self.chooseButtonBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[SCChooseButton class]]) {
                    SCChooseButton *button = (SCChooseButton *)obj;
                    
                    if ([button.titleLabel.text isEqualToString: [self.chooseButtonArray objectAtIndex:page]]) {
                        self.currentButton.selected = NO;
                        button.selected = YES;
                        self.currentButton = button;
                    }
                }
            }];
            
            NSLog(@"---%f", self.chooseButtonBar.contentOffset.x);
            [UIView animateWithDuration:0.25 animations:^{
                self.lineView.frame = CGRectMake(page*(self.chooseButtonWidth), self.lineView.frame.origin.y, self.lineView.frame.size.width, self.lineView.frame.size.height);
            }];
            self.chooseIndex = page;
            [self scrollToView];
        }
        
    }else if (scrollView == self.chooseButtonBar){
        //        NSLog(@"---%f", self.chooseButtonBar.contentOffset.x);
        
    }

}

-(void)scrollToView{

}

#pragma mark lazy loads
-(UIScrollView *)chooseButtonBar{
    if (nil == _chooseButtonBar) {
        _chooseButtonBar = [[UIScrollView alloc]init];
        _chooseButtonBar.backgroundColor = [UIColor whiteColor];
        
        [self.chooseButtonArray enumerateObjectsUsingBlock:^(NSString* buttonTitle, NSUInteger index, BOOL * _Nonnull stop) {
            
            CGRect frame = CGRectMake((self.chooseButtonWidth)*index, 0, self.chooseButtonWidth, self.chooseButtonHeight);
            
            SCChooseButton *button = [SCChooseButton chooseButtonWithTitle:buttonTitle frame:frame];
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            if (index == 0) {
                self.currentButton = button;
                button.selected = YES;
            }
            [_chooseButtonBar addSubview:button];
        }];

        _chooseButtonBar.showsHorizontalScrollIndicator = NO;
        _chooseButtonBar.showsVerticalScrollIndicator = NO;
        _chooseButtonBar.alwaysBounceVertical = NO;
        _chooseButtonBar.alwaysBounceHorizontal = NO;
        _chooseButtonBar.bounces = NO;
        _chooseButtonBar.scrollEnabled = YES;
        _chooseButtonBar.pagingEnabled = YES;
        _chooseButtonBar.contentSize = CGSizeMake((self.chooseButtonWidth)*self.chooseButtonArray.count, 0);
        
        [_chooseButtonBar addSubview:self.lineView];
        _chooseButtonBar.delegate = self;
        
        [self.view addSubview:_chooseButtonBar];
    }
    return _chooseButtonBar;
}

-(UIScrollView *)scrollView{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor lightGrayColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
//        _scrollView.bounces = NO;
        [self.chooseViewArray enumerateObjectsUsingBlock:^(UIView * subView, NSUInteger index, BOOL * _Nonnull stop) {
            CGRect frame = CGRectMake(SCREENWIDTH*index, 5, SCREENWIDTH, SCREENHEIGHT-LINEHEIGHT-(self.chooseButtonHeight)-64-5);
            subView.frame = frame;
            [_scrollView addSubview:subView];
        }];
        _scrollView.contentSize = CGSizeMake(SCREENWIDTH*self.chooseViewArray.count, 0);

        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIView *)lineView{
    if (nil == _lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.chooseButtonHeight), self.chooseButtonWidth, LINEHEIGHT)];
        _lineView.backgroundColor = [UIColor clearColor];
        UIView *colorLine = [[UIView alloc]initWithFrame:CGRectMake(_lineView.frame.size.width*0.25, 0, _lineView.frame.size.width*0.5, LINEHEIGHT)];
        colorLine.backgroundColor = [UIColor blueColor];
        [_lineView addSubview:colorLine];
    }
    return _lineView;
}

-(NSArray *)chooseButtonArray{
    if (nil == _chooseButtonArray) {
        _chooseButtonArray = [NSArray array];
    }
    return _chooseButtonArray;
}

-(NSArray *)chooseViewArray{
    if (nil == _chooseViewArray) {
        _chooseViewArray = [NSArray array];
    }
    return _chooseViewArray;
}
-(CGFloat)chooseButtonWidth{
    if (!_chooseButtonWidth) {
        _chooseButtonWidth = SCREENWIDTH * 0.5;
    }
    return _chooseButtonWidth;
}

-(CGFloat)chooseButtonHeight{
    if (!_chooseButtonHeight) {
        _chooseButtonHeight = CHOOSEBUTTONFEFAULTHEIGHT;
    }
    return _chooseButtonHeight;
}

@end
