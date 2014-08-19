#import <Foundation/Foundation.h>
@class ASXMLParser;

@interface ASXMLState : NSObject {
	ASXMLParser* currentTag;
}

@property(nonatomic, retain) ASXMLParser* currentTag;

-(void) finish;
-(ASXMLState*) handleChar:(unichar) character;

@end
