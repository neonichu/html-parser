#import <Foundation/Foundation.h>

#import "DTHTMLParser.h"

@interface BBUHTMLElement : NSObject

@property (readonly) NSString* innerHTML;

-(NSDictionary*)attributes;
-(NSArray*)children;
-(NSArray*)childrenWithTagName:(NSString*)tagName;
-(id)objectForKeyedSubscript:(id)key;
-(NSString*)tagName;

@end

#pragma mark -

@interface BBUHTMLParser : DTHTMLParser

@property (readonly) NSUInteger lastResultCount;

+(instancetype)parserWithItemAtPath:(NSString*)path;

-(void)enumerateTagsWithName:(NSString*)tagName
		  matchingAttributes:(NSDictionary*)matchingAttributes
		  			   block:(void (^)(BBUHTMLElement* element, NSError* error))block;

@end