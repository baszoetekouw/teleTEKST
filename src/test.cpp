#include "teletekst.h"
#include "tools.h"
#include <cstdio>

int main()
{
	auto img = Image("../test/P101_01.gif");
	//img.PrintAll();

	int x,y;
	
	x=1; y=4;
	//img.PrintChar(x,y);
	//printf("%s\n",img.GetPixelStr(x,y).c_str());
	printf("%s\n",base64(img.GetPixelMD5(x,y)).c_str());

	x=2; y=4;
	//img.PrintChar(x,y);
	//printf("%s\n",img.GetPixelStr(x,y).c_str());
	printf("%s\n",base64(img.GetPixelMD5(x,y)).c_str());

	x=3; y=4;
	//img.PrintChar(x,y);
	//printf("%s\n",img.GetPixelStr(x,y).c_str());
	printf("%s\n",base64(img.GetPixelMD5(x,y)).c_str());

	/*
	string bla = "foo";
	printf("xxx=> %5s -> %s\n", bla.c_str(), base64(bla,true).c_str() );
	bla = "foot";
	printf("xxx=> %5s -> %s\n", bla.c_str(), base64(bla,true).c_str() );
	bla = "foots";
	printf("xxx=> %5s -> %s\n", bla.c_str(), base64(bla,true).c_str() );
	*/

	return 0;
}
