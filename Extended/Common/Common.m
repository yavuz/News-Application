//
//  Common.m
//

#import "Common.h"
#import "EDColor.h"

void getGlobalVariables() {
    BOOL isselectcolor = [[NSUserDefaults standardUserDefaults] boolForKey: @"isselectcolor"];
    if (!isselectcolor) {
        //cbcolor = [UIColor colorWithRed:82/255.0f green:131/255.0f blue:169/255.0f alpha:1.0f];
        cbcolor = [UIColor colorWithHexString:[params valueForKey:@"DEFAULTCOLOR"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"isselectcolor"];
        
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:cbcolor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectcolor"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    } else {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectcolor"];
        cbcolor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

