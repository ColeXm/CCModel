
#import "NSObject+CCModel.h"

@class Detail2;
@class Detail;
@class PicInfos;

@interface PicInfos : NSObject


@property (nonatomic, strong) Detail *ABC;
@property (nonatomic, strong) Detail *ABC2;


@end

@interface Detail : NSObject


@property (nonatomic, strong) Detail2 *thumbnail;
@property (nonatomic, strong) Detail2 *bmiddle;
@property (nonatomic, strong) Detail2 *large;
@property (nonatomic, strong) Detail2 *largest;
@property (nonatomic, strong) Detail2 *original;
@property (nonatomic, strong) Detail2 *middleplus;
@property (nonatomic, strong) NSString *pic_id;
@property (nonatomic, assign) int photo_tag;
@property (nonatomic, strong) NSString *filter_id;
@property (nonatomic, strong) NSString *object_id;


@end



@interface Detail2 : NSObject

@property (nonatomic, strong) NSString *cut_type;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, assign) NSInteger height;

@end


@interface Array : NSObject

@property (nonatomic, strong) NSString *list_id;
@property (nonatomic, strong) NSString *type;

@end

@interface CCGHUser : NSObject
@property (nonatomic, strong) NSString *login;
@property (nonatomic, assign) UInt64 id;
@property (nonatomic, strong) NSString *avatar_url;
@property (nonatomic, strong) NSString *gravatar_id;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *html_url;
@property (nonatomic, strong) NSString *followers_url;
@property (nonatomic, strong) NSString *following_url;
@property (nonatomic, strong) NSString *gists_url;
@property (nonatomic, strong) NSString *starred_url;
@property (nonatomic, strong) NSString *subscriptions_url;
@property (nonatomic, strong) NSString *organizations_url;
@property (nonatomic, strong) NSString *repos_url;
@property (nonatomic, strong) NSString *events_url;
@property (nonatomic, strong) NSString *received_events_url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL site_admin;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *blog;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *hireable;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, assign) UInt32 public_repos;
@property (nonatomic, assign) UInt32 public_gists;
@property (nonatomic, assign) UInt32 followers;
@property (nonatomic, assign) UInt32 following;

@property (nonatomic, strong) PicInfos *pic_infos;


@property (nonatomic, strong) NSMutableArray *Array;

@end


