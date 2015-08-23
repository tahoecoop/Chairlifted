//
//  ChooseResortViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/22/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "ChooseResortViewController.h"
#import "EditProfileViewController.h"
#import "User.h"

@interface ChooseResortViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray *resorts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseResortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NetworkRequests getResortsWithState:self.state andCompletion:^(NSArray *array)
    {
        self.resorts = array;
        [self.tableView reloadData];
    }];
}


#pragma mark - table view

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resorts.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Resort *resort = self.resorts[indexPath.row];
    cell.textLabel.text = resort.name;
    User *user = [User currentUser];
    [user.favoriteResort fetchIfNeeded];
    
    if ([resort.name isEqualToString:user.favoriteResort.name] || [tableView indexPathForSelectedRow] == indexPath)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"unwind"])
    {
        EditProfileViewController *vc = segue.destinationViewController;
        Resort *resort = self.resorts[self.tableView.indexPathForSelectedRow.row];
        vc.selectedResort = resort;
    }
}


@end
