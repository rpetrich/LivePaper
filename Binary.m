#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <SpringBoard/SpringBoard.h>

#include <ctype.h>

typedef enum LPBinaryDataType {
    LPBinary,
    LPHexadecimal,
    LPAscii
} LPBinaryDataType;

// Stub class to load specifiers from plist
@interface LPBinarySettings : PSListController
@end
@implementation LPBinarySettings

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"LPBinarySettings" target:self] retain];
    }   
    return _specifiers;
}

@end

@interface LPBinaryView : UITextView {
    NSTimer *scrollTimer;
    
    CGSize byteSize;
    int linesPerPage;
    int bytesPerLine;
    CGPoint topOffset;
    CGPoint bottomOffset;
    
    LPBinaryDataType dataType;
    float scrollSpeed;
    BOOL invertedScroll;
}

@property (nonatomic, readonly) CGPoint topOffset;
@property (nonatomic, readonly) CGPoint bottomOffset;
@property (nonatomic, readonly) CGSize byteSize;
@property (nonatomic, readonly) int linesPerPage; 
@property (nonatomic, readonly) int bytesPerLine;


- (void)loadSettings;
- (void)setText;

- (void)startScroll;
- (void)scrollText:(NSTimer *)timer;
- (void)stopScroll;

- (NSString *)pageOfRandomData;

@end

@implementation LPBinaryView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor greenColor];
        self.font = [UIFont fontWithName:@"Courier" size:14.0f];

        self.editable = NO;
        self.userInteractionEnabled = NO;
       
        [self loadSettings]; 
        [self setText];
        [self startScroll];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    CGRect newFrame = CGRectMake(frame.origin.x - 8, frame.origin.y, frame.size.width + 16, frame.size.height); // Adjust for UITextView's margin :/
    [super setFrame:newFrame];
}

- (void)dealloc {
    [self stopScroll];
    [super dealloc];
}

#pragma mark -
#pragma mark Control Methods

- (void)loadSettings {    

    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.collab.livepaper.binary.plist"];
    
    dataType = LPBinary; 
    scrollSpeed = 0.10f;
    invertedScroll = YES;
    
    if (settings) {
        for (NSString *key in [settings allKeys]) {
            if ([key isEqualToString:@"LPBinaryInvertedScrolling"]) {
                invertedScroll = [[settings objectForKey:key] boolValue];
            }
            if ([key isEqualToString:@"LPBinaryDataType"]) {
                dataType = [[settings objectForKey:key] intValue];
            }
            if ([key isEqualToString:@"LPBinaryScrollSpeed"]) {
                scrollSpeed = 0.5f - [[settings objectForKey:key] floatValue];
            }

        }
    }    
}

- (void)startScroll {
    if (invertedScroll) {
        [self setContentOffset:self.topOffset animated:NO];
    } else {
        [self setContentOffset:self.bottomOffset animated:NO];
    }
    scrollTimer = [NSTimer timerWithTimeInterval:scrollSpeed target:self selector:@selector(scrollText:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:scrollTimer forMode:NSRunLoopCommonModes];
}

- (void)stopScroll {
    if ([scrollTimer isValid]) {
        [scrollTimer invalidate];
    }
    if (invertedScroll) {
        [self setContentOffset:self.topOffset animated:NO];
    } else {
        [self setContentOffset:self.bottomOffset animated:NO];
    }
}

- (void)setText {
    NSString *repeat = [self pageOfRandomData];
    self.text = [NSString stringWithFormat:@"%@%@%@", repeat, [self pageOfRandomData], repeat];
}

- (void)scrollText:(NSTimer *)timer {
    if (invertedScroll) {
        if ((self.contentOffset.y + (self.byteSize.height * 5)) >= self.bottomOffset.y) { // byteSize * 5 accounts for drift in scrolling, due to lack of accuracy in font size and spacing. Ugh.
            [self setContentOffset:self.topOffset animated:NO];
        }
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + self.byteSize.height) animated:NO];
    } else {
        if (self.contentOffset.y <= (self.byteSize.height * 5)) {
            [self setContentOffset:self.bottomOffset animated:NO];
        }
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - self.byteSize.height) animated:NO];
    }
}

#pragma mark -
#pragma mark Data Generation

- (NSString *)pageOfRandomData {
    NSMutableString *randDataString = [NSMutableString string];
    for (int x=0; x < self.linesPerPage; x++) {
        int w=0;
        for (int y=0; y < ceil((float)self.bytesPerLine / 4); y++) {
            int randomInt = arc4random();
            char bytes[4];
            bzero(bytes, 4);
            memcpy(bytes, &randomInt, 4);
            for (int z=0; z < 4; z++) {
                if (w < self.bytesPerLine) {
                    switch (dataType) {
                        case LPBinary: {
                            NSString *bits = @"";
                            for(int i = 0; i < 8; i ++) {
                                bits = [NSString stringWithFormat:@"%i%@", bytes[z] & (1 << i) ? 1 : 0, bits];
                            }
                            [randDataString appendString:[bits stringByAppendingString:@" "]];
                            break;
                        }
                        case LPHexadecimal: {
                            [randDataString appendString:[NSString stringWithFormat:@"%02X ", (bytes[z] & 0xFF)]];
                            break;
                        }
                        case LPAscii: {
                            NSString *randomCharacter = [[[[NSString alloc] initWithBytes:&bytes[z] length:sizeof(char) encoding:NSASCIIStringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([randomCharacter length] == 1) {
                                [randDataString appendString:randomCharacter];
                            } else {
                                [randDataString appendString:@"."];
                            }
                            
                            break;
                        }
                        default:
                            break;
                    }
                }
                w++;
            }
            
        }
        [randDataString appendString:@"\n"];
    }
    return randDataString;
}

#pragma mark -
#pragma mark Size

- (CGPoint)topOffset {
    return CGPointMake(self.contentOffset.x, 0);
}

- (CGPoint)bottomOffset {
    return CGPointMake(self.contentOffset.x, self.byteSize.height * self.linesPerPage * 2);
}

- (CGSize)byteSize {
    switch (dataType) {
        case LPBinary:
            byteSize = [@"11111111 " sizeWithFont:self.font];
            break;
        case LPHexadecimal:
            byteSize = [@"FF " sizeWithFont:self.font];
            break;
        case LPAscii:
            byteSize = [@"A" sizeWithFont:self.font];
            break;
            
        default:
            byteSize = CGSizeMake(0, 0);
            break;
    }
    return byteSize;
}

- (int)linesPerPage {
    linesPerPage = ceil(self.frame.size.height / self.byteSize.height);
    return linesPerPage;
}

- (int)bytesPerLine {
    bytesPerLine = floor(self.frame.size.width / self.byteSize.width);
    return bytesPerLine;
}

@end
