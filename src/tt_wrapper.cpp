#include "tt_wrapper.h"
#include "teletekst.h"

#include <cstddef>
#include <cmalloc>

void ParseGif( const char * filename, const char ** md5s, 
		size_t * width, size_t * height )
{
	auto img = Image(filename);

	auto width  = img.GetWidth();
	auto height = img.GetHeight();

	for (size_t y=0; y<height; y++)
	{
		for (size_t x=0; x<width; x++)
		{

		}
	}
}

