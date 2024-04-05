//
//  UpdatesTableViewCell.h
//  UpdatesListView
//
//  Created by Tope on 10/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell
@property(nonatomic,retain )IBOutlet UIImageView *img;
@property(nonatomic,retain )IBOutlet UILabel *title;
@property(nonatomic,retain )IBOutlet UILabel *miles;
@property(nonatomic,retain )IBOutlet UITextView *details;
@property(nonatomic,retain )IBOutlet UIButton *favBtn;
@property(nonatomic,retain )IBOutlet UILabel *discount;
@property(nonatomic,retain)IBOutlet UILabel *expireLabel;




@property(nonatomic,retain)IBOutlet UIView *cellBackgroundView;

@property(nonatomic,retain )IBOutlet UIButton *reportbtn;
@property(nonatomic,retain )IBOutlet UIButton *imagesbtn;


@property (nonatomic,retain)IBOutlet UILabel *progress;
@property(nonatomic,retain )IBOutlet UIButton *deletebtn;
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView *av;

@property (weak, nonatomic) IBOutlet UILabel *emptyDate;
@property (weak, nonatomic) IBOutlet UILabel *emptyExaminar;
@property (weak, nonatomic) IBOutlet UILabel *emptyReferring;


@property(nonatomic,retain )IBOutlet UIImageView *favImg;
@property(nonatomic,retain )IBOutlet UIImageView *receiverImg;

@property(nonatomic,retain )IBOutlet UILabel *from;
@property(nonatomic,retain )IBOutlet UILabel *to;
@property(nonatomic,retain )IBOutlet UILabel *amount;


@end
