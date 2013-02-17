/*
 * C++ implementation of the image parsing of telekst pages
 */

#include "teletekst.h"
#include "tools.h"

#include <cstdio>
#include <cassert>
#include <cstring> // for memcpy()
#include <string>
#include <vector>
#include <tuple>
#include <gif_lib.h>

#define likely(x)	__builtin_expect(!!(x), 1)
#define unlikely(x)	__builtin_expect(!!(x), 0)

unsigned char Image::GetPixel(const unsigned int i, const unsigned int j) const
{
	return the_buffer.at(i+GetWidth()*j);
}
std::string Image::GetPixelStr(const unsigned int i, const unsigned int j) const
{
	return Char2BitmapString(i,j);
}
std::string Image::GetPixelMD5(const unsigned int i, const unsigned int j) const
{
	return CalcMD5( Char2BitmapString(i,j) );
}

void Image::Init( const unsigned int width, const unsigned int height )
{
	if ( width%char_width!=0 || height%char_height!=0 )
	{
		fprintf(stderr, "Image size (%ux%u) not a multiple of char size (%ux%u)\n", 
			width, height, char_width, char_height);
		throw;
	}
	the_width  = width;
	the_height = height;
	printf("Initialized to (%ux%u)=%u\n", width, height, GetSize() );
	the_buffer.resize( GetSize() );
}

void Image::LoadGif( const std::string filename )
{
	GifFileType *gif = DGifOpenFileName(filename.c_str());
	if (!gif)
	{
		PrintGifError();
		throw;
	}

	// read gif
	while (1)
	{
		GifRecordType recordtype;
		if ( DGifGetRecordType(gif, &recordtype) == GIF_ERROR )
		{
			PrintGifError();
			throw;
		}

		if ( recordtype != IMAGE_DESC_RECORD_TYPE )
		{
			continue;
		}

		// read gif metadata
		DGifGetImageDesc( gif );

		// init image
		Init( gif->Image.Width, gif->Image.Height );

		// read colormap
		// Note: for some gifs, use gif->Image.ColorMap instead
		if (!gif->SColorMap) throw;
		LoadColorMap( gif->SColorMap );

		// load image data
		auto line = new unsigned char[GetWidth()];
		assert( sizeof(GifPixelType) == sizeof(*line) );

		// libgif kind of sucks: we have to do this line by line
		for ( unsigned int l = 0; l < GetHeight(); l++ )
		{
			auto result = DGifGetLine( gif, line, GetWidth() );
			if (!result) throw;
			//printf("%03i: ",l); for (auto i=0; i<GetWidth(); i++) {printf("%c",'a'+line[i]);} printf("\n");
			SetLine( l, line );
		}

		free(line);

		break;
	}

	printf( "Loaded image of %ux%u pixels and %u colors\n", 
		GetWidth(), GetHeight(), GetNumColors() );
}
	

void Image::LoadColorMap( const ColorMapObject * const colormap )
{
	if (!colormap) throw;

	assert( sizeof(GifPixelType) == sizeof(unsigned char) );
	if ( colormap->ColorCount>=no_color ) throw;

	for (int i=0; i<colormap->ColorCount; i++)
	{
		the_colormap.push_back( RGBColor(
					colormap->Colors[i].Red,
					colormap->Colors[i].Green,
					colormap->Colors[i].Blue
		) );
		printf(" - (%02x,%02x,%02x)\n", 
			colormap->Colors[i].Red,
			colormap->Colors[i].Green,
			colormap->Colors[i].Blue
		  );
	}


}

void Image::SetLine( const unsigned int linenr, const unsigned char * const line )
{
	for (unsigned i=0; i<GetWidth(); i++)
	{
		the_buffer.at(i+linenr*GetWidth()) = line[i];
	}
	return;

	// starting point in buffer
	auto dest = the_buffer.data() + linenr*GetWidth();

	// copy line
	auto result = memcpy( dest, line, GetWidth() );
	if (!result) throw;
}


void Image::PrintAll() const
{
	printf("Dumping image:\n");
	for (unsigned j=0; j<GetHeight(); j++)
	{
		printf("%03i: ", j);
		for (unsigned i=0; i<GetWidth(); i++)
		{
			auto c = GetPixel(i,j);
			printf("%c", 'a'+c);
		}
		printf("\n");
	}
	printf("\n");
}

void Image::PrintChar(const unsigned x, const unsigned y) const
{
	unsigned char c1 = no_color, c2 = no_color;
	for (unsigned j=0; j<char_height; j++)
	{
		for (unsigned i=0; i<char_width; i++)
		{
			auto c = GetPixel( x*char_width+i, y*char_height+j);
			if (i==0 && j==0) 
			{ 
				c1 = c;
			}
			else if ( c != c1 )
			{
				if (unlikely( c2 != no_color && c2 != c )) throw; // more than 2 colors in char
				c2 = c;
			}

			printf("%c", 'a'+c);
		}
		printf("\n");
	}
	printf("\n");
}

std::string Image::Char2BitmapString(const unsigned x, const unsigned y) const
{
	unsigned char c1 = no_color, c2 = no_color;
	std::string bitmapstring;
	for (unsigned j=0; j<char_height; j++)
	{
		for (unsigned i=0; i<char_width; i++)
		{
			auto c = GetPixel( x*char_width+i, y*char_height+j);
			if (i==0 && j==0) 
			{ 
				c1 = c;
			}
			else if ( c != c1 )
			{
				if (unlikely( c2 != no_color && c2 != c )) throw; // more than 2 colors in char
				c2 = c;
			}
			bitmapstring.push_back( (c==c1) ? '0' : '1' );
		}
	}
	return bitmapstring;
}
