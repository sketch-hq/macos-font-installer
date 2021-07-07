#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Find all downloadable fonts that are not downloaded
        CFArrayRef downloadableFonts = CTFontDescriptorCreateMatchingFontDescriptors(CTFontDescriptorCreateWithAttributes((CFDictionaryRef)@{
            (id)kCTFontDownloadableAttribute : (id)kCFBooleanTrue,
            (id)kCTFontDownloadedAttribute : (id)kCFBooleanFalse
        }), NULL);
        // Find all installed fonts
        CFArrayRef installedFonts = CTFontDescriptorCreateMatchingFontDescriptors(CTFontDescriptorCreateWithAttributes((CFDictionaryRef)@{}), NULL);
        NSMutableArray *installedNames = [NSMutableArray array];
        for (NSFontDescriptor* font in (__bridge NSArray *)installedFonts) {
            [installedNames addObject:font.postscriptName];
        }
        // Calculate downloadable fonts that are not already installed
        // This avoids downloading newer versions of fonts already included with the operating system
        NSMutableArray *fontsToInstall = [NSMutableArray array];
        for (NSFontDescriptor* font in (__bridge NSArray *)downloadableFonts) {
            if (![installedNames containsObject:font.postscriptName])
                [fontsToInstall addObject:font];
        }
        NSLog(@"Installing %d fonts", (int)[fontsToInstall count]);
        int finished = 0;
        int* finishedRef = &finished;
        // Install all fonts. This is an asynchronous process so we register a callback to know when it finished
        CFArrayRef fontRefsToInstall = (__bridge CFArrayRef)fontsToInstall;
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(fontRefsToInstall, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
            NSDictionary *dict = (__bridge NSDictionary*)progressParameter;
            double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
            if (progressValue > 0) NSLog(@"%f %% completed", progressValue);
            if (state == kCTFontDescriptorMatchingDidFinish) {
                NSLog(@"Finished");
                *finishedRef = 1;
            } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
                NSLog(@"Error %@", dict);
                *finishedRef = -1;
            }
            return (bool)YES;
        });
        while (!finished) {
            [NSThread sleepForTimeInterval:1];
        }
        // If finished in error, return an appropriate status code
        return (finished < 0);
    }
}
