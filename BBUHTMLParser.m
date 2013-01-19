#import "BBUHTMLParser.h"

#define LOG_ME(prefix)		NSLog(@"%@: %@ %@", prefix, elementName, attributeDict)

typedef void(^BBUHTMLVisitorBlock)(BBUHTMLElement* element, NSError* error);

@interface BBUHTMLElement ()

@property (strong) NSDictionary* attributes;
@property (strong) NSMutableArray* childElements;
@property (strong) NSString* tagName;

@end

#pragma mark -

@implementation BBUHTMLElement

-(NSArray*)children {
	return [self.childElements copy];
}

-(NSArray*)childrenWithTagName:(NSString*)tagName {
	NSMutableArray* children = [NSMutableArray array];
	for (BBUHTMLElement* child in self.children) {
		if ([child.tagName isEqualToString:tagName]) {
			[children addObject:child];
		}
	}
	return children;
}

-(id)initWithTagName:(NSString*)tagName attributes:(NSDictionary*)attributes {
	self = [super init];
	if (self) {
		self.attributes = attributes;
		self.childElements = [NSMutableArray array];
		self.tagName = tagName;
	}
	return self;
}

-(NSString*)description {
	NSMutableArray* attributes = [NSMutableArray arrayWithCapacity:self.attributes.count];
	for (NSString* key in self.attributes) {
		[attributes addObject:[NSString stringWithFormat:@"%@=\"%@\"", 
			key, self.attributes[key]]];
	}
	NSString* attrs = [attributes componentsJoinedByString:@" "];
	if (attrs.length > 0) {
		attrs = [@" " stringByAppendingString:attrs];
	}

	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"<%@%@>\n", self.tagName, attrs];
	[description appendString:self.innerHTML];
	[description appendFormat:@"</%@>", self.tagName];
	return [description copy];
}

-(NSString*)innerHTML {
	NSMutableString* innerHTML = [NSMutableString string];
	for (NSObject* childElement in self.childElements) {
		[innerHTML appendFormat:@"%@\n", childElement.description];
	}
	return innerHTML;
}

-(id)objectForKeyedSubscript:(id)key {
	return self.attributes[key];
}

@end

#pragma mark -

@interface BBUHTMLParser () <DTHTMLParserDelegate>

@property (strong) NSMutableArray* currentHTMLElements;
@property (strong) NSString* lookingForTag;
@property (assign) NSUInteger resultCount;
@property (copy) BBUHTMLVisitorBlock visitorBlock;
@property (strong) NSDictionary* wantedAttributes;

@end

#pragma mark - 

@implementation BBUHTMLParser

+(instancetype)parserWithItemAtPath:(NSString*)path {
	NSData* data = [NSData dataWithContentsOfFile:path];
	return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(void)enumerateTagsWithName:(NSString*)tagName
		  matchingAttributes:(NSDictionary*)matchingAttributes
		  			   block:(BBUHTMLVisitorBlock)block {
	self.lookingForTag = tagName;
	self.resultCount = 0;
	self.visitorBlock = block;
	self.wantedAttributes = matchingAttributes;
	[self parse];
}

-(id)initWithData:(NSData*)data encoding:(NSStringEncoding)encoding {
	self = [super initWithData:data encoding:encoding];
	if (self) {
		self.currentHTMLElements = [NSMutableArray array];
		self.delegate = self;
	}
	return self;
}

-(NSUInteger)lastResultCount {
	return self.resultCount;
}

#pragma mark - DTHTMLParser delegate methods

-(void)parser:(DTHTMLParser*)parser didStartElement:(NSString*)elementName 
		attributes:(NSDictionary *)attributeDict {
	if (![elementName isEqualToString:self.lookingForTag]) {
		BBUHTMLElement* parent = [self.currentHTMLElements lastObject];
		if (!parent) {
			return;
		}

		BBUHTMLElement* child = [[BBUHTMLElement alloc] initWithTagName:elementName 
														 	 attributes:attributeDict];
		[parent.childElements addObject:child];
		[self.currentHTMLElements addObject:child];
		return;
	}

	for (NSString* key in self.wantedAttributes) {
		if (![self.wantedAttributes[key] isEqual:attributeDict[key]]) {
			return;
		}
	}

	BBUHTMLElement* element = [[BBUHTMLElement alloc] initWithTagName:elementName 
														   attributes:attributeDict];
	[self.currentHTMLElements addObject:element];
}

-(void)parser:(DTHTMLParser*)parser didEndElement:(NSString*)elementName {
	if (self.currentHTMLElements.count <= 0) {
		return;
	}

	if (![elementName isEqualToString:self.lookingForTag]) {
		[self.currentHTMLElements removeLastObject];
		return;
	}

	NSAssert(self.currentHTMLElements.count == 1, @"Too many elements left.");
	BBUHTMLElement* element = [self.currentHTMLElements lastObject];
	[self.currentHTMLElements removeAllObjects];

	if (self.visitorBlock) {
		self.resultCount++;
		self.visitorBlock(element, nil);
	}
}

@end