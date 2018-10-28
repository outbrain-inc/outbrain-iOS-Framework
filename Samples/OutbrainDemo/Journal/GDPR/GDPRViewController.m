//
//  GDPRViewController.m
//  CMPConsentToolDemoApp
//

#import "GDPRViewController.h"
//#import "CMPConsentToolAPI.h"
#import "CMPConsentToolViewController.h"

@interface GDPRViewController () <CMPConsentToolViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *GDPRConsentStringLabel;

@property (weak, nonatomic) IBOutlet UILabel *GDPRCmpPresentLabel;

@property (weak, nonatomic) IBOutlet UILabel *GDPRSubjectToGDPRLabel;

@property (weak, nonatomic) IBOutlet UILabel *GDPRPurposesLabel;

@property (weak, nonatomic) IBOutlet UILabel *GDPRVendorsLabel;

@property (weak, nonatomic) IBOutlet UILabel *GDPROutbrainVendorLabel;

@end

@implementation GDPRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showGDPR:(id)sender {
    CMPConsentToolViewController *consentToolVC = [[CMPConsentToolViewController alloc] init];
    consentToolVC.consentToolURL = [NSURL URLWithString: @"https://demofiles.smaato.com/cmp/index.html"];
    consentToolVC.consentToolAPI.subjectToGDPR = SubjectToGDPR_Yes;
    consentToolVC.consentToolAPI.cmpPresent = YES;
    consentToolVC.delegate = self;
    [self presentViewController:consentToolVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark CMPConsentToolViewController delegate
-(void)consentToolViewController:(CMPConsentToolViewController *)consentToolViewController didReceiveConsentString:(NSString *)consentString {
    [consentToolViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.GDPRConsentStringLabel.text = consentString;
    
    self.GDPRCmpPresentLabel.text = consentToolViewController.consentToolAPI.cmpPresent ? @"YES" : @"NO";
    
    self.GDPRSubjectToGDPRLabel.text = consentToolViewController.consentToolAPI.subjectToGDPR == SubjectToGDPR_Yes ? @"YES" : @"NO";
    
    self.GDPRPurposesLabel.text = consentToolViewController.consentToolAPI.parsedPurposeConsents;
    
    self.GDPRVendorsLabel.text = consentToolViewController.consentToolAPI.parsedVendorConsents;
    
    int vendorId = 164;
    BOOL vendorConsent = [consentToolViewController.consentToolAPI isVendorConsentGivenFor:vendorId];
    self.GDPROutbrainVendorLabel.text = vendorConsent ? @"YES" : @"NO";
}
@end
