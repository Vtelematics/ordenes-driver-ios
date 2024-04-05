//
//  SectionView.m
//  CustomTableTest
//
//  Created by Punit Sindhwani on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SectionView

@synthesize section;
@synthesize sectionTitle;
@synthesize discButton;
@synthesize delegate;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame WithTitle: (NSString *) title img:(NSString *)imageName  Section:(NSInteger)sectionNumber icon:(BOOL)show delegate: (id <SectionView>) Delegate
{
    self = [super initWithFrame:frame];
    if (self) {
   
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discButtonPressed:)];
        [self addGestureRecognizer:tapGesture];
        
        self.userInteractionEnabled = YES;

        self.section = sectionNumber;
        self.delegate = Delegate;

        CGRect LabelFrame = self.bounds;
        LabelFrame.size.width -= 50;
        CGRectInset(LabelFrame, 0.0, 5.0);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 4, 250, 30)];
        label.text = title;
        label.font = [UIFont fontWithName:@"Play-Bold" size:17];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = UITextAlignmentLeft;
        [self addSubview:label];
        self.sectionTitle = label;
        
        
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
        
        img.image=[UIImage imageNamed:imageName];
        
        img.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:img];
        
        
        CGRect buttonFrame = CGRectMake(LabelFrame.size.width+20, 13, 20, 20);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonFrame;
        
        
        if (show) {
            [button setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"arrow_open"] forState:UIControlStateSelected];
        }
        
        
        [button addTarget:self action:@selector(discButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.discButton = button;

        //static NSMutableArray *colors = nil;
        
        
        UILabel* SepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width,2)];
        SepLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        SepLabel.backgroundColor = [UIColor colorWithRed: 60.0/255.0 green:125.0/255.0 blue:250.0/255.0 alpha:1.0];
        //[self addSubview:SepLabel];
        
        [self.layer setBackgroundColor:([ [ UIColor clearColor ] CGColor ])];
        
       // [(CAGradientLayer *)self.layer setColors:colors];
       // [(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.48], [NSNumber numberWithFloat:1.0], nil]];
    }
    return self;
}

- (void) discButtonPressed : (id) sender
{
    [self toggleButtonPressed:TRUE];
}

- (void) toggleButtonPressed : (BOOL) flag
{
    self.discButton.selected = !self.discButton.selected;
    if(flag)
    {
        if (self.discButton.selected) 
        {
            if ([self.delegate respondsToSelector:@selector(sectionOpened:)]) 
            {
                [self.delegate sectionOpened:self.section];
            }
        } else
        {
            if ([self.delegate respondsToSelector:@selector(sectionClosed:)]) 
            {
                [self.delegate sectionClosed:self.section];
            }
        }
    }
}

@end
