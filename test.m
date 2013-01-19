#import "BBUHTMLParser.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
    	BBUHTMLParser* parser = [BBUHTMLParser parserWithItemAtPath:@"test.html"];
    	[parser enumerateTagsWithName:@"div" 
    			matchingAttributes:@{@"class": @"user"}
    			block:^(BBUHTMLElement* element, NSError* error) {
    				BBUHTMLElement* a = [[element childrenWithTagName:@"a"] lastObject];
            NSString* user = [a[@"href"] substringFromIndex:1];
            printf("%s\n", [user UTF8String]);
    			}];
	}
}
