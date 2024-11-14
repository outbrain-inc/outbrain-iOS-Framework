#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import <OutbrainSDK/OutbrainSDK.h>

@interface SFWebViewVC : UIViewController <UIScrollViewDelegate, SFWidgetDelegate>

@property (nonatomic, strong) NSString *widgetId;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet SFWidget *sfWidget;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sfWidgetHeightConstraint;

@end

@implementation SFWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetId = @"MB_1";
    
    // Test regular widget on the same page together with Bridge widget
    /*
    [Outbrain fetchRecommendationsWithRequest:[OBRequest requestWithURL:OBConf.baseURL widgetID:@"SDK_1"]
                                     callback:^(OBRecommendationResponse * _Nullable outbrainRes) {
        NSLog(@"outbrain response %@", outbrainRes.recommendations);
    }];
    */
    [self.sfWidget configureWith:self url:@"https://mobile-demo.outbrain.com" widgetId:self.widgetId widgetIndex:0 installationKey:@"NANOWDGT01" userId:nil darkMode:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.sfWidget viewWillTransitionTo:size with:coordinator];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.contentView.frame.size.height);
    }];
}

#pragma mark - SFWidgetDelegate

- (void)didChangeHeight {
    self.sfWidgetHeightConstraint.constant = [self.sfWidget getCurrentHeight];
}

- (void)onOrganicRecClick:(NSURL *)url {
    // Handle click on organic URL
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    [self.navigationController presentViewController:safariVC animated:YES completion:nil];
}

- (void)onRecClick:(NSURL *)url {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    [self.navigationController presentViewController:safariVC animated:YES completion:nil];
}

- (void)widgetEvent:(NSString *)eventName additionalData:(NSDictionary<NSString *,id> *)additionalData {
    NSLog(@"App received widgetEvent: **%@** with data: %@", eventName, additionalData);
}

@end
