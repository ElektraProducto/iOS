//
//  UserDetailCell.m
//  Affinitas
//
//  Created by OnurMac on 11/11/15.
//  Copyright © 2015 Onur Unal. All rights reserved.
//

#import "UserDetailCell.h"
#import "AFUserDetail.h"
#import "AFUserDetailRoot.h"
#import "UserDetailGaleryCell.h"
#import "UserImageViewController.h"
#import "AFProduct.h"

#define K_CELL          @"UserDetailCell"
#define K_CELL_GALERY   @"UserDetailGaleryCell"

BOOL segmentedHasChanged = NO;

@implementation UserDetailCell{
    NSArray <AFProduct *>*userImages;
}
- (instancetype)initWithCustom{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:K_CELL];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:K_CELL owner:self options:nil];
        self = nib[0];
    }
    return  self;
}

- (void)awakeFromNib {
    // Make it round
    //[super awakeFromNib];
    self.kUserImage.contentMode = UIViewContentModeScaleAspectFill;
    self.kUserImage.layer.cornerRadius =self.kUserImage.frame.size.height/2;
    self.kUserImage.layer.masksToBounds = YES;
    self.kUserImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kUserImage.layer.borderWidth=2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataDetail00:(AFUsers*)detail{
    DKLog(K_VERBOSE_MOBILE_API_JSON, @"User Detail --> {%@}",detail);
    [self.collectionView registerClass:[UserDetailGaleryCell class] forCellWithReuseIdentifier:K_CELL_GALERY];
    userImages = [detail valueForKey:@"products"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self setValueForCell:detail];
}

- (void)setDataDetail01:(AFUsers*)detail{
    DKLog(K_VERBOSE_MOBILE_API_JSON, @"User Detail --> {%@}",detail);
    [self.collectionView registerClass:[UserDetailGaleryCell class] forCellWithReuseIdentifier:K_CELL_GALERY];
    userImages = [detail valueForKey:@"recommendedProducts"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self setValueForCell:detail];
    if (detail.isTech == FALSE) {
        [self.kJobTitle setTextColor:[UIColor darkGrayColor]];
        [self.collectionView setHidden:TRUE];
    }else{
        [self.kJobTitle setTextColor:[UIColor greenColor]];
        [self.collectionView setHidden:FALSE];
    }
    
    if ([detail.phone isEqualToString:@""] || detail.phone == NULL) {
        [self.productSegmentedControl removeSegmentAtIndex:0 animated:FALSE];
        [self.productSegmentedControl setSelectedSegmentIndex:0];
    }
}

-(void)setValueForCell:(AFUsers*)detail{
    self.kCityPostcode.text = [NSString stringWithFormat:@"%@",[detail valueForKey:JSON_ADDRESS]];
    self.kJobTitle.text = [NSString stringWithFormat:@"%@",[detail valueForKey:JSON_CITY]];
    self.KSmokeUser.text = [NSString stringWithFormat:@"%@",[detail valueForKey:JSON_SMOKER]];
    self.kWishForChildren.text = [NSString stringWithFormat:@"%@",[detail valueForKey:JSON_CREDIT]];
    self.kFirstNameAge.text = [NSString stringWithFormat:@"%@, %@",[detail valueForKey:JSON_FIRSTNAME], [detail valueForKey:JSON_AGE]];
    [self.kUserImage sd_setImageWithURL:[self replaceURL:[detail valueForKey:@"image_url"]]];
    [self.collectionView reloadData];
    if (detail.isTech == FALSE) {
        [self.kJobTitle setTextColor:[UIColor darkGrayColor]];
        [self.collectionView setHidden:TRUE];
        [self.btnSendBudget setHidden:TRUE];
        [self.productSegmentedControl setHidden:TRUE];
    }else{
        [self.kJobTitle setTextColor:[UIColor greenColor]];
        [self.collectionView setHidden:FALSE];
        [self.btnSendBudget setHidden:FALSE];
        [self.productSegmentedControl setHidden:FALSE];
    }
    
    if ([detail.phone isEqualToString:@""] || detail.phone == NULL) {
        [self.productSegmentedControl removeSegmentAtIndex:0 animated:FALSE];
        [self.productSegmentedControl setSelectedSegmentIndex:0];
    }
}


-(NSURL*)replaceURL:(NSString*)url{
    return [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"/profiles.php" withString:@""]];
}

-(NSString*)isFlag:(BOOL)flag{
    if (flag) {
        return @"Yes";
    }else{return @"No";}
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return userImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserDetailGaleryCell *cell = (UserDetailGaleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:K_CELL_GALERY forIndexPath:indexPath];
    [cell.kThumbImage sd_setImageWithURL:[self replaceURL:(NSString*)userImages[indexPath.row].foto]];
    cell.lblTitle.text = [[NSString alloc] initWithFormat:@"%@ \n%@",userImages[indexPath.row].precio, userImages[indexPath.row].nombre ];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate didImageGaleryClicked:[self replaceURL:(NSString*)userImages[indexPath.row].foto]];
}

- (IBAction)segmentedControlTap:(UISegmentedControl *)sender {
    [self.delegate didTappedSegmentedControl:!segmentedHasChanged];
}

- (IBAction)sendBudget:(UIButton *)sender {
    [self.delegate sendBudget];
}


@end
