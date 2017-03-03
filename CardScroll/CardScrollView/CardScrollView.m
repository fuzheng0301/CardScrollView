//
//  CardScrollView.m
//  GCCardViewController
//
//  Created by 付正 on 17/3/3.
//  Copyright © 2017年 付正. All rights reserved.
//

#import "CardScrollView.h"

#define kGCRatio 0.7
#define kGCViewWidth CGRectGetWidth(self.frame)
#define kGCViewHeight CGRectGetHeight(self.frame)
#define kGCScrollViewWidth kGCViewWidth*kGCRatio

@interface CardScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, readonly)UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, assign) NSInteger totalNumberOfCards;
@property (nonatomic, assign) NSInteger startCardIndex;
@property (nonatomic, assign) NSInteger currentCardIndex;

@end

@implementation CardScrollView

#pragma mark - initialize

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kGCScrollViewWidth, kGCViewHeight)];
    self.scrollView.center = CGPointMake(self.center.x, self.frame.size.height/2);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self addSubview:self.scrollView];
    
    //设置分页
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, kGCViewHeight-30, kGCViewWidth, 30)];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.pageIndicatorTintColor = [UIColor orangeColor];
    _pageControl.currentPage = 0;//设置当前分页
    [self addSubview:_pageControl];
    
    self.cards = [NSMutableArray array];
    self.startCardIndex = 0;
    self.currentCardIndex = 0;
    self.canDeleteCard = YES;
}

#pragma mark - public methods
- (void)loadCard
{
    for (UIImageView *card in self.cards) {
        [card removeFromSuperview];
    }
    
    self.totalNumberOfCards = [self.cardDataSource numberOfCards];
    if (self.totalNumberOfCards == 0) {
        return;
    }
    
    [self.scrollView setContentSize:CGSizeMake(kGCScrollViewWidth*self.totalNumberOfCards, kGCViewHeight)];
    [self.scrollView setContentOffset:[self contentOffsetWithIndex:0]];
    
    for (NSInteger index = 0; index < self.totalNumberOfCards; index++) {
        UIImageView *card = [self.cardDataSource cardReuseView:nil atIndex:index];
        card.center = [self centerForCardWithIndex:index];
        card.tag = index;
        card.userInteractionEnabled = YES;
        [self.scrollView addSubview:card];
        [self.cards addObject:card];
        
        //添加点击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress:)];
        [card addGestureRecognizer:singleTap];
        
        [self.cardDelegate updateCard:card withProgress:1 direction:CardMoveDirectionNone];
    }
    //设置底部
    _pageControl.numberOfPages = self.cards.count;
}

- (NSArray *)allCards
{
    return self.cards;
}

- (NSInteger)currentCard
{
    return self.currentCardIndex;
}

#pragma mark - private methods

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [self.scrollView setContentOffset:[self contentOffsetWithIndex:index] animated:animated];
}

- (CGPoint)centerForCardWithIndex:(NSInteger)index
{
    return CGPointMake(kGCScrollViewWidth*(index + 0.5), self.scrollView.center.y);
}

- (CGPoint)contentOffsetWithIndex:(NSInteger)index
{
    return CGPointMake(kGCScrollViewWidth*index, 0);
}

#pragma mark --- 点击某个图片
-(void)buttonpress:(UIGestureRecognizer *)singleTap
{
    [self.cardDelegate cardClick:singleTap.view.tag];
}

- (void)ascendingSortCards
{
    [self.cards sortUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
        return obj1.tag > obj2.tag;
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translatedPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
        if (fabs(translatedPoint.y) > fabs(translatedPoint.x)) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat orginContentOffset = self.currentCardIndex*kGCScrollViewWidth;
    CGFloat diff = scrollView.contentOffset.x - orginContentOffset;
    CGFloat progress = fabs(diff)/(kGCViewWidth*0.7);
    CardMoveDirection direction = diff > 0 ? CardMoveDirectionLeft : CardMoveDirectionRight;
    
    for (UIImageView *card in self.cards) {
        [self.cardDelegate updateCard:card withProgress:progress direction:direction];
    }
    
    if (fabs(diff) >= kGCScrollViewWidth*0.7) {
        self.currentCardIndex = direction == CardMoveDirectionLeft ? self.currentCardIndex + 1 : self.currentCardIndex - 1;
        
        BOOL isLeft = direction == CardMoveDirectionLeft;
        if (isLeft) {
            _pageControl.currentPage ++;
        } else {
            _pageControl.currentPage --;
        }
    }
}

@end
