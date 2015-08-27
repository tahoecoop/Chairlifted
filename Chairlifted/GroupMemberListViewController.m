//
//  GroupMemberListViewController.m
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import "GroupMemberListViewController.h"
#import "GroupMemberRespondRequestCellTableViewCell.h"
#import "NetworkRequests.h"

@interface GroupMemberListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *members;
@property (nonatomic) NSMutableArray *pendingMembers;
@property (nonatomic) int skipCount;

@end

@implementation GroupMemberListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self getInfo];
}

-(void)getInfo
{
    [NetworkRequests getPendingUsersInGroup:self.group andSkipCount:self.skipCount withCompletion:^(NSArray *array)
     {
         self.pendingMembers = [NSMutableArray arrayWithArray:array];
         [NetworkRequests getJoinedUsersInGroup:self.group andSkipCount:self.skipCount withCompletion:^(NSArray *arrayTwo)
          {
              self.members = [NSMutableArray arrayWithArray:arrayTwo];
              [self.tableView reloadData];
          }];
     }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.joinGroup.status isEqualToString:@"admin"])
    {
        return 2;
    }
    else
    {
        return 1;
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && [self.joinGroup.status isEqualToString:@"admin"])
    {
        if (!self.pendingMembers.count > 0)
        {
            return 1;
        }
        else
        {
            return  self.pendingMembers.count;
        }
    }
    else if (section == 1 || (![self.joinGroup.status isEqualToString:@"admin"] && section == 0))
    {
        if (!self.members.count > 0)
        {
            return 1;
        }
        else
        {
            return  self.members.count;
        }
    }
    else
    {
        return 0;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [self.joinGroup.status isEqualToString:@"admin"])
    {
        if (self.pendingMembers.count == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
            cell.textLabel.text = @"No pending requests";
            return cell;
        }
        else
        {
            GroupMemberRespondRequestCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupMemberCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;

            JoinGroup *joinGroup = self.pendingMembers[indexPath.row];
            cell.joinGroup = joinGroup;
            User *user = joinGroup.user;
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
             {
                 if (!error)
                 {
                     cell.usernameLabel.text = user.username;
                 }
             }];
            return cell;
        }
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (self.members.count == 0)
        {
            cell.textLabel.text = @"No pending requests";
        }
        else
        {
            JoinGroup *joinGroup = self.members[indexPath.row];
            User *user = joinGroup.user;
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject * object, NSError *error)
             {
                 cell.textLabel.text = user.username;
             }];
        }
        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && [self.joinGroup.status isEqualToString:@"admin"])
    {
        return @"Pending Group Requests";
    }
    else
    {
        return @"Current Members";
    }
}


-(void)buttonWasTapped
{
    [self getInfo];
}

@end