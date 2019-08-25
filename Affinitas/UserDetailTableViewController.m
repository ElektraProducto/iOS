//
//  UserDetailTableViewController.m
//  Affinitas
//
//  Created by OnurMac on 11/11/15.
//  Copyright © 2015 Onur Unal. All rights reserved.
//

#import "UserDetailTableViewController.h"
#import "AFUserDetailRoot.h"
#import "UserDetailCell.h"
#import "UserImageViewController.h"
#import <MessageUI/MessageUI.h>

#define K_USER_DETAIL_CELL                @"UserDetailCell"

@interface UserDetailTableViewController () <MFMessageComposeViewControllerDelegate>{
    UIStoryboard *sb;
}
@end

@implementation UserDetailTableViewController

BOOL isRecomendedProduct = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    sb = [UIStoryboard storyboardWithName:K_STORYBOARD bundle:[NSBundle mainBundle]];
    self.title = [self.userDetailList.data valueForKey:JSON_FIRSTNAME];
  }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  [[UIScreen mainScreen] bounds].size.height - 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:K_USER_DETAIL_CELL];
    if(!cell) {
        cell = [[UserDetailCell alloc] initWithCustom];
    }
    if (isRecomendedProduct) {
        [cell setDataDetail01:self.userDetailList.data];
    } else {
        [cell setDataDetail00:self.userDetailList.data];
    }
    cell.delegate = self;
    return  cell;
}

#pragma mark - UserDetailCell Delegate

-(void)didImageGaleryClicked:(NSURL *)imageURL{
    UserImageViewController *galleryView = [sb instantiateViewControllerWithIdentifier:K_IMAGE_SLIDER_ID];
    galleryView.sImage = imageURL;
    [self.navigationController pushViewController:galleryView animated:YES];
}

-(void)didTappedSegmentedControl:(BOOL*)isSelected{
    isRecomendedProduct = !isRecomendedProduct;
    [self.tableView reloadData];
}

- (void)sendBudget {
    if([MFMessageComposeViewController canSendText] && self.userDetailList.data.recommendedProducts != NULL) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init]; // Create message VC
        messageController.messageComposeDelegate = self; // Set delegate to current instance
        
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init]; // Create an array to hold the recipients
        [recipients addObject:self.userDetailList.data.phone]; // Append example phone number to array
        messageController.recipients = recipients; // Set the recipients of the message to the created array
        
        NSString *name = [[[[self.userDetailList data] recommendedProducts] firstObject] nombre];
        NSString *precio = [[[[self.userDetailList data] recommendedProducts] firstObject] precio];
        NSString *foto = [[[[self.userDetailList data] recommendedProducts] firstObject] foto];
        
        messageController.body = [[NSString alloc] initWithFormat:@"Recomendaciones para ti \n%@, \n%@, \n%@", name, precio, foto]; // Set initial text to example message
        
        dispatch_async(dispatch_get_main_queue(), ^{ // Present VC when possible
            [self presentViewController:messageController animated:YES completion:NULL];
        });
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
