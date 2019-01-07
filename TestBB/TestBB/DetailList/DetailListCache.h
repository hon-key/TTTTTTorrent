#import <Foundation/Foundation.h>

@interface DetailListCache : NSObject

@property (nonatomic,copy,readonly) NSString *url;

+ (instancetype)cache:(NSString *)url;

- (NSString *)storeTorrent:(NSString *)path;
- (NSString *)storedTorrent;

- (void)storeImage:(NSString *)path forName:(NSString *)name;
- (NSString *)storedImageForName:(NSString *)name;

@end
