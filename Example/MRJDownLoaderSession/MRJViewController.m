//
//  MRJViewController.m
//  MRJDownLoaderSession
//
//  Created by mrjlovetian@gmail.com on 07/18/2018.
//  Copyright (c) 2018 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJViewController.h"
#import "MRJDownLoaderSessionManager.h"

@interface MRJViewController ()
    @property (strong, nonatomic) IBOutlet UIProgressView *progressView;
    
@end

@implementation MRJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)start
{
    [[MRJDownLoaderSessionManager shareDownLoaderManager] downLoadWithUrl:[NSURL URLWithString:@"http://vodsphn1rqs.vod.126.net/vodsphn1rqs/CozhBPHn_1761895104_hd.mp4"] progress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    } complete:^(NSString *filePath) {
        NSLog(@"done download %@", filePath);
    } errorMsg:^(NSString *errorMsg) {
        
    }];
    // Dispose of any resources that can be recreated.
}
    
- (IBAction)pause {
    [[MRJDownLoaderSessionManager shareDownLoaderManager] pause:[NSURL URLWithString:@"http://vodsphn1rqs.vod.126.net/vodsphn1rqs/CozhBPHn_1761895104_hd.mp4"]];
}

@end
