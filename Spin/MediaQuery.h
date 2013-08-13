#import <BridgeKit/JavaObject.h>

@interface MediaQuery : JavaObject 

+(NSInteger)hasMusicFileWithArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title;

@end