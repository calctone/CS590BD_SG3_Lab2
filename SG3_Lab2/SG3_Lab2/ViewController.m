//
//  ViewController.m
//  SG3_Lab2
//
//  Created by Brandon on 6/17/15.
//  Copyright (c) 2015 Brandon. All rights reserved.
//
#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "STTwitterAPI.h"

#define BASE_URL "http://nlpservices.mybluemix.net/api/service"

@interface ViewController () {
    
}

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *tokens;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _responseTableView.delegate = self;
    _responseTableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * This is our new function that calls into the Twitter API to tweet the NLP Commands.
 */
- (void) tweetCommands {
    NSMutableString * result = [[NSMutableString alloc] init];
    for (NSObject * obj in _tokens)
    {
        [result appendString:[obj description]];
        [result appendString:@" "];
    }
    NSLog(@"The concatenated string is %@", result);
    
    NSString *apiKey = @"K5irO3T6OnBimYiLwKI1aDPv0";
    NSString *apiSecret = @"sswoK3Dgjpr17AAUaWlQyfLdFpA0ENEs11wDoCQ2ahghcAaZvu";
    NSString *oauthToken = @"3248175864-yiPSna2GQo0b3WHUSHPWeFl0kHjmb4zBPy648A4";
    NSString *oathSecret = @"ZAVqYA8UTavzk0gg9I1ksthmq404LZtsoXvpbFuLBHJwr";
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:apiKey consumerSecret:apiSecret oauthToken:oauthToken oauthTokenSecret:oathSecret];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        NSLog(@"Access granted with %@", bearerToken);
        
        [twitter postStatusUpdate:result
                inReplyToStatusID:nil
                         latitude:nil
                        longitude:nil
                          placeID:nil
               displayCoordinates:nil
                         trimUser:nil
                     successBlock:^(NSDictionary *status) {
                         NSLog(@"Success: %@", status);
                     } errorBlock:^(NSError *error) {
                         NSLog(@"Error: %@", error);
                     }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
    }];
}

- (IBAction)tappedOnTokenize:(id)sender {
    
    [_sentenceTextField resignFirstResponder];  //To hide the keyboard
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *sentense = [_sentenceTextField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *url = [NSString stringWithFormat:@"%s/chunks/%@", BASE_URL, sentense];
    
    NSLog(@"%@", url);
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        _tokens = [responseObject objectForKey:@"tokens"];
        _tags = [responseObject objectForKey:@"tags"];
        
        [self tweetCommands];
        
        [_responseTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];

}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tokens count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [_tokens objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [_tags objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Used to handle the tap on a Table view row.
}

@end
