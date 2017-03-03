//
//  ViewController.m
//  CardScroll
//
//  Created by 付正 on 2017/3/3.
//  Copyright © 2017年 付正. All rights reserved.
//

#import "ViewController.h"
#import "CardScrollView.h"

/**
 *  color config
 */
#define GCUIColorFromRGB(rgbValue)                                                                 \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                           \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                              \
blue:((float)(rgbValue & 0xFF)) / 255.0                                       \
alpha:1.0]

#define kGCCardRatio 0.8
#define kGCCardWidth CGRectGetWidth(self.view.frame)*kGCCardRatio
#define kGCCardHeight kGCCardWidth/kGCCardRatio

@interface ViewController ()<CardScrollViewDelegate,CardScrollViewDataSource>

@property (nonatomic, strong) CardScrollView *cardScrollView;
@property (nonatomic, strong) NSMutableArray *cards;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = GCUIColorFromRGB(0xFF5050);
    
    self.cardScrollView = [[CardScrollView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-self.view.frame.size.width)/2, self.view.frame.size.width, self.view.frame.size.width)];
    self.cardScrollView.backgroundColor = [UIColor purpleColor];
    self.cardScrollView.cardDelegate = self;
    self.cardScrollView.cardDataSource = self;
    [self.view addSubview:self.cardScrollView];
    
    self.cards = [NSMutableArray array];
    for (NSInteger i = 0; i < 8; i++) {
        [self.cards addObject:@(i)];
    }
    
    [self.cardScrollView loadCard];
}

#pragma mark - CardScrollViewDelegate
- (void)updateCard:(UIImageView *)card withProgress:(CGFloat)progress direction:(CardMoveDirection)direction
{
    if (direction == CardMoveDirectionNone) {
        if (card.tag != [self.cardScrollView currentCard]) {
            CGFloat scale = 1 - 0.1 * progress;
            card.layer.transform = CATransform3DMakeScale(scale, scale, 1.0);
            card.layer.opacity = 1 - 0.2*progress;
        } else {
            card.layer.transform = CATransform3DIdentity;
            card.layer.opacity = 1;
        }
    } else {
        NSInteger transCardTag = direction == CardMoveDirectionLeft ? [self.cardScrollView currentCard] + 1 : [self.cardScrollView currentCard] - 1;
        if (card.tag != [self.cardScrollView currentCard] && card.tag == transCardTag) {
            card.layer.transform = CATransform3DMakeScale(0.9 + 0.1*progress, 0.9 + 0.1*progress, 1.0);
            card.layer.opacity = 0.8 + 0.2*progress;
        } else if (card.tag == [self.cardScrollView currentCard]) {
            card.layer.transform = CATransform3DMakeScale(1 - 0.1 * progress, 1 - 0.1 * progress, 1.0);
            card.layer.opacity = 1 - 0.2*progress;
        }
    }
}

#pragma mark - CardScrollViewDataSource
- (NSInteger)numberOfCards
{
    return self.cards.count;
}

- (UIImageView *)cardReuseView:(UIImageView *)reuseView atIndex:(NSInteger)index
{
    if (reuseView) {
        // you can set new style
        return reuseView;
    }
    
    UIImageView *card = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGCCardWidth * 0.8, kGCCardHeight)];
    card.layer.backgroundColor = [UIColor whiteColor].CGColor;
    card.layer.cornerRadius = 4;
    NSString *imgName = [NSString stringWithFormat:@"%ld.png",(long)index];
    card.image = [UIImage imageNamed:imgName];
    card.layer.masksToBounds = YES;
    
    return card;
}

#pragma mark --- 点击图片tag
- (void)cardClick:(NSInteger)index
{
    NSLog(@"第%ld张图",(long)index+1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
