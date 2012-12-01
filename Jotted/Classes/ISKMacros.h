#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define BLUECOLOR UIColorFromRGB(0xC7E4EB)
#define YELLOWCOLOR UIColorFromRGB(0xFAFA90)
#define REDCOLOR UIColorFromRGB(0xFFCCC8)

#define STACKWIDTH 290
#define STACKHEIGHT 400
#define STACKCORNERRAD 6