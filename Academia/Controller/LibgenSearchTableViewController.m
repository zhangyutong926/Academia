//
//  LibgenSearchTableViewController.m
//  Academia
//
//  Created by Yutong Zhang on 2018/12/24.
//  Copyright © 2018 Yutong Zhang. All rights reserved.
//

#import "LibgenSearchTableViewController.h"
#import "Publication.h"
#import "Libgen.h"

@interface LibgenSearchTableViewController ()
@property (nonatomic, readonly) NSMutableArray/*<Publication *>*/ *pubs;
@property (nonatomic) int selectedPublicationIndex;
- (IBAction)searchButtonPressed;
@property (weak, nonatomic) IBOutlet UITextField *keywordTextview;
@end

@implementation LibgenSearchTableViewController

@synthesize pubs = _pubs;

- (NSMutableArray *)pubs {
    if (!_pubs) {
        _pubs = [[NSMutableArray alloc] init];
    }
    return _pubs;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSString *error;
    [self.pubs removeAllObjects];
    [self.pubs addObjectsFromArray:SearchForPublications(@"manifold", &error)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pubs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LibgenSearchCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"LibgenSearchCell"];
    }
    Publication *pub = self.pubs[indexPath.row];
    NSString *line1;
    if (pub.details[@"edition"] == nil || [pub.details[@"edition"] isEqualToString:@""]) {
        line1 = [NSString stringWithFormat:@"[%@][%@] %@", pub.id, pub.details[@"extension"], pub.details[@"title"]];
    } else {
        line1 = [NSString stringWithFormat:@"[%@][%@] %@ ed.%@", pub.id, pub.details[@"extension"], pub.details[@"title"], pub.details[@"edition"]];
    }
    NSString *line2 = [NSString stringWithFormat:@"by %@, published by %@ - %@", pub.details[@"author"], pub.details[@"publisher"], pub.details[@"isbn"]];
    cell.textLabel.text = line1;
    cell.detailTextLabel.text = line2;
    return cell;
}

- (void)searchButtonPressed {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Searching..." preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tintColor = UIColor.blackColor;
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [loadingIndicator startAnimating];
    [alert.view addSubview:loadingIndicator];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSString *keywords = self.keywordTextview.text;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *searchKeyword = [keywords stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *error;
        NSArray *pubs = SearchForPublications(searchKeyword, &error);
        if (error != nil && ![error isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
                [[[UIAlertView alloc] initWithTitle:@"Error During Search" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
            });
            return;
        }
        
        [self.pubs removeAllObjects];
        [self.pubs addObjectsFromArray:pubs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self.tableView reloadData];
        });
    });
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.selectedPublicationIndex = indexPath.row;
//    [self performSegueWithIdentifier:@"ShowPublicationDetailSegue" sender:self];
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
