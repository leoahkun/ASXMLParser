#import "ASXMLState.h"
#import "ASXMLParser.h"

@implementation ASXMLState
@synthesize currentTag;

-(void) dealloc {
	self.currentTag = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) finish {}

-(ASXMLState*) handleChar:(unichar) character {
	return self;
}

@end
