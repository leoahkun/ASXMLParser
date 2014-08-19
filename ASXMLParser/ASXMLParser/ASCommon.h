//NSString additions
static inline char ASCharAt(NSString* string, int index) {
	return [string characterAtIndex:index];
}

static inline NSComparisonResult ASStringCompare(NSString *string1, NSString* string2) {
	return [string1 compare:string2];
}

static inline NSString* ASStringConcat(NSString *string1, NSString* string2) {
	return [string1 stringByAppendingString:string2];
}

static inline int ASStringFind(NSString* string, NSString* subString) {
	NSRange range = [string rangeOfString:subString];
	if (range.location != NSNotFound) {
		return range.location;
	}
	return -1;
}

static inline NSString* ASStringJoinStrings(NSString* separator, NSArray* listOfStrings) {
	return [listOfStrings componentsJoinedByString:separator];
}

static inline int ASStringLastIndexOf(NSString* string, NSString *subString) {
	NSRange range = [string rangeOfString:subString options:NSBackwardsSearch];
	if (range.location != NSNotFound) {
		return range.location;
	}
	return -1;
}

static inline NSString* ASStringSubString(NSString* string, int startPos, int endPos) {
//	NSLog(@"** subString = %@  %i %i %i %i", string, [string length], startPos, endPos, endPos-startPos);
	return [string substringWithRange:NSMakeRange(startPos, endPos-startPos)];
}

static inline NSString* ASStringAppendString(NSString* string, NSString* appendString) {
	return [NSString stringWithFormat:@"%@%@",string,appendString];
}

static inline NSString* ASStringAppendChar(NSString* string, char character) {
	return [NSString stringWithFormat:@"%@%c",string,character];
}
