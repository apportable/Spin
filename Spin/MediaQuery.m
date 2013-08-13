#import <BridgeKit/JavaObject.h>
#import "MediaQuery.h"


@implementation MediaQuery

+ (void)initializeJava {
	[super initializeJava];
	[MediaQuery registerStaticMethod:@"hasMusicFile"
			selector:@selector(hasMusicFileWithArtist:album:title:)
			returnValue:[JavaClass intPrimitive] 
			arguments:[NSString className], [NSString className], [NSString className], nil];
}

+ (NSString *)className {
	return @"com.apportable.test.MediaQueryApi";
}

@end