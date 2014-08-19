#import "ASXMLAttribute.h"

@implementation ASXMLAttribute
@synthesize name;
@synthesize value;
@synthesize nnamespace;

-(void) dealloc {
	self.name = nil;
	self.value = nil;
	self.nnamespace = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.name = @"";
		self.value = @"";
		self.nnamespace = @"";
    }
    
    return self;
}

-(id) initWithName:(NSString*) aName value:(NSString*) aValue {
	self = [super init];
    if (self) {
        self.name = aName;
		self.value = aValue;
		self.nnamespace = @"";
    }
    
    return self;

}

-(id) initWithName:(NSString*) aName value:(NSString*) aValue nnamespace:(NSString*) aNamespace {
	self = [super init];
    if (self) {
        self.name = aName;
		self.value = aValue;
		self.nnamespace = aNamespace;
    }
    
    return self;

}

@end
