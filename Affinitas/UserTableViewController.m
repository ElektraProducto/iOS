//
//  UserTableViewController.m
//  Affinitas
//
//  Created by OnurMac on 11/11/15.
//  Copyright © 2015 Onur Unal. All rights reserved.
//

#import "UserTableViewController.h"
#import "UserListCell.h"
#import "AFUsers.h"
#import "UserDetailTableViewController.h"

#define K_USER_CELL                @"UserListCell"

@interface UserTableViewController (){
    UserDetailTableViewController *detailData;
}
@end

@implementation UserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AFUserRoot *root = [[AFUserRoot alloc] init];
    root.success = true;
    self.ref = [[FIRDatabase database] reference];
    [[_ref child:@"users"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        NSMutableArray *myArray = [NSMutableArray array];
        for (FIRDataSnapshot *item in snapshot.children) {
            NSMutableArray <AFProduct *>*products = [NSMutableArray array];
            NSMutableArray <AFProduct *> *recommendedProducts = [NSMutableArray array];
            if (![item.value[@"ekt_id"]  isEqual: @"no"]) {
                AFUsers *user = [[AFUsers alloc] init];
                user._id = item.value[@"ekt_id"];
                user.fullName = item.value[@"full_name"];
                if (item.value[@"foto"] != nil) {
                    user.image_url = item.value[@"foto"];
                } else {
                    user.image_url = @"https://picsum.photos/id/778/200";
                }
                user.age = item.value[@"age"];
                user.segment = item.value[@"segment"];
                user.credit = item.value[@"times_seen"];
                user.total_images = item.value[@"spent"];
                user.onlineShopper = item.value[@"online_shopper"];
                user.address = item.value[@"address"];
                user.phone = item.value[@"phone"];
                user.mail = item.value[@"mail"];
                user.spent = item.value[@"spent"];
                for (NSDictionary *comprado in item.value[@"commprados"]) {
                    AFProduct *product = [[AFProduct alloc] init];
                    product.foto = comprado[@"foto"];
                    product.nombre = comprado[@"nombre"];
                    product.precio = comprado[@"precio"];
                    product.sku = comprado[@"sku"];
                    [products addObject:product];
                    
                }
                for (NSDictionary *recommendado in item.value[@"recommendado"]) {
                    AFProduct *product = [[AFProduct alloc] init];
                    product.foto = recommendado[@"foto"];
                    product.nombre = recommendado[@"nombre"];
                    product.precio = recommendado[@"precio"];
                    product.sku = recommendado[@"sku"];
                    [recommendedProducts addObject:product];
                }
                user.products = products;
                user.recommendedProducts = recommendedProducts;
                [myArray addObject:user];
                user.isTech = ((NSNumber *)item.value[@"is_tech"]).integerValue == 1;
            } else {
                AFUsers *user = [[AFUsers alloc] init];
                user.fullName = item.value[@"Brand"];
                user.age = @"";
                user.segment = [[NSString alloc] initWithFormat:@"Se conectó en: %@", item.value[@"Last_Network"]];
                user.credit = item.value[@"times_seen"];
                user.image_url = @"https://picsum.photos/id/778/200";
                user.isTech = ((NSNumber *)item.value[@"is_tech"]).integerValue == 1;

                [myArray addObject:user];
                
            
            }
        }
        root.data= myArray;
        self.userList = root;
        [self.tableView reloadData];
        if ([[[[[[UIApplication sharedApplication] keyWindow] rootViewController] childViewControllers] lastObject] class] == [UserDetailTableViewController class]) {
            UserDetailTableViewController *detail = (UserDetailTableViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController].childViewControllers.lastObject;
            for (AFUsers* user in self.userList.data) {
                if (user._id == detail.userId) {
                    AFUserDetailRoot *root = [[AFUserDetailRoot alloc] init];
                    root.success = true;
                    root.data = user;
                    detail.userDetailList = root;
                }
            }
            [[detail tableView] reloadData];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    //[self fetchData];
}

-(void)fetchData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[AFMobileApiManager sharedClient] getUserListWithCompletion:^(id response) {
            [self setData:response];
            
        } error:^(NSError *error) {
            NSLog(@"Err : %@",error.description);
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

-(void)setData:(AFUserRoot*)instance{
    self.userList = instance;
    [self.tableView reloadData];
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
    return self.userList.data.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:K_USER_CELL];
    if (!cell)
        cell = [[UserListCell alloc] initWithCustomNibAndController:self _user:self.userList.data[indexPath.row]];
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AFUserDetailRoot *root = [[AFUserDetailRoot alloc] init];
    root.success = true;
    root.data = self.userList.data[indexPath.row];
    [self segue:root];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 100);
    UIView *view = [[UIView alloc] initWithFrame:frame];

    [view setBackgroundColor:[[UIColor alloc] initWithRed:236.0/255.0 green:74.0/255.0 blue:96.0/255.0 alpha:1]];
    UILabel *labelCount = [[UILabel alloc] init];
    
    
    
    labelCount.text = [[NSString alloc] initWithFormat:@"Clientes en la Tienda \n %@",[@(self.userList.data.count) stringValue]];
    [labelCount setTextAlignment:NSTextAlignmentCenter];
    [labelCount setTextColor:[UIColor whiteColor]];
    labelCount.numberOfLines = 0;
    [labelCount setFont:[UIFont systemFontOfSize:20]];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[labelCount]];
    
    [stackView setAlignment:UIStackViewAlignmentCenter];
    [stackView setDistribution:UIStackViewDistributionFill];
    
    [view addSubview:stackView];
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    
    
    [[stackView.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:8] setActive:TRUE];
    [[stackView.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:8] setActive:TRUE];
    [[stackView.topAnchor constraintEqualToAnchor:view.topAnchor constant:8] setActive: TRUE];
    [[stackView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:8] setActive: TRUE];
    
    
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}

-(void)segue:(AFUserDetailRoot*)instance{
    detailData = [[UserDetailTableViewController alloc] init];
    detailData.userDetailList = instance;
    detailData.userId = instance.data._id;
    [self.navigationController pushViewController:detailData animated:YES];
}


@end
