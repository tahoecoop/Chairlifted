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

@interface GroupsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *myGroups;
@property (nonatomic) NSMutableArray *allGroups;
@property (nonatomic) NSArray *pendingGroups;



@end

@implementation GroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NetworkRequests getMyGroupsWithCompletion:^(NSArray *array)
    {
        self.myGroups = array;
        [self.tableView reloadData];
    }];
}

- (IBAction)onSegControlToggle:(UISegmentedControl *)sender
{
    self.myGroups = nil;
    self.allGroups = nil;
    
    if (self.segControl.selectedSegmentIndex == 0)
    {
        if (!self.myGroups.count > 0)
        {
            [NetworkRequests getMyGroupsWithCompletion:^(NSArray *array)
             {
                 self.myGroups = array;
                 [self.tableView reloadData];
             }];
        }
        [self.tableView reloadData];
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        if (!self.allGroups.count > 0)
        {
            [NetworkRequests getAllGroupsWithCompletion:^(NSArray *array)
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

    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupFeedSegue"])
    {
        GroupFeedViewController *vc = segue.destinationViewController;
        JoinGroup *joinGroup;
        
        if (self.segControl.selectedSegmentIndex == 0)
        {
            joinGroup = self.myGroups[self.tableView.indexPathForSelectedRow.row];
            vc.group = joinGroup.group;

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
}

-(void)didFinishSaving
{
    [self.segControl sendActionsForControlEvents:UIControlEventValueChanged];
}




@end
