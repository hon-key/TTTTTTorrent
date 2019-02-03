#import "DetailListCache.h"

@interface DetailListCache ()
@property (nonatomic,copy) NSString *url;
@property (nonatomic,strong) NSMutableDictionary *caches;

@end

static NSLock *lock;

@implementation DetailListCache

+ (void)safetyConfigLock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSLock alloc] init];
    });
}

+ (instancetype)cache:(NSString *)url {
    static NSMutableDictionary<NSString *,DetailListCache *> *singletons;
    [lock lock];
    DetailListCache *singleton = singletons[url];
    if (!singleton) singleton = [[DetailListCache alloc] initWithUrl:url];
    [lock unlock];
    return singleton;
}

- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
        self.caches = [[[NSUserDefaults standardUserDefaults] objectForKey:url] mutableCopy] ?: [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (NSString *)storeTorrent:(NSString *)path {
    NSURL *from = [NSURL fileURLWithPath:path];
    NSString *toStr = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),path.lastPathComponent];
    NSURL *to = [NSURL fileURLWithPath:toStr];
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:from toURL:to error:&error];
    [lock lock];
    [self.caches setObject:path.lastPathComponent forKey:@"k_torrent"];
    [lock unlock];
    [self synchronize];
    return toStr;
}

- (NSString *)storedTorrent {
    [lock lock];
    NSString *filename = [self.caches objectForKey:@"k_torrent"];
    [lock unlock];
    if (!filename) return nil;
    NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),filename];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath] ? filePath : nil;
}

- (void)storeImage:(NSString *)path forName:(NSString *)name {
    [lock lock];
    [self.caches setObject:path forKey:name];
    [lock unlock];
    [self synchronize];
}

- (NSString *)storedImageForName:(NSString *)name {
    [lock lock];
    NSString *imgPath =[self.caches objectForKey:name];
    [lock unlock];
    return [[NSFileManager defaultManager] fileExistsAtPath:imgPath] ? imgPath : nil;
}

- (void)synchronize {
    [lock lock];
    [[NSUserDefaults standardUserDefaults] setObject:self.caches forKey:self.url];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [lock unlock];
}




@end
