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
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"
#import <AFNetworkReachabilityManager.h>
#import "UIAlertController+ErrorAlert.h"
#import "UIAlertController+SignInPrompt.h"

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
    self.mySkipCount = 30;
    self.groupSkipCount = 30;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}


-(void)viewWillAppear:(BOOL)animated
{
    if ([User currentUser])
    {
        if (!self.myGroups)
        {
            UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
            UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
            spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
            [activityView addSubview:spinnerImageView];
            [self.view addSubview:activityView];
            [spinnerImageView rotateLayerInfinite];

            [NetworkRequests getMyGroupsWithSkipCount:0 andCompletion:^(NSArray *array)
             {
                 self.myGroups = [NSMutableArray arrayWithArray:array];
                 [activityView removeFromSuperview];
                 [self.tableView reloadData];
             }];
        }
    }
    
    [self.segControl sendActionsForControlEvents:UIControlEventValueChanged];
}


-(void)viewDidAppear:(BOOL)animated
{
    if (![User currentUser])
    {
        UIAlertController *alert = [UIAlertController alertToSignInWithCompletion:^(BOOL signIn)
        {
            if (signIn)
            {
                [self performSegueWithIdentifier:@"loginBeforeGroups" sender:self];
            }
            else
            {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}


- (IBAction)onSegControlToggle:(UISegmentedControl *)sender
{
    if ([User currentUser])
    {
        if (self.segControl.selectedSegmentIndex == 0)
        {
            UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
            UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
            spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
            [activityView addSubview:spinnerImageView];
            [self.view addSubview:activityView];
            [spinnerImageView rotateLayerInfinite];


            [NetworkRequests getMyGroupsWithSkipCount:0 andCompletion:^(NSArray *array)
             {
                 self.myGroups = nil;
                 self.myGroups = [NSMutableArray arrayWithArray:array];
                 [activityView removeFromSuperview];
                 [self.tableView reloadData];
             }];
        }
        else if (self.segControl.selectedSegmentIndex == 1)
        {
            UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
            UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
            spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
            [activityView addSubview:spinnerImageView];
            [self.view addSubview:activityView];
            [spinnerImageView rotateLayerInfinite];

            [NetworkRequests getAllGroupsWithSkipCount:0 andCompletion:^(NSArray *array)
             {
                 self.allGroups = nil;
                 self.allGroups = [NSMutableArray arrayWithArray:array];
                 [activityView removeFromSuperview];
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

        for (JoinGroup *jg in self.myGroups)
        {
            if ([jg.group.name isEqualToString: group.name] && [jg.user.displayName isEqualToString:[User currentUser].displayName])
            {
                joinGroup = jg;
            }
        }
    }
    cell.groupNameLabel.text = group.name;
    cell.memberQuantityLabel.text = [NSString stringWithFormat:@"%i members", group.memberQuantity];
    cell.lastUpdatedLabel.text = [NSDate determineTimePassed:group.mostRecentPost];
    if ([group.isPrivate boolValue])
    {
        cell.lockImageView.hidden = NO;
    }
    else
    {
        cell.lockImageView.hidden = YES;
        cell.crownImageView.hidden = YES;
    }

    if (![joinGroup.status isEqualToString:@"admin"])
    {
        cell.crownImageView.hidden = YES;
    }
    else
    {
        cell.crownImageView.hidden = NO;
    }

    return cell;
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

- (IBAction)onCreateGroupButtonPressed:(UIBarButtonItem *)sender
{
    if (![User currentUser])
    {
        UIAlertController *alert = [UIAlertController alertToSignInWithCompletion:^(BOOL signIn)
        {
            if (signIn)
            {
                [self performSegueWithIdentifier:@"loginBeforeGroups" sender:self];
            }
            else
            {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"CreateGroupsSegue" sender:self];
    }

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
    else if ([segue.identifier isEqualToString:@"CreateGroupsSegue"])
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


-(void)didFinishSaving
{
    [self.segControl setSelectedSegmentIndex:0];
    [self.segControl sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
