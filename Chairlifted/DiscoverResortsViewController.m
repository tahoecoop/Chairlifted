//
//  DiscoverResultsViewController.m
//  
//
//  Created by Eric Schofield on 27Aug//2015.
//
//

#import "DiscoverResortsViewController.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "User.h"
#import "NetworkRequests.h"
#import "TopicsFeedViewController.h"

@interface DiscoverResortsViewController ()

@property (nonatomic) NSArray *resorts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DiscoverResortsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];

    [NetworkRequests getResortsWithState:self.state andCompletion:^(NSArray *array)
     {
         self.resorts = array;
         [activityView removeFromSuperview];
         [self.tableView reloadData];
     }];

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resorts.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResortsCell"];

    Resort *resort = self.resorts[indexPath.row];
    cell.textLabel.text = resort.name;
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ResortToFeed"])
    {
        TopicsFeedViewController *vc = segue.destinationViewController;
        Resort *resort = self.resorts[self.tableView.indexPathForSelectedRow.row];
        vc.resort = resort;
    }
}

@end
