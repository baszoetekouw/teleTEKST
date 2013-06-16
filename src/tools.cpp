#include "tools.h"

#include <string>
#include <openssl/md5.h>

// calculate MD5 of a std::string
std::string CalcMD5(const std::string str)
{
	const unsigned char * buff = (const unsigned char *) str.c_str();
	unsigned char md5[MD5_DIGEST_LENGTH];
	auto len = str.length();

	MD5( buff, len, md5 );

	std::string md5_str( (const char *) md5, MD5_DIGEST_LENGTH );
	return md5_str;
}

// return a base-64 encoded version of the input string
std::string base64( const std::string & buf, const bool padding )
{
	std::string str_base64;

	size_t byte = 0; // bytes count from 0 to N-1
	int    bit  = 7; // bits count from 7 to 0 

	// iterate through the buffer in 6-bit steps
	while ( byte<buf.size() )
	{
		unsigned char this_byte;
		unsigned char next_byte;
		unsigned char val_6bit;
		unsigned char out;

		this_byte = buf[byte];
		next_byte = (byte+1)==buf.size() ? 0 : buf[byte+1];

		//fprintf(stderr, "==> pos %zu(%u): %02x %02x\n", byte, bit, this_byte, next_byte);

		if (bit==7)
		{
			// take first 6 bits from current byte
			val_6bit = (this_byte>>2) & 0x3f;
			bit = 1;
		}
		else if (bit==1)
		{
			// take last 2 bits from current byte and first 4 bits from next byte
			val_6bit = ( (this_byte<<4) & 0x30 ) | ( (next_byte>>4) & 0x0f );
			byte++;
			bit = 3;
		}
		else if (bit==3)
		{
			// take last 4 bits from current byte and first 2 bits from next byte
			val_6bit = ( (this_byte<<2) & 0x3c ) | ( (next_byte>>6) & 0x03 );
			byte++;
			bit = 5;
		}
		else if (bit==5)
		{
			// take last 6 bits from current byte
			val_6bit = ( this_byte & 0x3f );
			byte++;
			bit = 7;
		}
		else
		{
			throw; // never reached
		}

		//fprintf(stderr, "    six-bit value: %02x==%u\n", val_6bit, val_6bit);

		// now check the 6-bit value in "val_6bit" and convert to radix-64 
		if      (val_6bit <  26)  out = 'A'+val_6bit;
		else if (val_6bit <  52)  out = 'a'+val_6bit-26;
		else if (val_6bit <  62)  out = '0'+val_6bit-52;
		else if (val_6bit == 62)  out = '+';
		else if (val_6bit == 63)  out = '/';

		//fprintf(stderr, "    radix-64: %c\n", out);

		str_base64.push_back(out);
	}

	if (padding)  while ( str_base64.size() % 4 )  str_base64.push_back('=');

	return str_base64;
}

