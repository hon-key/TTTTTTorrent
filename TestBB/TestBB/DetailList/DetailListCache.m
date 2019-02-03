#import "DetailListCache.h"

static dispatch_semaphore_t sem;
#define LOCK(sem) dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
#define UNLOCK(sem) dispatch_semaphore_signal(sem)

@interface DetailListCache ()
@property (nonatomic,copy) NSString *url;
@property (nonatomic,strong) NSMutableDictionary *caches;
@end

@implementation DetailListCache
+ (void)load {
    sem = dispatch_semaphore_create(1);
}
+ (instancetype)cache:(NSString *)url {
    static NSMutableDictionary<NSString *,DetailListCache *> *singletons;
    LOCK(sem);
    DetailListCache *singleton = singletons[url];
    if (!singleton) {
        singleton = [[DetailListCache alloc] initWithUrl:url];
        singletons[url] = singleton;
    }
    UNLOCK(sem);
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
    LOCK(sem);
    [self.caches setObject:path.lastPathComponent forKey:@"k_torrent"];
    UNLOCK(sem);
    [self synchronize];
    return toStr;
}

- (NSString *)storedTorrent {
    LOCK(sem);
    NSString *filename = [self.caches objectForKey:@"k_torrent"];
    UNLOCK(sem);
    if (!filename) return nil;
    NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),filename];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath] ? filePath : nil;
}

- (void)storeImage:(NSString *)path forName:(NSString *)name {
    LOCK(sem);
    [self.caches setObject:path forKey:name];
    UNLOCK(sem);
    [self synchronize];
}

- (NSString *)storedImageForName:(NSString *)name {
    LOCK(sem);
    NSString *imgPath =[self.caches objectForKey:name];
    UNLOCK(sem);
    return [[NSFileManager defaultManager] fileExistsAtPath:imgPath] ? imgPath : nil;
}

- (void)synchronize {
    LOCK(sem);
    [[NSUserDefaults standardUserDefaults] setObject:self.caches forKey:self.url];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UNLOCK(sem);
}




@end
