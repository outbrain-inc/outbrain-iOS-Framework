//#import "_Post.h"



extern const struct PostAttributes {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *isRecommendation;
	__unsafe_unretained NSString *order;
	__unsafe_unretained NSString *post_id;
	__unsafe_unretained NSString *summary;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
    __unsafe_unretained NSString *imageURL;
} PostAttributes;


@interface Post : NSObject {}


@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSString* body;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, copy) NSString* post_id;
@property (nonatomic, copy) NSString* summary;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* url;

@property (nonatomic, copy) NSString * imageURL;    // If available

@property (nonatomic, assign) BOOL isRecommendation;


@property (nonatomic, copy, readonly) NSAttributedString * attributedTitleString;
@property (nonatomic, copy, readonly) NSAttributedString * attributedSummaryString;
@property (nonatomic, copy, readonly) NSAttributedString * attributedBodyString;



@end
