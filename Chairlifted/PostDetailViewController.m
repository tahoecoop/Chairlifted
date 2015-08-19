//
//  PostDetailViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "PostDetailViewController.h"
#import "DetailHeaderTableViewCell.h"
#import "DetailPostImageTableViewCell.h"
#import "DetailPostTextOnlyTableViewCell.h"
#import "DetailActionTableViewCell.h"
#import "DetailCommentTableViewCell.h"



@interface PostDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PostDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;


}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [self.tableView reloadData];
//}

#pragma mark - Table View Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.post.comments.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.post.image)
        {
            DetailPostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImagePost"];

            return cell;
        }
        else
        {
            DetailPostTextOnlyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextPost"];

            return cell;
        }
    }
    else
    {
        DetailCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        return cell;
    }

}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        DetailHeaderTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        return header;
    }
    else
    {
        DetailActionTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"Action"];
        return header;
    }
}






@end
