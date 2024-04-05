//
//  UpdatesTableViewCell.m
//  UpdatesListView
//
//  Created by Tope on 10/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell
//@synthesize startfrom,category,title;
@synthesize av;
//@synthesize distance;
@synthesize title;
@synthesize details;
@synthesize miles;
@synthesize favImg;
@synthesize img;
@synthesize discount;


@synthesize progress;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        _cellBackgroundView.layer.shadowOpacity = 1.0;
        _cellBackgroundView.layer.shadowRadius = 1.0;
        _cellBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _cellBackgroundView.layer.shadowOffset = CGSizeMake(0, 1);
        _cellBackgroundView.layer.cornerRadius = 10.0;
    }
    
   // [av startAnimating];
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
