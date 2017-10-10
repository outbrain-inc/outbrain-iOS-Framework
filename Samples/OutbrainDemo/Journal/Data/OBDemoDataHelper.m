//
//  OBDemoDataHelper.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/27/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBDemoDataHelper.h"
#import "Post.h"

#import <CommonCrypto/CommonDigest.h>

NS_INLINE NSString * md5FromString(NSString * input) {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

/**
 *  Define our encoding keys here so we don't have to spell them out all the time
 **/
extern const struct OBDCodingKeys {
    __unsafe_unretained NSString * queueKey;
    __unsafe_unretained NSString * lastUpdateKey;
    __unsafe_unretained NSString * postsListKey;
} OBDCodingKeys;

const struct OBDCodingKeys OBDCodingKeys = {
    .queueKey                   = @"queueKey",
    .lastUpdateKey              = @"lastUpdateKey",
    .postsListKey               = @"postsListKey"
};

@interface OBDemoDataHelper() <NSCacheDelegate>
@property (nonatomic, strong) NSCache * imageCache;
@end

@implementation OBDemoDataHelper
{
    NSDate * _lastPostsUpdate;
}

#define LAST_POST_UPDATE_KEY    @"LAST_POST_UPDATE"
#define DEBUG_INDICATORS_KEY    @"debug_indicators"

#pragma mark - Shared Instance

+ (instancetype)defaultHelper
{
    static dispatch_once_t onceToken;
    static OBDemoDataHelper * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[OBDemoDataHelper alloc] init];
        if(![[NSUserDefaults standardUserDefaults] valueForKey:DEBUG_INDICATORS_KEY])
        { [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEBUG_INDICATORS_KEY]; }
    });
    return instance;
}

+ (BOOL)showsDebugIndicators
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEBUG_INDICATORS_KEY];
}

- (id)init
{
    if((self = [super init]))
    {
        _networkQueue = [[NSOperationQueue alloc] init];
        _lastPostsUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:LAST_POST_UPDATE_KEY];
        _posts = [NSMutableArray array];
        
        // 4Mb of in memory cache
        // 20MB of disk cache
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                             diskCapacity:20 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
        
        _imageCache = [[NSCache alloc] init];
        _imageCache.countLimit = 10;
        _imageCache.delegate = self;
    }
    return self;
}


#pragma mark - Coding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if(self)
    {
        _lastPostsUpdate = [aDecoder decodeObjectForKey:OBDCodingKeys.lastUpdateKey];
        _posts = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:OBDCodingKeys.postsListKey]];
        _networkQueue = [aDecoder decodeObjectForKey:OBDCodingKeys.queueKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_posts forKey:OBDCodingKeys.postsListKey];
    [aCoder encodeObject:_networkQueue forKey:OBDCodingKeys.queueKey];
    [aCoder encodeObject:_lastPostsUpdate forKey:OBDCodingKeys.lastUpdateKey];
}


#pragma mark - Methods

- (Post *)_postObjectWithData:(NSDictionary *)postData
{
    Post * post = [[self class] createPostWithPayload:postData];
    
    post.title = postData[@"title"];
    NSString * authorString = @"";
    
    // Author doesn't seem to be consistent.  Better make some checks
    if(postData[@"author"][@"first_name"] && postData[@"author"][@"last_name"])
    {
        authorString = [NSString stringWithFormat:@"%@ %@",postData[@"author"][@"first_name"],postData[@"author"][@"last_name"]];
    } else if(postData[@"author"][@"nickname"] && [postData[@"author"][@"nickname"] length] > 0) {
        authorString = postData[@"author"][@"nickname"];
    }
    
    post.author = authorString;
    
    // For the body and summary, we want to strip the html version of the Outbrain Widget
    post.body = [[self class] stringByStrippingHTMLOutbrainWidget:postData[@"content"]];
    post.summary = [[self class] stringByStrippingHTMLOutbrainWidget:postData[@"excerpt"]];
    
    
    // You should try to keep creation of dateFormatters to a minimum
    static NSDateFormatter * formatter = nil;
    if(!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-DD HH:mm:ss"];
    }
    post.date = [formatter dateFromString:postData[@"date"]];
    post.url = postData[@"url"];
    
    NSArray * attachments = postData[@"attachments"];
    
    if([attachments isKindOfClass:[NSArray class]] && attachments.count > 0)
    {
        id firstAttachment = attachments[0];
        if(firstAttachment[@"images"][@"large"][@"url"])
        {
            post.imageURL = firstAttachment[@"images"][@"large"][@"url"];
        }
    }
    
    return post;
}

- (void)updatePostsInViewController:(UIViewController *)vc withCallback:(void(^)(BOOL updated))callback
{
    // We don't want to refresh if less than 30 seconds
    if(_lastPostsUpdate && [[NSDate date] timeIntervalSinceDate:_lastPostsUpdate] < 30 && [self posts].count > 0)
    {
        if(!callback) return;
        return callback(NO);
    }
    
    // Update the date var so we can keep users from trying to aggressively update
    _lastPostsUpdate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:_lastPostsUpdate forKey:LAST_POST_UPDATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Show that we're doing stuff
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    typeof(self) __self = self;
    __block BOOL updated = NO;
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        void (^ShowErrorBlock)(NSString * title, NSString *message) = ^(NSString *title, NSString *message) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle: title
                                                      message: message
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okButton = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                            }];
                
                [alertController addAction:okButton];
                [vc presentViewController:alertController animated:YES completion:nil];
            });
            
        };
        // Our data parsing block
        void (^ParseData)(NSData *) = ^(NSData * data) {
            NSError * error = nil;
            NSDictionary * jsonPayload = [NSJSONSerialization JSONObjectWithData:data options:(0) error:&error];
            if (error || !jsonPayload)
            {
                // Something went horribly wrong.
                NSString * errorMessage = error ? [error userInfo][NSLocalizedDescriptionKey] : @"There was an error parsing the data response in `[OBDemoDataHelper startDataSyncing]`";
                ShowErrorBlock(@"Error",errorMessage);
                
            } else {
                // We have a valid jsonPayload with no errors.  Now let's turn that payload into valid Post objects for CoreData
                if(jsonPayload[@"posts"])
                {
                    [__self.posts removeAllObjects];
                    for(id postData in jsonPayload[@"posts"])
                    {
                        [__self.posts addObject:[self _postObjectWithData:postData]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        updated = YES;
                    });
                }
            }
        };
        
        
        // We're doing this synchronous because this is a sample app.  Yes it may be bad practice, but it fits our needs.
        NSString * urlString = [NSString stringWithFormat:@"%@?json=true",OBDemoURL];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
        NSHTTPURLResponse * response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        
        // Nothing changed.  Let's not do anything here
        if([response statusCode] == 302) return;
        
        if(data)
        {
            ParseData(data);
        }
        else
        {
            // No data retrieved.  (Usually means the connection timed out).
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Check if we have data saved
                if([[__self posts] count] == 0)
                {
                    // Only show this as an error if we don't have data saved already
                    ShowErrorBlock(@"Network Error",@"Couldn't contact the server.  Please check your connection and try again");
                }
            });
        }
    }];
    
    
    // Finally stop the networkIndicator and call the callback if available
    [blockOp setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(callback)
            {
                callback(updated);
            }
        });
    }];
    
    // Add op to the queue
    [self.networkQueue addOperation:blockOp];
}

- (void)fetchPostForURL:(NSURL *)url withCallback:(void (^)(id, NSError *))callback
{
    // First let's check if we already have this post in our list
    
    for(Post * p in self.posts)
    {
        if([p.url isEqualToString:url.absoluteString])
        {
            // Found the post already in our list
            return callback(p,nil);
        }
    }
    
    
    // Show that we're doing stuff
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    typeof(self) __weak __self = self;
    __block Post *post = nil;
    __block NSError * error;
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        // Our data parsing block
        void (^ParseData)(NSData *) = ^(NSData * data) {
            NSError * error = nil;
            NSDictionary * jsonPayload = [NSJSONSerialization JSONObjectWithData:data options:(0) error:&error];
            if(error || !jsonPayload)
            {
                // Something went horribly wrong.
                NSString * errorMessage = error ? [error userInfo][NSLocalizedDescriptionKey] : @"There was an error parsing the data response in `[OBDemoDataHelper startDataSyncing]`";
                
                error = [NSError errorWithDomain: @"Error" code:100 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                
            } else {
                // We have a valid jsonPayload with no errors.  Now let's turn that payload into valid Post objects for CoreData
                if(jsonPayload[@"post"] || jsonPayload[@"page"])
                {
                    post = [__self _postObjectWithData:jsonPayload[@"post"]?:jsonPayload[@"page"]];
                }
            }
        };
        
        
        // We're doing this synchronous because this is a sample app.  Yes it may be bad practice, but it fits our needs.
        NSString * urlString = [NSString stringWithFormat:@"%@?json=true",url.absoluteString];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
        NSHTTPURLResponse * response = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        
        // Nothing changed.  Let's not do anything here
        if([response statusCode] == 302) return;
        
        if(data)
        {
            ParseData(data);
        }
    }];
    
    
    // Finally stop the networkIndicator and call the callback if available
    [blockOp setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(callback)
            {
                callback(post, error);
            }
        });
    }];
    
    // Add op to the queue
    [self.networkQueue addOperation:blockOp];
}

- (void)_putImage:(UIImage *)image inCacheWithKey:(NSString *)cacheKey
{
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _putImage:image inCacheWithKey:cacheKey];
        });
    }
    
    [self.imageCache setObject:image forKey:cacheKey];
}

+ (void)fetchImageWithURL:(NSURL *)url withCallback:(void (^)(UIImage *))callback
{
    static dispatch_queue_t image_fetch_queue = nil;
    if(!image_fetch_queue)
    {
        image_fetch_queue = dispatch_queue_create("com.outbrain-journal.imageQueue", 0);
    }
    
    BOOL (^ReturnHandler)(UIImage *) = ^(UIImage *returnImage) {
        if(!returnImage) return NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(returnImage);
        });
        return YES;
    };
    
    __block UIImage * responseImage;
    NSString * key = md5FromString([url absoluteString]);
    
    // First let's check if the image is in our cache.
    responseImage = [[[self defaultHelper] imageCache] objectForKey:key];
    if(ReturnHandler(responseImage)) return;
    
    dispatch_async(image_fetch_queue, ^{
        // Next check if the image is on disk.  If it is then we'll go ahead and add it to the cache and return from the cache
        NSString * cachesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.objournal.images"];
        NSFileManager * fm = [[NSFileManager alloc] init];
        [fm createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * diskCachePath = [cachesDir stringByAppendingPathComponent:key];
        
        // We have this on disk.
        responseImage = [UIImage imageWithContentsOfFile:diskCachePath];
        if(!ReturnHandler(responseImage))
        {
            // Fetch the image
            NSData * d = [NSData dataWithContentsOfURL:url];
            if(d)
            {
                responseImage = [UIImage imageWithData:d];
                if(!ReturnHandler(responseImage)) return;
            }
        }
        
        if(responseImage)
        {
//            [[self defaultHelper] _putImage:responseImage inCacheWithKey:key];
        }
    });
}

+ (NSString *)_dateStringFromDate:(NSDate *)date
{
    // Next the date
    static NSDateFormatter * formatter = nil;
    if(!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d, yyyy hh:mm"];
    }
    return [formatter stringFromDate:date];
}

+ (NSAttributedString *)_buildArticleAttributedStringWithPost:(Post *)post
{
    NSString * postTitle = post.title;
    NSString * dateString = [self _dateStringFromDate:post.date];
    NSString * bodyString = [post.body stringByStrippingHTML];
    bodyString = [bodyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * articleString = [NSString stringWithFormat:@"%@\n%@\n%@%@", postTitle, dateString, post.imageURL?IMAGE_SPACING:@"", bodyString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.f;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = 15.f;
    paragraphStyle.paragraphSpacingBefore = 10.f;
    
    UIColor * lightGrayTextColor = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1.000];
    NSMutableAttributedString * articleAttributedString = [[NSMutableAttributedString alloc] initWithString:articleString attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:lightGrayTextColor}];
    
    [articleAttributedString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor blackColor]} range:[articleString rangeOfString:postTitle]];
    [articleAttributedString addAttributes:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:11]} range:[articleString rangeOfString:dateString]];
    [articleAttributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} range:[articleString rangeOfString:bodyString]];
    return articleAttributedString;
}

#pragma mark - Cache Evicting

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    
}

@end


@implementation OBDemoDataHelper (Parsing)

+ (NSString *)stringByStrippingHTMLOutbrainWidget:(NSString *)contentString
{
    NSString * obContentLocationID  =   @"<!-- OBSTART";
    if([contentString rangeOfString:obContentLocationID].location != NSNotFound)
    {
        NSString * newContentString = [contentString substringToIndex:[contentString rangeOfString:obContentLocationID].location];
        
        NSRange r;
        NSString *s = [newContentString copy];
        // Strip out the html tags
        while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        {
            s = [s stringByReplacingCharactersInRange:r withString:@""];
        }
        if([s rangeOfString:@"\n"].location == 0) {
            s = [s substringFromIndex:1];
        }
        return s;
//        return [s stringByReplacingOccurrencesOfString:@"\n" withString:@""];;
    }
    return contentString;
}

+ (Post *)createPostWithPayload:(NSDictionary *)postPayload
{
    Post * post = [[Post alloc] init];
    
    post.post_id = postPayload[@"post_id"];
    
    return post;
}

@end

@implementation NSString (HTML_Extensions)

- (NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}
@end
