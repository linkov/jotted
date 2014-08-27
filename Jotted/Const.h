#define BLUECOLOR UIColorFromRGB(0xC7E4EB)
#define YELLOWCOLOR UIColorFromRGB(0xFAFA90)
#define REDCOLOR UIColorFromRGB(0xFFCCC8)

#define CREMECOLOR UIColorFromRGB(0xC7E4EB)
#define GRASSCOLOR UIColorFromRGB(0xFAFA90)
#define WHITECOLOR UIColorFromRGB(0xFFCCC8)


#define STACKWIDTH 290
#define STACKHEIGHT 400
#define STACKCORNERRAD 2

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_LEGACY_35 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif
