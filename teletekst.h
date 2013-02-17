#include <cstdio>
#include <cassert>
#include <string>
#include <vector>
#include <tuple>
#include <gif_lib.h>

#define likely(x)	__builtin_expect(!!(x), 1)
#define unlikely(x)	__builtin_expect(!!(x), 0)

typedef std::tuple<unsigned char,unsigned char, unsigned char> RGBColor;
typedef unsigned int Pixel;

class Image 
{
public:
	Image(const unsigned int width, const unsigned int height)
	{
		Init( width, height );
	}

	Image( const std::string filename ) { LoadGif( filename ); }

	void LoadGif( const std::string filename );

	void SetColorMap( const std::vector <RGBColor> colormap ) { the_colormap = colormap; }
	const std::vector<RGBColor> &GetColorMap() const { return the_colormap; }

	unsigned int GetWidth()     const { return the_width; }
	unsigned int GetHeight()    const { return the_height; }
	unsigned int GetSize()      const { return the_width*the_height; }
	unsigned int GetNumColors() const { return the_colormap.size(); }

	unsigned char GetPixel(const unsigned int i, const unsigned int j) const;
	std::string GetPixelStr(const unsigned int i, const unsigned int j) const;
	std::string GetPixelMD5(const unsigned int i, const unsigned int j) const;

	void PrintAll() const;
	void PrintChar(const unsigned x=0, const unsigned y=0) const;


private:
	const static unsigned char char_width  = 11;
	const static unsigned char char_height = 14;
	const static unsigned char no_color    = 0xff;
	unsigned int the_width;
	unsigned int the_height;
	std::vector <Pixel> the_buffer;
	std::vector <RGBColor> the_colormap;

	void Init( const unsigned int width, const unsigned int height );
	void LoadColorMap( const ColorMapObject * const colormap );
	void SetLine( const unsigned int linenr, const unsigned char * const line );

	std::string Char2BitmapString(const unsigned x, const unsigned y) const;
};

