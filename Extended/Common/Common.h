//
//  Common.h
//

#import <Foundation/Foundation.h>

#ifndef COMMON_H
#define COMMON_H

#pragma mark - Global Variables


#define IDIOM		UI_USER_INTERFACE_IDIOM()
#define is_iPad		(interfaceIdiom==UIUserInterfaceIdiomPad)
#define is_iPhone	(interfaceIdiom==UIUserInterfaceIdiomPhone)
#define is_iPhone5  ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


UIColor *cbcolor;
NSMutableDictionary *params;
void getGlobalVariables();

@interface NSObject (FMObjectLogs)
- (void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);
@end

#endif
