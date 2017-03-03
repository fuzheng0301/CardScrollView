//
//  CardScrollView.h
//  GCCardViewController
//
//  Created by 付正 on 17/3/3.
//  Copyright © 2017年 付正. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CardMoveDirection) {
    CardMoveDirectionNone,
    CardMoveDirectionLeft,
    CardMoveDirectionRight
};

@protocol CardScrollViewDataSource <NSObject>

- (NSInteger)numberOfCards;
- (UIImageView *)cardReuseView:(UIImageView *)reuseView atIndex:(NSInteger)index;

@end

@protocol CardScrollViewDelegate <NSObject>

- (void)updateCard:(UIImageView *)card withProgress:(CGFloat)progress direction:(CardMoveDirection)direction;
- (void)cardClick:(NSInteger)index;

@end

@interface CardScrollView : UIView

@property (nonatomic, weak) id<CardScrollViewDataSource>cardDataSource;
@property (nonatomic, weak) id<CardScrollViewDelegate>cardDelegate;
@property (nonatomic, assign) BOOL canDeleteCard;

- (void)loadCard;
- (NSArray *)allCards;
- (NSInteger)currentCard;

@end
