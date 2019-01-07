#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageDisplayer : UIViewController
@property (nonatomic,strong) UIImage *image;
/// 完成按钮回调 参数：identifier（NSString *） image（UIImage *）
- (void)addTarget:(id)target finished:(SEL)finished;
@end
