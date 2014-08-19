
@interface ASXMLAttribute : NSObject {
	NSString *name;
	NSString *value;
	NSString *nnamespace;	
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *value;
@property(nonatomic, retain) NSString *nnamespace;

-(id) initWithName:(NSString*) aName value:(NSString*) aValue;
-(id) initWithName:(NSString*) aName value:(NSString*) aValue nnamespace:(NSString*) aNamespace;


@end
