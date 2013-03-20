
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ViewController
{
    IBOutlet UIActivityIndicatorView *indicator;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}

- (void)connectAndRetry:(NSURL *)url queue:(NSOperationQueue *)queue completion:(void(^)(NSData *data))completion
{
    completion = [completion copy];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
    {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)r;
        if(e == nil && response.statusCode == 200)
        {
            //成功
            if(completion)
                completion(d);
        }
        else
        {
            //失敗 リトライ ３秒後
            NSLog(@"retry 3 seconds after");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:3.0];
                
                [queue addOperationWithBlock:^{
                    NSLog(@"retry");
                    [self connectAndRetry:url queue:queue completion:completion];
                }];
            });
        }
    }];
}

- (IBAction)buttonPush:(UIButton *)sender
{
    [indicator startAnimating];
    sender.enabled = NO;
    sender.alpha = 0.5;
    
    [self connectAndRetry:[NSURL URLWithString:@"http://google.co.jp"]
                    queue:[NSOperationQueue mainQueue]
               completion:^(NSData *data)
     {
         NSLog(@"done");
         sender.enabled = YES;
         sender.alpha = 1.0;
         [indicator stopAnimating];
     }];
}
@end
