#import "ASXMLParser.h"
#import "ASXMLState.h"
#import "ASCommon.h"
#import "ASXMLAttribute.h"

@interface ASXMLParser () 
@property(nonatomic, retain) ASXMLState *state;

@end

@implementation ASXMLParser
@synthesize name;
@synthesize nnamespace;
@synthesize data;
@synthesize parent;
@synthesize dontClose;
@synthesize tags;
@synthesize attributes;	
@synthesize finished;
@synthesize open_tags;
@synthesize state;

- (id)init
{
    self = [super init];
    if (self) {
		self.name = @"__document_root";
		self.data = @"";
		self.nnamespace = @"";
		self.parent = nil;
		self.dontClose = NO;
		self.tags = [[NSMutableArray alloc] init];
		self.attributes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(id) initWithName:(NSString*) aName parent:(ASXMLParser*) aParent nnamespace:(NSString*) aNameSpace
{
    self = [super init];
    if (self) {
	// Initialization code here.
		self.name = aName;
		self.parent = aParent;
		self.nnamespace = aNameSpace;
		self.data = @"";
		self.finished = NO;
		self.tags = [[NSMutableArray alloc] init];
		self.attributes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(BOOL) isFinished {
	if ([self.name isEqualToString:@"__document_root"]) {
		if ([self.tags count] > 0) {
			BOOL lfinished = YES;
			
			for (int i = 0; i < [tags count]; i++) {
				ASXMLParser* foo = (ASXMLParser*) [tags objectAtIndex:i];
				if (![foo isFinished]) {
					lfinished = NO;
				}
			}
			return lfinished;
		}
	} else if (self.finished) {
		BOOL lfinished = YES;
		
		for (int i = 0; i < [tags count]; i++) {
			ASXMLParser* foo = (ASXMLParser*) [tags objectAtIndex:i];
			if (![foo isFinished]) {
				lfinished = NO;
			}
		}
		return lfinished;
	}
	return self.finished;
}

+(ASXMLParser*) parse:(NSString*) aData {		
	ASXMLParser *root = [[ASXMLParser alloc] init];
	__strong ASXMLState *aState = [[NormalState alloc] initWithCurrentTag:root];
	for (int i = 0; i < [aData length]; i++){
		
		ASXMLState *new_state = [aState handleChar:[aData characterAtIndex:i]];
		
		
		if (new_state != aState){
			[aState finish];
			aState = new_state;
		}
	}	
	return root;
	
}

-(BOOL) parseCharacter:(unichar) aData {
	if (state == nil){
		self.state = [[NormalState alloc] initWithCurrentTag:self];
	}
	
	ASXMLState *new_state = [self.state handleChar:aData];
	
	if (new_state != state){
		[state finish];
		self.state = new_state;
	}
	return [self isFinished];
}

-(NSString*) toXML {
	return [self toXMLfromLevel:0];
}
 
-(NSString*) toXMLfromLevel:(int) nestingLevel {
	NSString *ss = @"";
	NSString *nesting = @"";
 
	if (![name isEqualToString:@"__document_root"]) {
		ss = ASStringAppendString(ss, ASStringAppendString(nesting, @"<"));
 
		if (![nnamespace isEqualToString:@""]) {
			ss = ASStringAppendString(ss, ASStringAppendString(nnamespace, @":"));
		}
 
		ss = ASStringAppendString(ss, name);

 
		for (int i = 0; i < [attributes count]; i++) {
			ASXMLAttribute *att = (ASXMLAttribute*) [attributes objectAtIndex:i];
			if ([att.nnamespace length] == 0) {
				ss = ASStringAppendString(ss, [NSString stringWithFormat:@" %@=\"%@\"",att.name,att.value]);
			} else {
				ss = ASStringAppendString(ss, [NSString stringWithFormat:@" %@:%@=\"%@\"",att.nnamespace,att.name,att.value]);
			}
		}
		 
		if ([name isEqualToString:@"?xml"]) {
			ss = ASStringAppendString(ss, @"?>");
		} else if (([tags count] == 0) && ([data length] == 0) && (dontClose == NO)) {
			ss = ASStringAppendString(ss, @" />");
			return ss;
		} else {
			 ss = ASStringAppendString(ss, @">");
		}
	} else {
		nestingLevel = -1;
	}
	 
	if (([tags count] != 0) && ([data length] > 0) && (![name isEqualToString:@"__document_root"])) {
		ss = ASStringAppendString(ss, nesting);
	}
	 
	NSString *copy = data;
		
	copy = [copy stringByReplacingOccurrencesOfString:@"\\" withString:@"&quot;"];
	copy = [copy stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	copy = [copy stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	copy = [copy stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	copy = [copy stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
  
	ss = ASStringAppendString(ss, copy);
 
	for (int i = 0; i < [tags count]; i++) {
		ASXMLParser *att = (ASXMLParser*) [tags objectAtIndex:i];
		NSString *temp = [att toXMLfromLevel:nestingLevel + 1];
		ss = ASStringAppendString(ss, temp);
	}
 
	if ((![name isEqualToString:@"__document_root"]) && (![name isEqualToString:@"?xml"]) && (dontClose == NO)) {
		if ([tags count] != 0) {
			ss = ASStringAppendString(ss, nesting);
		}
		ss = ASStringAppendString(ss, @"</");

		if ([nnamespace length] > 0) {
			ss = ASStringAppendString(ss, ASStringAppendString(nnamespace, @":"));
		}
		ss = ASStringAppendString(ss, ASStringAppendString(name, @">"));
	}

	return ss;
}

-(void) addTag:(ASXMLParser*) xml_tag {
	if (![xml_tag.name isEqualToString:@"!--"]) {
		[self.tags addObject:xml_tag];
	}
}
 
-(void) addXMLAttribute:(ASXMLAttribute*) xmlAttribute {
	[self.attributes addObject:xmlAttribute];	
}

-(void) addData:(NSString*) d {
	self.data = ASStringAppendString(data, d);
}
 
-(ASXMLParser*) findTag:(NSString*) text {
	for (int i = 0; i < [tags count]; i++) {
		ASXMLParser *tag = (ASXMLParser*) [tags objectAtIndex:i];
		if ([tag.name isEqualToString:text]) {
			return tag;
		}
	}

	for (int i = 0; i < [tags count]; i++) {
		ASXMLParser *temptag = (ASXMLParser*) [tags objectAtIndex:i];
		ASXMLParser *tag = (ASXMLParser*) [temptag findTag:text];
		if (tag != nil) {
			return tag;
		}
	}
	return nil;
}

-(NSString*) findAttribute:(NSString*) text {
	for (int i = 0; i < [attributes count]; i++) {
		ASXMLAttribute *att = (ASXMLAttribute*) [attributes objectAtIndex:i];
		if ([att.name isEqualToString:text]) {
			return att.value;
		}
	}
	return nil;
}
 
-(ASXMLParser*) subTagWithName:(NSString*) n nnamespace:(NSString*) ns {
	ASXMLParser *tag;
	if (ns != nil) {
		tag = [[ASXMLParser alloc] initWithName:n parent:self nnamespace:ns];
	} else {
		tag = [[ASXMLParser alloc] initWithName:n parent:self nnamespace:@""];
	}
	[self addTag:tag];
	return tag;
}

@end

#pragma mark TagState

@interface TagState () 
@property(nonatomic, assign) BOOL close;
@property(nonatomic, assign) BOOL iinline;
@property(nonatomic, retain) NSMutableString *buffer;
@end

@implementation TagState
@synthesize close;
@synthesize iinline;
@synthesize buffer;


-(void) dealloc {
	self.buffer = nil;
}

-(id) init {
	self = [super init];
    if (self) {
		self.close = NO;
		self.iinline = NO;
		self.buffer = [[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}

-(id) initWithCurrentTag:(ASXMLParser*) currTag {	
	self = [super init];
    if (self) {
		self.close = NO;
		self.iinline = NO;
		self.currentTag = currTag;
		self.buffer = [[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}

-(ASXMLState*) handleChar:(unichar)character {
	if (!close) {
		switch (character) {
			case '[':
			{
				if ([self.buffer isEqualToString:@"![CDATA"]) {
					return [[CDataState alloc] initWithCurrentTag:self.currentTag];
				} else {
					[buffer appendFormat:@"%C",character];
				}
			}
				break;
			case ' ': {
				ASXMLParser *new_tag;
				int pos = ASStringLastIndexOf(buffer, @":");				
				if (pos >= 0) {
					NSString *ns = ASStringSubString(buffer, 0, pos);
					NSString *tag = ASStringSubString(buffer, pos + 1, pos + 1 + [buffer length] - pos - 1);
					new_tag = [[ASXMLParser alloc] initWithName:tag parent:currentTag nnamespace:ns];
				} else {
					new_tag = [[ASXMLParser alloc] initWithName:buffer parent:currentTag nnamespace:@""];
				}
				[currentTag addTag:new_tag];
				return [[AttributeState alloc] initWithCurrentTag:new_tag];
			}
				break;
			case '>': {						
				ASXMLParser *new_tag;
				int pos = ASStringLastIndexOf(buffer, @":");	
				
				if (pos >= 0) {
					NSString *ns = ASStringSubString(buffer, 0, pos);
					NSString *tag = ASStringSubString(buffer, pos + 1, pos + 1 + [buffer length] - pos - 1);
					new_tag = [[ASXMLParser alloc] initWithName:tag parent:currentTag nnamespace:ns];
				} else {
					new_tag = [[ASXMLParser alloc] initWithName:buffer parent:currentTag nnamespace:@""];
				}
				[currentTag addTag:new_tag];
				
				return [[NormalState alloc] initWithCurrentTag:new_tag] ;
			}
				break;
			case '/': {
				if ([buffer length] != 0) {
					self.iinline = true;
				}
				self.close = true;
			}
				break;				
			default: {						
				[buffer appendFormat:@"%C",character];
			}
				break;
		}
		return self;
	} else {
		switch (character) {
			case '>': {
				if (iinline) {
					ASXMLParser *new_tag;
					int pos = ASStringLastIndexOf(buffer, @":");
					if (pos >= 0) {
						NSString *ns = ASStringSubString(buffer, 0, pos);
						NSString *tag = ASStringSubString(buffer, pos + 1, pos + 1 + [buffer length] - pos - 1);
						new_tag = [[ASXMLParser alloc] initWithName:tag parent:currentTag nnamespace:ns];
					} else {
						new_tag = [[ASXMLParser alloc] initWithName:buffer parent:currentTag nnamespace:@""];
					}
					
					new_tag.finished = YES;
					[currentTag addTag:new_tag];
					return [[NormalState alloc] initWithCurrentTag:currentTag];
				} else {
					currentTag.finished = YES;
					if (currentTag.parent != nil) {
						return [[NormalState alloc] initWithCurrentTag:currentTag.parent];
					} else {
						return [[NormalState alloc] initWithCurrentTag:currentTag];
					}
				}

			}
				break;
			default:
				[buffer appendFormat:@"%C",character];
				break;
				// return this;
		}
		return self;
	}
	//return this;
}


@end

#pragma mark -
#pragma mark AttributeState

@interface AttributeState () 
@property(nonatomic, assign) BOOL inName;
@property(nonatomic, assign) BOOL escaped;
@property(nonatomic, assign) BOOL inDoubleCommas;
@property(nonatomic, assign) BOOL inSingleCommas;
@property(nonatomic, assign) BOOL iinline;
@property(nonatomic, retain) NSMutableString* varName;
@property(nonatomic, retain) NSMutableString* varVal;

@end

@implementation AttributeState
@synthesize inName;
@synthesize escaped;
@synthesize inDoubleCommas;
@synthesize inSingleCommas;
@synthesize iinline;
@synthesize varName;
@synthesize varVal;

-(void) dealloc {
	self.varName = nil;
	self.varVal = nil;
}

-(id) init {
	self = [super init];
    if (self) {
		self.inName = YES;
		self.escaped = NO;
		self.inDoubleCommas = NO;
		self.inSingleCommas = NO;
		self.iinline = NO;
		self.varVal = [[NSMutableString alloc] initWithString:@""];
		self.varName = [[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}

-(id)initWithCurrentTag:(ASXMLParser*) currTag {
	self = [super init];
    if (self) {
		self.currentTag = currTag;
		self.varVal = [[NSMutableString alloc] initWithString:@""];
		self.varName = [[NSMutableString alloc] initWithString:@""];
		
		self.inName = YES;
		self.escaped = NO;
		self.inDoubleCommas = NO;
		self.inSingleCommas = NO;
	}
    
    return self;
}

-(ASXMLState*) handleChar:(unichar)character {
	switch (character) {
		case '=':
			if (!inSingleCommas && !inDoubleCommas) {
				inName = NO;
			} else {
				//self.varVal = ASStringAppendChar(varVal, character);
				[self.varVal appendFormat:@"%C",character];
			}
			
			break;
		case '\"': {
			if (inName) {
				//self.varName = ASStringAppendChar(varName, character);
				[self.varName appendFormat:@"%C",character];
			} else {
				if (inDoubleCommas) {
					inDoubleCommas = NO;
					inName = YES;
					ASXMLAttribute *xa;
					
					int pos = ASStringLastIndexOf(varName, @":");
					
					if (pos >= 0) {
						NSString *ns = ASStringSubString(varName, 0, pos);
						NSString *name = ASStringSubString(varName, pos + 1, pos + 1 + [varName length] - pos - 1);
						xa = [[ASXMLAttribute alloc] initWithName:[NSString stringWithString:name] value:[NSString stringWithString:varVal] nnamespace:[NSString stringWithString:ns]];
					} else {
						xa = [[ASXMLAttribute alloc] initWithName:[NSString stringWithString:varName] value:[NSString stringWithString:varVal]];
					}
					
					[currentTag addXMLAttribute:xa];

					//self.varName = @"";
					[self.varName setString:@""];
					[self.varVal setString:@""];
					
				} else if (!inSingleCommas){
					inDoubleCommas = YES;
				} else {
					//self.varVal = ASStringAppendChar(varVal, '\"');
					[self.varVal appendFormat:@"%C",'\"'];
				}
			}
		}
			break;
		case '\'':
			if (inName) {
				//self.varName = ASStringAppendChar(varName, character);
				[self.varName appendFormat:@"%C",character];
			} else {
				if (inSingleCommas) {
					inSingleCommas = NO;
					inName = YES;
					ASXMLAttribute *xa;
					
					int pos = ASStringLastIndexOf(varName, @":");
					
					if (pos >= 0) {
						NSString *ns = ASStringSubString(varName, 0, pos);
						NSString *name = ASStringSubString(varName, pos + 1, pos + 1 + [varName length] - pos - 1);
						xa = [[ASXMLAttribute alloc] initWithName:[NSString stringWithString:name] value:[NSString stringWithString:varVal] nnamespace:[NSString stringWithString:ns]];
					} else {
						xa = [[ASXMLAttribute alloc] initWithName:[NSString stringWithString:varName] value:[NSString stringWithString:varVal]];
					}
					
					[currentTag addXMLAttribute:xa];
					//self.varName = @"";
					[self.varName setString:@""];
					[self.varVal setString:@""];
				} else if (!inDoubleCommas){
					inSingleCommas = YES;
				} else {
					//self.varVal = ASStringAppendChar(varVal, '\'');
					[self.varVal appendFormat:@"%C",'\''];
				}
			}
			break;
		case ' ':
			if ((inSingleCommas || inDoubleCommas) && !inName) {
				//self.varVal = ASStringAppendChar(varVal, character);
				[self.varVal appendFormat:@"%C",character];
			}
			break;
		case '/':
			if (!inSingleCommas && !inDoubleCommas) {
				iinline = YES;
			} else {
				//self.varVal = ASStringAppendChar(varVal, character);
				[self.varVal appendFormat:@"%C",character];
			}
			break;
		case '>':						
			if (!inSingleCommas && !inDoubleCommas) {
				if (iinline) {
					currentTag.finished = YES;
					return [[NormalState alloc] initWithCurrentTag:currentTag.parent];
				} else if (([currentTag.name hasPrefix:@"!--"]) && ([currentTag.name hasSuffix:@"--"])) {
					currentTag.finished = YES;
					return [[NormalState alloc] initWithCurrentTag:currentTag.parent];
				} else {
					if ([currentTag.name isEqualToString:@"?xml"]) {
						currentTag.finished = YES;
					}
					if ([currentTag.name isEqualToString:@"stream"]) {
						currentTag.finished = YES;
					}							
				}
				return [[NormalState alloc] initWithCurrentTag:currentTag];
			} else {
				//self.varVal = ASStringAppendChar(varVal, character);
				[self.varVal appendFormat:@"%C",character];
			}
			break;
		default:
			if (inName) {
				//self.varName = ASStringAppendChar(varName, character);
				[self.varName appendFormat:@"%C",character];
			} else {
				//self.varVal = ASStringAppendChar(varVal, character);
				[self.varVal appendFormat:@"%C",character];
			}
			break;
	}
	return self;
}


@end

#pragma mark -
#pragma mark NormalState

@interface NormalState () 
@end

@implementation NormalState

-(id) init {
	self = [super init];
    if (self) {
    }
    
    return self;
}
-(id) initWithCurrentTag:(ASXMLParser*) currTag {
	self = [super init];
    if (self) {
		self.currentTag = currTag;
    }
    
    return self;
}

-(ASXMLState*) handleChar:(unichar)character {
	switch (character) {
		case ' ':
		case ',':
		case '\r':
		case '\n':
		case '\t':
			break;
		case '<':
			return [[TagState alloc] initWithCurrentTag:currentTag];
		default: {
			DataState *ds = [[DataState alloc] initWithCurrentTag:currentTag];
			ASXMLState *ret = [ds handleChar:character];
			return ret;
		}			
	}
	return self;

}

@end

#pragma mark -
#pragma mark DataState

@interface DataState () 
@property(nonatomic, assign) BOOL escaped;
@property(nonatomic, retain) NSMutableString *buffer;
@end

@implementation DataState
@synthesize escaped;
@synthesize	buffer;

-(id) init {
	self = [super init];
    if (self) {
		self.escaped = NO;
		//self.buffer = @"";
		self.buffer = [[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}
-(id) initWithCurrentTag:(ASXMLParser*) currTag {
	self = [super init];
    if (self) {
		self.currentTag = currTag;
		self.buffer = [[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}

-(void) finish { 
	currentTag.data = [currentTag.data stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\\"];
	currentTag.data = [currentTag.data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	currentTag.data = [currentTag.data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	currentTag.data = [currentTag.data stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	currentTag.data = [currentTag.data stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
}

-(ASXMLState*) handleChar:(unichar)character {
	if (escaped) {
		//self.buffer = ASStringAppendChar(buffer, character);
		[self.buffer appendFormat:@"%C",character];
		self.escaped = NO;
		return self;
	}
	switch (character) {
		case '\\':
			//self.buffer = ASStringAppendChar(buffer, character);
			[self.buffer appendFormat:@"%C",character];
			self.escaped = YES;
			break;
		case '<':
			currentTag.data = ASStringAppendString(currentTag.data,buffer);
			return [[TagState alloc] initWithCurrentTag:currentTag];
		default:			
			//self.buffer = ASStringAppendChar(buffer, character);
			[self.buffer appendFormat:@"%C",character];
			break;
	}
	return self;
}

@end

#pragma mark -
#pragma mark CDataState

@interface CDataState () 
@property(nonatomic, retain) NSMutableString* closeCData;
@property(nonatomic, retain) NSMutableString *buffer;
@end

@implementation CDataState
@synthesize closeCData;
@synthesize buffer;


-(id) initWithCurrentTag:(ASXMLParser*) currTag {
	self = [super init];
    if (self) {
		//self.buffer = @"";
		self.buffer = [[NSMutableString alloc] initWithString:@""];
		//self.closeCData = @"";
		self.closeCData = [[NSMutableString alloc] initWithString:@""];
		self.currentTag = currTag;
    }
    
    return self;
}

-(ASXMLState*) handleChar:(unichar)character {
	switch (character){
		case ']':
			if ([closeCData length] <= 1) {
				//self.closeCData = ASStringAppendChar(closeCData, character);
				[self.closeCData appendFormat:@"%C",character];
			} else {
				//self.buffer = ASStringAppendString(buffer, closeCData);
				[self.buffer appendString:closeCData];
				//self.buffer = ASStringAppendChar(buffer, character);
				[self.buffer appendFormat:@"%C",character];
				//self.closeCData = @"";
				[self.closeCData setString:@""];
			}
			break;
		case '>':
			if ([closeCData isEqualToString:@"]]"]) {
				currentTag.data = ASStringAppendString(currentTag.data, buffer);
				return [[NormalState alloc] initWithCurrentTag:currentTag];
			} else {
				//self.buffer = ASStringAppendString(buffer, closeCData);
				[self.buffer appendString:closeCData];				
				//self.buffer = ASStringAppendChar(buffer, character);
				[self.buffer appendFormat:@"%C",character];
				//self.closeCData = @"";
				[self.closeCData setString:@""];
			}
			break;
		default:
			if ([closeCData length] > 0){
				//self.buffer = ASStringAppendString(buffer, closeCData);
				[self.buffer appendString:closeCData];				
				//self.buffer = ASStringAppendChar(buffer, character);
				[self.buffer appendFormat:@"%C",character];
				//self.closeCData = @"";
				[self.closeCData setString:@""];
			} else {
				//self.buffer = ASStringAppendChar(buffer, character);
				[self.buffer appendFormat:@"%C",character];
			}
			break;
	}
	return self;

}
	


@end

