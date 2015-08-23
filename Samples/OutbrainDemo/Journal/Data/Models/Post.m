#import "Post.h"



const struct PostAttributes PostAttributes = {
	.author = @"author",
	.body = @"body",
	.date = @"date",
	.isRecommendation = @"isRecommendation",
	.order = @"order",
	.post_id = @"post_id",
	.summary = @"summary",
	.title = @"title",
	.url = @"url",
    .imageURL = @"imageURL"
};


@interface Post ()
{
    NSAttributedString *_attributedSummaryString;
}
// Private interface goes here.

@end


@implementation Post
@synthesize attributedTitleString = _attributedTitleString;
@synthesize attributedSummaryString = _attributedSummaryString;
@synthesize attributedBodyString = _attributedBodyString;


- (UIColor *)bodyTextColor
{
    return UIColorFromRGB(0x777777);
}

// Custom logic goes here.
- (NSAttributedString *)attributedTitleString
{
    if(!_attributedTitleString)
    {
        NSDictionary * titleAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor]};
        NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:[self.title stringByReplacingOccurrencesOfString:@"\n\r" withString:@""] attributes:titleAttributes];
        _attributedTitleString = [attributedString copy];
    }
    return _attributedTitleString;
}

- (NSAttributedString *)attributedSummaryString
{
    if(!_attributedSummaryString)
    {
        NSDictionary * titleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[self bodyTextColor]};
        NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:[self.summary stringByReplacingOccurrencesOfString:@"\n" withString:@""] attributes:titleAttributes];
        _attributedSummaryString = [attributedString copy];
    }
    return _attributedSummaryString;
}

- (NSAttributedString *)attributedBodyString
{
    if(!_attributedBodyString)
    {
        NSDictionary * titleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[self bodyTextColor]};
        NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:[self.summary stringByReplacingOccurrencesOfString:@"\n" withString:@""] attributes:titleAttributes];
        _attributedBodyString = [attributedString copy];
    }
    return _attributedBodyString;
}


@end
