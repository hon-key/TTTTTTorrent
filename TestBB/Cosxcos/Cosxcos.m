#import "Cosxcos.h"
#import "OCGumbo+Query.h"

#define COSXCOS_BASE_URL @"https://bt.cosxcos.net/"
#define COSXCOS_PAGE_COMP @"simple/page/"

@interface Cosxcos ()

@end

@implementation Cosxcos

@end

@implementation Cosxcos (Root)
+ (NSDictionary<NSString *,NSNumber *> *)attributeForRow {
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{@"置顶":@(CosxcosRowAttrTop),
                 @"百度":@(CosxcosRowAttrBaidu),
                 @"种子":@(CosxcosRowAttrTorrent),
                 @"热门":@(CosxcosRowAttrHot),
                 @"磁力":@(CosxcosRowAttrMagnet),
                 @"电驴":@(CosxcosRowAttrEd2k),
                 };
    });
    return dict;
}
+ (void)loadPage:(int)index complete:(void (^)(NSArray<CosxcosRow *> *))complete {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%d",COSXCOS_BASE_URL,COSXCOS_PAGE_COMP,index]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil);
            });
        }else {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:html];
            OCGumboElement *table = document.body.Query(@"table.table")[0];
            OCGumboElement *tbody = table.Query(@"tbody")[0];
            OCQueryObject *tRows = tbody.Query(@"tr");
            NSMutableArray *tRowsM = [tRows mutableCopy];
            [tRowsM removeObject:[tRows firstObject]];
            if (complete) {
                NSArray *result = [self handleTRows:tRowsM];
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(result);
                });
            }
        }
        
    }];
    
    [dataTask resume];
    
}
+ (NSArray *)handleTRows:(NSArray<OCGumboElement *> *)tRows {
    
    NSMutableArray *cosxcosRows = [NSMutableArray new];
    for (OCGumboElement *tRow in tRows) {
        CosxcosRow *cRow = [[CosxcosRow alloc] init];
        OCGumboElement *td = tRow.Query(@"td")[1];
        for (OCGumboElement *a in td.Query(@"a")) {
            NSString *text = [a.text() stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSNumber *attr = [[self attributeForRow] objectForKey:text];
            if (attr) {
                cRow.attr = cRow.attr | attr.unsignedIntegerValue;
            }else {
                if ([a hasAttribute:@"title"]) {
                    cRow.title = [a getAttribute:@"title"];
                }
                if ([a hasAttribute:@"href"]) {
                    cRow.url = [a getAttribute:@"href"];
                }
            }
        }
        [cosxcosRows addObject:cRow];
    }
    return cosxcosRows;
}
@end

@implementation Cosxcos (Detail)
+ (void)loadDetail:(NSString *)url complete:(void (^)(CosxcosDetail *))complete {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil);
            });
        }else {
            CosxcosDetail *detail = [[CosxcosDetail alloc] init];
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:html];
            
            NSArray *raws = document.Query(@"div.hero-unit").textArray();
            NSMutableArray *contents = [NSMutableArray new];
            for (NSString *content in raws) {
                NSString *newContent = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [contents addObject:newContent];
            }
            
            NSMutableArray *imgs = [NSMutableArray new];
            OCGumboElement *heroUnit = document.Query(@"div.hero-unit")[0];
            for (OCGumboNode *node in heroUnit.childNodes) {
                if ([node isKindOfClass:[OCGumboElement class]] &&
                    ((OCGumboElement *)node).tag == GUMBO_TAG_IMG) {
                    [imgs addObject:[((OCGumboElement *)node) getAttribute:@"src"]];
                }
            }
            
            NSString *torrentUrl = [document.Query(@"a.d-down")[0] getAttribute:@"href"];
            if ([torrentUrl hasPrefix:@"magnet:?"]) detail.magnet = torrentUrl;
            else detail.torrentUrl = torrentUrl;
            detail.contents = contents;
            detail.imageUrls = imgs;
            detail.url = url;
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(detail);
            });
        }
    }];
    [dataTask resume];
}

+ (void)downloadTorrent:(NSString *)url asName:(NSString *)name complete:(void (^)(NSString *))complete {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil);
            });
        }else {
            NSURL *toUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@.torrent",NSTemporaryDirectory(),name?:[[NSUUID UUID] UUIDString]]];
            NSError *error = nil;
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:toUrl error:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil);
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(toUrl.relativePath);
                });
            }
        }
    }];
    [downloadTask resume];
}

@end

@implementation CosxcosRow

@end

@implementation CosxcosDetail
@end
