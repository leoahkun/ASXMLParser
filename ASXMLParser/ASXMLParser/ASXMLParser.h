#import <Foundation/Foundation.h>
#import "ASXMLState.h"
@class ASXMLState;
@class ASXMLAttribute;

@interface ASXMLParser : NSObject {
	NSString *name;
	NSString *nnamespace;
	NSString *data;
	ASXMLParser *parent;
	BOOL dontClose;
	NSMutableArray *tags;
	NSMutableArray *attributes;	
	BOOL finished;
	int open_tags;
	
@private 	
	ASXMLState *state;
}
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *nnamespace;
@property(nonatomic, retain) NSString *data;
@property(nonatomic, retain) ASXMLParser *parent;
@property(nonatomic, assign) BOOL dontClose;
@property(nonatomic, retain) NSMutableArray *tags;
@property(nonatomic, retain) NSMutableArray *attributes;
@property(nonatomic, assign) BOOL finished;
@property(nonatomic, assign) int open_tags;

-(id) initWithName:(NSString*) aName parent:(ASXMLParser*) aParent nnamespace:(NSString*) aNameSpace;
-(BOOL) isFinished;
+(ASXMLParser*) parse:(NSString*) aData;
-(NSString*) toXML;
-(NSString*) toXMLfromLevel:(int) nestingLevel;
-(void) addTag:(ASXMLParser*) xml_tag;
-(void) addXMLAttribute:(ASXMLAttribute*) xmlAttribute;
-(void) addData:(NSString*) d;
-(ASXMLParser*) findTag:(NSString*) text;
-(NSString*) findAttribute:(NSString*) text;
-(ASXMLParser*) subTagWithName:(NSString*) n nnamespace:(NSString*) ns;

@end

@interface TagState : ASXMLState {
@private
    BOOL close;
	BOOL iinline;
	NSMutableString *buffer;
}

-(id) initWithCurrentTag:(ASXMLParser*) currTag;
-(ASXMLState*) handleChar:(unichar)character;

@end

@interface AttributeState : ASXMLState {
@private
    BOOL inName;
	BOOL escaped;
	BOOL inDoubleCommas;
	BOOL inSingleCommas;
	BOOL iinline;
	
	NSMutableString* varName;
	NSMutableString* varVal;
}

-(id) initWithCurrentTag:(ASXMLParser*) currTag;
-(ASXMLState*) handleChar:(unichar)character;

@end

@interface NormalState : ASXMLState {
}

-(id) initWithCurrentTag:(ASXMLParser*) currTag;
-(ASXMLState*) handleChar:(unichar)character;

@end

@interface DataState : ASXMLState {
@private
    BOOL escaped;
	NSMutableString *buffer;
}

-(id) initWithCurrentTag:(ASXMLParser*) currTag;
-(ASXMLState*) handleChar:(unichar)character;
-(void) finish;

@end

@interface CDataState : ASXMLState {
@private
    NSMutableString *closeCData;
	NSMutableString *buffer;
}

-(id) initWithCurrentTag:(ASXMLParser*) currTag;
-(ASXMLState*) handleChar:(unichar)character;

@end




