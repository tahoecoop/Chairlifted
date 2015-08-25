//
//  DashboardViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "GroupsViewController.h"
#import "NetworkRequests.h"
#import "GroupCustomTableViewCell.h"
#import "NSDate+TimePassage.h"
#import "JoinGroup.h"
#import "GroupFeedViewController.h"
#import "SearchViewController.h"

@interface GroupsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *myGroups;
@property (nonatomic) NSMutableArray *allGroups;
@property (nonatomic) NSMutableArray *pendingGroups;
@property (nonatomic) int groupSkipCount;
@property (nonatomic) int mySkipCount;

@end

@implementation GroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mySkipCount = 0;
    self.groupSkipCount = 0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [NetworkRequests getMyGroupsWithSkipCount:self.mySkipCount andCompletion:^(NSArray *array)
    {
        self.myGroups = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.segControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (IBAction)onSegControlToggle:(UISegmentedControl *)sender
{
    self.myGroups = nil;
    self.allGroups = nil;
    
    if (self.segControl.selectedSegmentIndex == 0)
    {
        if (!self.myGroups.count > 0)
        {
            self.mySkipCount = 0;
            [NetworkRequests getMyGroupsWithSkipCount:self.mySkipCount andCompletion:^(NSArray *array)
             {
                 self.myGroups = [NSMutableArray arrayWithArray:array];
                 [self.tableView reloadData];
             }];
        }
        [self.tableView reloadData];
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        if (!self.allGroups.count > 0)
        {
            self.groupSkipCount = 0;
            [NetworkRequests getAllGroupsWithSkipCount:self.groupSkipCount andCompletion:^(NSArray *array)
             {
                 self.allGroups = [NSMutableArray arrayWithArray:array];
                 [self.tableView reloadData];
             }];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
}



#pragma mark - table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segControl.selectedSegmentIndex == 0)
    {
        return self.myGroups.count;
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        return self.allGroups.count;
    }
    else
    {
        return 0;
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    JoinGroup *joinGroup;
    Group *group;

    if (self.segControl.selectedSegmentIndex == 0)
    {
        joinGroup = self.myGroups[indexPath.row];
        group = joinGroup.group;
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        group = self.allGroups[indexPath.row];
    }

    cell.groupNameLabel.text = group.name;
    cell.memberQuantityLabel.text = [NSString stringWithFormat:@"%i members", group.memberQuantity];
    cell.lastUpdatedLabel.text = [NSDate determineTimePassed:group.mostRecentPost];
    if ([group.isPrivate boolValue])
    {
        cell.privateImageView.hidden = NO;
    }
    else
    {
        cell.privateImageView.hidden = YES;
    }
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupFeedSegue"])
    {
        GroupFeedViewController *vc = segue.destinationViewController;

        if (self.segControl.selectedSegmentIndex == 0)
        {
            JoinGroup *joinGroup = self.myGroups[self.tableView.indexPathForSelectedRow.row];
            vc.group = joinGroup.group;
            vc.joinGroup = joinGroup;
        }
        else if (self.segControl.selectedSegmentIndex == 1)
        {
            vc.group = self.allGroups[self.tableView.indexPathForSelectedRow.row];
        }
    }
    else if ([segue.identifier isEqualToString:@"CreateGroupSegue"])
    {
        CreateGroupViewController *vc = (CreateGroupViewController *)[segue.destinationViewController topViewController];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ToGroupSearch"])
    {
        SearchViewController *vc = segue.destinationViewController;
        vc.isGroup = YES;
    }
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

    if (self.segControl.selectedSegmentIndex == 0)
    {
        if (indexPath.row == self.mySkipCount - 5)
        {
            [NetworkRequests getMyGroupsWithSkipCount:self.mySkipCount andCompletion:^(NSArray *array)
             {
                 [self.myGroups addObjectsFromArray:array];
                 self.mySkipCount = self.mySkipCount + 30;
                 [self.tableView reloadData];
             }];
        }
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        if (indexPath.row == self.groupSkipCount - 5)
        {
            [NetworkRequests getAllGroupsWithSkipCount:self.groupSkipCount andCompletion:^(NSArray *array)
             {
                 [self.allGroups addObjectsFromArray:array];
                 self.groupSkipCount = self.groupSkipCount + 30;
                 [self.tableView reloadData];
             }];
        }
    }
}


-(void)didFinishSaving
{
    [self.segControl sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
