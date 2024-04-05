//
//  SideView.m
//  MyPractice
//
//  Created by eph132 on 10/06/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "SideView.h"
#import "CategoryMenu.h"
#import "DetailCell.h"
#import "SectionInfo.h"


#define DEFAULT_ROW_HEIGHT 157
#define HEADER_HEIGHT 50


@interface SideView ()
-(void)openDrawer;
-(void)closeDrqwer;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, strong) NSMutableArray *sectionInfoArray;
@property (nonatomic, strong) NSArray *categoryList;
- (void) setCategoryArray;
@end

@implementation SideView
{
    
    NSArray *topItems;
    NSMutableArray *subItems; // array of arrays
    
    int currentExpandedIndex;
    UITableView *_tableView;
}

@synthesize categoryList = _categoryList;
@synthesize openSectionIndex;
@synthesize sectionInfoArray;

SideView *side;

NSArray *titleArray;
NSArray *imageArray;
NSArray *vcArray;


- (id)init
{
    side = [[[NSBundle mainBundle] loadNibNamed:@"SideView"
                                          owner:self
                                        options:nil]
            objectAtIndex:0];
    
    
    [side sizeToFit];
    
   /* if (IS_IPHONE_4_OR_LESS)
    {
        float widthNew = 62;
        float heightNew = 62;
        
        //self.scrollView.frame = CGRectMake(0, 72, widthNew, heigtNew);
        
        CGRect frm = _imgUser.frame;
        frm.size.width = widthNew;
        frm.size.height = heightNew;
        _imgUser.frame = frm;
    }*/
   
    [side.imgUser.layer setShadowColor:[UIColor blackColor].CGColor];
    [side.imgUser.layer setShadowOpacity:0.8];
    [side.imgUser.layer setShadowRadius:3.0];
    [side.imgUser.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    side.imgUser.layer.masksToBounds = YES;
    
    
    CGRect basketTopFrame = side.frame;
    
    basketTopFrame.origin.x = -320;
    
   // NSLog(@"Width:%f",basketTopFrame.size.width);
   //  NSLog(@"Width:%f",basketTopFrame.size.height);
    
    
    side.frame = basketTopFrame;
   
    
    _closeView.hidden=YES;
    
        [self openDrawer];
    
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    
    
    
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_gesView addGestureRecognizer:gestureRecognizer];

    
    
    [_menuTableView reloadData];
    
    
    return side;
    
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
    
    [self closeDrawer:nil];
}


- (void)configureWith:(id<customProtocol>)delegate{
    //Configure the delegate it will manage the events
    //from subviews like buttons and other controls
    self.delegate = delegate;
    //.. to configure any subView
}


- (void) awakeFromNib
{
    
    
   // [self setCategoryArray];
    //self.menuTableView.sectionHeaderHeight = 45;
   // self.menuTableView.sectionFooterHeight = 0;
   // self.openSectionIndex = NSNotFound;
    
    vcArray=[NSArray arrayWithObjects:@"HomeViewController",@"MyRidesViewController",@"MyWalletViewController",@"MyProfileViewController",@"TermsViewController",@"HelpViewController",@"Logout", nil];
    
    
    titleArray=[NSArray arrayWithObjects:@"Home",@"My Rides",@"My Wallet",@"My Profile",@"Terms & Conditions",@"Help",@"Logout", nil];
    
   // imageArray=[NSArray arrayWithObjects:@"icon_drawer_home", @"icon_drawer_booking", @"icon_drawer_history", @"icon_drawer_car", @"icon_drawer_partner", @"icon_drawer_account", @"icon_drawer_coupon", @"icon_drawer_help", @"icon_drawer_privacy", @"icon_drawer_terms", @"icon_drawer_logout", nil];
    
    
    
    NSData *data2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_DATA"];
    
    NSDictionary *getUserData=[NSKeyedUnarchiver unarchiveObjectWithData:data2];
    
    
    NSLog(@"Get Data:%@",getUserData);
    
    
    
    
    
    NSString *userName= [getUserData valueForKeyPath:@"user.name"];
    
    int genValue= [[getUserData valueForKeyPath:@"user.gender"]intValue];
    
    if(genValue==1)
    {
        _imgUser.image = [UIImage imageNamed:@"people2.jpg"];
    }
    else
    {
        _imgUser.image = [UIImage imageNamed:@"people2.jpg"];
    }
    
   // _lblName.text = [NSString stringWithFormat:@"HELLO %@",[userName uppercaseString]];
    
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    
        
    
    [super awakeFromNib];
    
}



- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    if (self = [super initWithFrame:rect])
    {
       
       
        
    }
    return self;
}





/*
- (id)initWithTitle:(NSString *)aTitle
            options:(NSArray *)aOptions
            handler:(void (^)(NSInteger anIndex))aHandlerBlock {
    
    
    
    
   
    
    if(self = [self initWithTitle:aTitle options:aOptions])
        self.handlerBlock = aHandlerBlock;
    
    return self;
}
 */

- (void)setUpTableView
{
}


#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    
    
    
 
    
  
    
    
    
    side = [[[NSBundle mainBundle] loadNibNamed:@"SideView"
                                         owner:self
                                       options:nil]
           objectAtIndex:0];
    
    CGRect basketTopFrame = side.frame;
    //basketTopFrame.origin.x = basketTopFrame.size.width;
    basketTopFrame.origin.x = -320;
    side.frame = basketTopFrame;
    
    //side.delegate = self;
    
    [aView addSubview: side];
    //side.hidden=YES;
    
    
    
    if (animated) {
        
        [self openDrawer];
    }
    
    [_menuTableView reloadData];
    
    
}

-(void)openDrawer
{
    side.hidden=NO;
    _closeView.hidden=YES;
    
    
    
    
    
    CGRect basketTopFrame = side.frame;
    //basketTopFrame.origin.x = basketTopFrame.size.width;
    basketTopFrame.origin.x = 0;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         side.frame = basketTopFrame;
                         // basketBottom.frame = basketBottomFrame;
                     }
                     completion:^(BOOL finished)
     {
         NSLog(@"Done! AAA");
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _closeView.hidden=NO;
         });
         
         
     }];
    
    
    
    

}



- (IBAction)closeDrawer:(id)sender {
    
    [_delegate didTapSomeButton:@"Close"];
    
    side.hidden=NO;
    _closeView.hidden=YES;
    CGRect basketTopFrame = side.frame;
    //basketTopFrame.origin.x = basketTopFrame.size.width;
    basketTopFrame.origin.x = -320;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         side.frame = basketTopFrame;
                         // basketBottom.frame = basketBottomFrame;
                     }
                     completion:^(BOOL finished)
     {
         NSLog(@"Done!");
         
         
         
         
         [self removeFromSuperview];
         
     }];

    
     
    
}




#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DetailCell * cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell1 == nil)
    {
        
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil];
        
        for (UIView *view in views)
        {
            if([view isKindOfClass:[UITableViewCell class]])
            {
                cell1 = (DetailCell*)view;
            }
        }
    }
    
    cell1.emptyDate.text=titleArray[indexPath.row];
   // cell1.img.image= [UIImage imageNamed:imageArray[indexPath.row]];
   
    return cell1;

    
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    //SectionInfo *array = [self.sectionInfoArray objectAtIndex:indexPath.section];
    //return [[array objectInRowHeightsAtIndex:indexPath.row] floatValue];
    
    
    return 60;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSLog(@"Index:%ld",(long)indexPath.row);
        
        [_delegate didTapSomeButton:vcArray[indexPath.row]];
   
    
    [self closeDrawer:nil];
    
    
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/

- (IBAction)clickProfile:(id)sender
{
    [_delegate didTapSomeButton: @"MyProfileViewController"];

    [self closeDrawer:nil];
}

- (IBAction)clickHome:(id)sender
{
    [_delegate didTapSomeButton: @"HomeViewController"];
    
    [self closeDrawer:nil];
}

- (IBAction)clickMyRides:(id)sender
{
    [_delegate didTapSomeButton: @"MyRidesViewController"];
    
    [self closeDrawer:nil];
}

- (IBAction)clickMyWallet:(id)sender
{
    [_delegate didTapSomeButton: @"MyWalletViewController"];
    
    [self closeDrawer:nil];
}

- (IBAction)clickHelp:(id)sender
{
    [_delegate didTapSomeButton: @"HelpViewController"];
    
    [self closeDrawer:nil];
}

- (IBAction)clickTerms:(id)sender
{
    [_delegate didTapSomeButton: @"TermsViewController"];
    
    [self closeDrawer:nil];
}

- (IBAction)clickLogout:(id)sender
{
    [_delegate didTapSomeButton: @"Logout"];
    
    [self closeDrawer:nil];
}

@end
