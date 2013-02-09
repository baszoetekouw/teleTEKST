#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use LWP::Simple;
use File::Temp qw(tempfile);
use Image::Imlib2;
use Digest::MD5 qw(md5_base64);

$|=1;

use constant {
	NUM_COLS    => 40,
	NUM_ROWS    => 24,
	CHAR_WIDTH  => 11,
	CHAR_HEIGHT => 14,
};

my $URL = 'http://nos.nl/data/teletekst/gif/P%03u_%02u.gif';

my %CHARMAP = (
	'yZILqp4Nsptq+wF6rw2Q8w' => 'A',
	'5HIASYw+c247jfjY24+f0w' => 'B',
	'oXjAFvz5rqe+Jp6uU1V6aQ' => 'C',
	'1ogz0qeqsnIj6vQzFC3EQA' => 'D',
	'hWr2A/fRmz5MugrRJmD6Ig' => 'E',
	'z91xeMzPQOzoRKvdnXSviw' => 'F',
	'p4YIAb2F7Z7r04ByBzB99A' => 'G',
	'lkEoniFV3vHUN/KRfgQE1g' => 'H',
	'yju3qPaX0Swxddol+NsShw' => 'I',
	'CXz7Ud+6e3CpUin/ffpyHg' => 'J',
	'ahSCww8LDe6KSIajdXVg7Q' => 'K',
	'3au9Lu/cT77IWbMQXBy7yQ' => 'L',
	'ZsMTuhG4zOFKHPBTG7/0GA' => 'M',
	'tLu+8Zi9HSycopWmmudVQw' => 'N',
	                                 # O
	'HSmUSi/jEntBY2PKJYxE0A' => 'P',
	'/Fk1a/DIYVlPOVuocueLug' => 'Q',
	'9QdXUrB0diXqTdkktbMFxg' => 'R',
	'z9MACMDDk8c9zGYxwz0NFw' => 'S',
	'qwNzvnLgU5HzC8ENKp2ckg' => 'T',
	'RZEyby2KvKYGIE3o4ZjAjQ' => 'U',
	'E3FMzPGFWb1rYY8uFnnp1w' => 'V',
	'Sk8TBxHof1tdQ+zk0nn3TA' => 'W',
	'cu4O2+T5vOwNpkJD8AgnwQ' => 'X',
	'Zy7OWOwAQdaLzwwq9v43/Q' => 'Y',
	'PXLxMHZBKmtoJjcxAlW7mA' => 'Z',

	'/EllNnZXlxSn3zABBp8yJQ' => 'a',
	'mjevVn9WK42MfT9tHRr3jw' => 'b',
	'FbP97YxVjLU5RGEflJGXKg' => 'c',
	'N/8U/ZbSMgPiI1kQYySCpw' => 'd',
	'A0WI2s4J0fXN14K9q+0xXA' => 'e',
	'rauUP3eaR7E97XiwnMe79Q' => 'f',
	'yXemYKb6FWkSOt96PSLWEg' => 'g',
	'YMxhpD+5v48HDo19zLKMWQ' => 'h',
	'u1zbAwIadlISywol4RO8pQ' => 'i',
	'RPfgzpB/jSFRja779zP0Ig' => 'j',
	'GiocBrS68Tj7aw07o/D8Iw' => 'k',
	'jCT27TztvGtiNuj/or0HUg' => 'l',
	'ky8BJ/1++Q3EkWeFzoL6hQ' => 'm',
	'CjCBNZGJkoys6NkZF1S7Rg' => 'n',
	'MHRu9cMVe1GY6R8er5xpTQ' => 'o',
	'zgw5slLrzQbc+0xvRmHgpw' => 'p',
	'DP8G9e0lObZPdWfNA/iMCg' => 'q',
	'5TFkvSMerIXfR6ZH4SX55Q' => 'r',
	'u0P/ZNrGRGiXNzJo6you5Q' => 's',
	'yF37MNTEtaebhMjL2qY7JQ' => 't',
	'vG+sqJFuTZ+fscWE6nV5CQ' => 'u',
	'RrqK44ffguBPSgRmzOWYRQ' => 'v',
	'zKLvNohB7SNg3dNFM9pM6Q' => 'w',
	'1qm0ZxF6S5P7gNwGf3SXQA' => 'x',
	'uAiQDOY33R24CKt9f30FhA' => 'y',
	'h7itvPQs+t4/2v85fzCu2g' => 'z',

	'wYw6c++B8zfLkcDKoDt9Ew' => '0',
	'GAZT3nubUzLzQIVegtS0hw' => '1',
	'm6eBO29jSn+LfAKvGDcnpg' => '2',
	'TKaXPX6/sGkH/efjAEOBKw' => '3',
	'YqxdqBOx4lv/aQXwqLxN6A' => '4',
	'mKC7bfBzW7JTk+NYvGUx3Q' => '5',
	'Y78+Ilea2Mv37JbekyQ0zg' => '6',
	'1R90RLvBn1H2baGtOn+3Tg' => '7',
	'qbRuWj8AtPX/7MftmrvDmw' => '8',
	'5yd3EEprRKPKj/OTghUrYQ' => '9',
	'TlkTprYNWmhWep2Ld0wlRA' => 'O',

	'GtAWDc6Nj0BZ1AICoBGREw' => ' ',
	'YoXmvB4lPPR70X3VBieZBg' => "'",
	'Hg3RzjI+e3xFHNB5Xg+G/g' => '"',
	'Eo0Dgg4ayAO6FikLwoZyVw' => "\x{2019}", # ’
	'AwOxpYjql3ld00j44WzlYw' => '.',
	'TvVXhHUgdSoQx8pjFodOaQ' => ',',
	'b2/6Bk5y36qUEZMZbQyg3Q' => ':',
	'mI3DdKHNfLKXqVGfi2208A' => ';',
	'IkjGweRaGuH6vRPLuY7auA' => '/',
	'rIxOU9F8blB5DNBCzAtA7Q' => '(',
	'e8Xy2fPYgtv+rCE/YJYyCw' => ')',
	'SWzCAZGTBrgJ1J3L2lNArQ' => '+',
	'FSGqZN0jDOE6p8YqT77RfQ' => '-',
	'n/pcZQ0OjKWbKhnllZM2GA' => '*',
	'r76cV/3Mo8yHsBYQMPn+lg' => '&',
	'tqpFXUoQpEI9jF5PqmQROw' => '%',

	'nLoCwPh0qvwuvJhUhS94Pw' => "\x{e2}", # â
	'DAlN3FeEpq7CEfIVCTIZtQ' => "\x{e1}", # á
	'5phEStq6CPPXN37ZnS5Ujg' => "\x{e4}", # ä
	'gou3QxkrnMuc3b6UvLEAEA' => "\x{ea}", # ê
	'VLB6O9W9U1rkRRa0L2VNwg' => "\x{e9}", # é
	'zpr7eHfGVXECzhDYq9HKKw' => "\x{ef}", # è
	'eg5b/v462+RnqcKtZOGe6A' => "\x{eb}", # ë
	'6Rfy9abRjqmsfVbKe4AFhA' => "\x{cb}", # Ë
	'5HSyAWuKjE488MFkCatgUQ' => "\x{ed}", # í
	'KEsc2v959ngqMGfn7nK5PA' => "\x{ef}", # ï
	'vs8Bzt8ZiFizfLOnBOCiZA' => "\x{f6}", # ö
	'mPlrOID7KFUy4xZfe0x1hQ' => "\x{f4}", # ô
	'Rdb8D2b6DO4thVCpPhAl9g' => "\x{d6}", # Ö
	'+KLMUH32JqdyD5HxwHVPpQ' => "\x{161}", # š

	'jnANoReEIdj4M592Z8xs0A' => "\x{2500}", # ─ light horizontal
	'1DFflVIrnKOdNBM+HIaTdw' => "\x{2501}", # ━ heavy horizontal
	'Tlvc0t8dd4l8Rgw1w/Tiiw' => "\x{2513}", # ┐ down and left
	'LyQsW4Gp5ktBCQuUjE9IgA' => "\x{2513}", # ┐ down and left
	'0M6MWhTiHi8HAp0cCwv31w' => "\x{2518}", # ┘ up and left
	'QcYerh2F7P3Kh26nvPDcCA' => "\x{2518}", # ┘ up and left
	'd2n1KZ5/6CBEs/EIeShrkQ' => "\x{250f}", # ┌ down and right
	'ib89yRpYE1EYPtyV+kHg0Q' => "\x{2599}", # └ up and right

	'WiLU3M7IYbOL7UPTJwNdYA' => "\x{251b}", # ┛ up and left bold
	'KVymYXMvvPTptNA3sP2Nkw' => "\x{2589}", # ┓ down and left bold

	'7lsSHMFnBZ0KdvmWnaUDzA' => "\x{2583}", # ▃ lower 3/8 block
	'/TD9f7zaCF17UyIsSp6J0g' => "\x{2585}", # ▅ lower 5/8 block
	'6OSbRijhYLgjkf9XghK3mQ' => "\x{2586}", # ▆ lower 3/4 block
	'Bo5uByV/34uw3exi3x9seQ' => "\x{259d}",
	'sbtXq8E/kkpPgrpaEV8kEA' => "\x{259f}",
	'2kDqyyE+NvOClm2niTq+hg' => "\x{250f}",
	'+56coRSg75PGNoOPFK2c4A' => "\x{259d}",

	'iSQAn5T+NQP9PoW5wmZCXw' => "\x{2590}", # ▐ left box
	'IFpcbLNbUXGljJ72cu4Xiw' => "\x{2590}", # ▐ left box

	'E/FjxJ1PaSCrbtKvT1tL4A' => "\x{25a0}", # ■ black square


	#'fGll4Og6rCVlT3DPemxLJg' => "\x{2596}", # ▖
	#'KVymYXMvvPTptNA3sP2Nkw' => "\x{259a}", # ▚
	#'lkEoniFV3vHUN/KRfgQE1g' => "\x{2590}", # ▐ left box
	#'jnANoReEIdj4M592Z8xs0A' => "\x{2501}", # ━ heavy horizontal
	#'E/FjxJ1PaSCrbtKvT1tL4A' => "\x{25a0}", # ■ black square
	#'7lsSHMFnBZ0KdvmWnaUDzA' => "\x{2584}", # ▄ lower half block
	#'Bo5uByV/34uw3exi3x9seQ' => "\x{259d}", # ▝ quadrant upper right
	#'Tlvc0t8dd4l8Rgw1w/Tiiw' => "\x{259f}", # ▟ quadrant

	# double height top
	'fYOs74EEjVCuNQxMtpVMgQ' => 'A',
	'eqpd4En/DjSmhCx9s9aKFw' => 'B',
	'JYWWtxZLmWHZ8PDMcCVrkw' => 'C',
	'30qRXmElH002y7cU6Krbww' => 'D',
	'N4FAJjvsKd+iOFtFTJ2pkw' => 'E',
	'Q4G5X7y/uBCkal4CjSEG/A' => 'F',
	'V5DyOdhyxzh39p8eNXYGFA' => 'G',
	'LbGuTJnf1XD3P3jYhJBvoA' => 'H',
	'8SL5svDI1yeBLw9rGR/v0A' => 'I',
	'A+KCwUVkm2juu/xkpCPUsw' => 'J',
	't1prlBTSxD4cR1cuZ0T4LQ' => 'K',
	'5YP2cB69pU/4+eTPjqJKLw' => 'L',
	'DoHxXW4Ihs472/a21PFpDQ' => 'M',
	'DVon5vsiACP8bAn7AC3W9g' => 'N',
	'8LqlR9pGskDY05N1ZiaTiw' => 'O',
	'yOwxjDOj0EshRCCs18T2lw' => 'P',
	# Q
	'2vkPNmRwiuRuT7yqJxnOYw' => 'R',
	'N7fS0emWoLyOET11bxwHKg' => 'S',
	'iGnZmibdFf7cZR68Jv9o2Q' => 'T',
	'IHY1fODHkyZHBg2pEf5Cmw' => 'U',
	'vA0Xt6R3taIXCWGMT5G+AA' => 'V',
	'1hxVLiphabl8qFYgy1xQNg' => 'W',
	# X
	# Y
	# Z
	'uF/gJmhC+YzwWqhlZtpQbQ' => 'a',
	'BA7tBX8CD5Yddo0iMnpQgA' => 'b',
	'zM+0vUmDcGeKOLN2pXMjoA' => 'c',
	'6WxjxtDW76YwCH0+mFSwFw' => 'd',
	'7DSQcgDjZ5hmtdqO2x85oA' => 'e',
	'F0FTG11lOyCPR0ZgArTuTQ' => 'f',
	'Y9Ym+A1qrY835lxFYsR2eQ' => 'g',
	'dNUfCMg0r1gEgqW1rmnEdw' => 'h',
	'bylagXiW89dNyHfic6nFdQ' => 'i',
	've1KvCB6bT5hxZPuuRQOnA' => 'j',
	'+nxaMmBP4Y811h1mhlJzFw' => 'k',
	'dUIk5/E5JJbw0NVCN4CPkA' => 'l',
	'DSFORK66n56uMNZJpcGRGg' => 'm',
	'WU2O/ZR32bnrN5mh3Z2L8A' => 'n',
	'Aw+ebkYR5bMVLgXaHHRs7w' => 'o',
	'R3FomhLXnpcvolLoIFmCbg' => 'p',
	# q
	'cUbJ7qShe5vkuJ8bZijuGA' => 'r',
	'6KLyE65WADlr7+rpF9lQNA' => 's',
	'lYnQ5tmdPGqdPOgMH8SkKQ' => 't',
	'ja7yFcNzpf3RNjt5phOABw' => 'u',
	'QUl/Qwm5wx7LV5jL9IWXCw' => 'v',
	'9aVQcR3ZCf3LAX/ACUdRUA' => 'w',
	# x
	'tfIZmSt82AE51g+//alCuw' => 'y',
	'mko3GKLIFnQOoSH1v59Qrw' => 'z',
	'NFdMgZAszxkn3nVbFKRSIQ' => '1',
	'apS+EAKKu9AF05WG/xgmOg' => '2',
	'OANB4oesWbWepCM1FxqAfA' => '3',
	'k+EvxEMLy2MsV6Np6PXR+w' => '4',
	# 5
	'2jLVefWXERE2DgzGIUFcdA' => '6',
	# 7
	'dBKGqWiPvdi6fbbeuasqJA' => '8',
	# 9
	'kyMsBMYIrCxzyfOZrCoVyA' => '0',
	'H2uFubmvaONJFAnXGX1/7Q' => '"',
	'qld8w1/Wl6DrY0OAybDHrw' => ':',
	'PhkK/rakXmU0i2NNxZ03XQ' => '-',
	'iiJrpKbqoce9hmfbT/x/WA' => "\x{eb}", # ë

	# double height bottom
	'NwxPqWhvL+a2SVHzVBdgvw' => ' ', # A
	'KTCF05zNjd7zxpHGtVKwXg' => ' ', # B
	'lN+qGwBDZNqnP+BDYTBpmQ' => ' ', # C
	'codXG3zhYhXKDeT4EK6Abw' => ' ', # D
	'0qFBlnEO7MMDU6OHq97g/Q' => ' ', # E
	'nUKQ4cFdYH0iORUf5SBJMw' => ' ', # F (?)
	'x0HCLQhFPPxYIUJHIlNzyQ' => ' ', # G
	'wDQsTen8LR53pjjKx7h4zg' => ' ', # H
	'n6kAv9SRGrpD7IuDJbtYmg' => ' ', # I
	'uZGyCOiZDCfG1sUEn1qRUA' => ' ', # J
	'axYsVgPCNdH8drrrpjT4xg' => ' ', # K
	'bQpmN/KtfpGO/i/ZpEFJig' => ' ', # L
	'KQOK3wW4ao+b6zeOlqUK8A' => ' ', # N
	'axWlA6K3tNH5K/8zYvrVrA' => ' ', # M (inverse)
	'vDiSf6e/xemQdRnq80joyg' => ' ', # O (inverse)
	'/qa6OkzeBqZ1C2lYMt1Fjg' => ' ', # P
	'chpPR17D1Vibzd8aeypfcA' => ' ', # R
	'WqXadYPmuvzCKcZ1h4eIkA' => ' ', # S
	'nUKQ4cFdYH0iORUf5SBJMw' => ' ', # T
	'XgS036gVcYSzOS6tF7uUZg' => ' ', # U
	'NPrtpFfF8IZcdeUlc1DwzA' => ' ', # V
	'h1KdBg2lR+DjY2gfWMdWig' => ' ', # W
	'0m+2/w2ZAvLn6ak9waINng' => ' ', # a
	'BsPG0uz6Ho5eGgSBh9xXYA' => ' ', # b
	'qDH8ZAy5H5yRgn/PrHE4uw' => ' ', # c
	'57s8JlAtXtPSZrhrM+DB0A' => ' ', # d
	'h8HytxWG1m3eOTA67KiUTQ' => ' ', # e
	'ea+uerauSPLnFeO+QxbGmg' => ' ', # f
	'eqpoAdqev/htw8jUM2aXTQ' => ' ', # g
	'P0rRZ5RWlAGEuY0kZU6vLQ' => ' ', # h, same a n
	'Lu+Wfqw4rKVMslkFMurM/A' => ' ', # i
	'/t6fnf6zdlyQutO6XloITg' => ' ', # j
	'Ygb6i1+aJBtJx/CaccDvSA' => ' ', # k
	'CuWWBFombHCpCX42gT3RxQ' => ' ', # m (inverse)
	'P0rRZ5RWlAGEuY0kZU6vLQ' => ' ', # n, same as h
	'x36O4fXo4I02k49zTgAPiw' => ' ', # o
	'rDPjVEcYcXsxpickOL5NFQ' => ' ', # p
	'j0/6i432gm7wJIieX4O3aQ' => ' ', # r
	'3SYsMKQVstvhUJ7e8XaOsw' => ' ', # s
	'pyJytEfbhCf++SvXiByxHg' => ' ', # t
	'LJwaQdUsnp050BaSRp6t9Q' => ' ', # u
	'6E4tP+spqSpEs11xJB1cAA' => ' ', # v
	'UmZsnM9lWmz9D0Kl8maMJA' => ' ', # w
	'sEVjAGQ6GlwofZkYkOPGpg' => ' ', # y
	'1r4OzvfYSWdGZ1Hn0KUcnQ' => ' ', # z
	'2AQdFKmzlJrmO6ZMUqhRGA' => ' ', # 1
	'ogzRTLIRl7BiAaJDvuRHtQ' => ' ', # 2
	'OXZzYKjCadEmTaLOjVMTpw' => ' ', # 3
	'm0cboPENe9kLt4kxbTDFFw' => ' ', # 8
	'lx9BQfJE6OzCyqMpIRvRpQ' => ' ', # 0
	'E0JW3xWti6sV400J48qygA' => ' ', # :
	'4p+S2OkLey9psZHFUhTs2g' => ' ', # -

);

my $UNKNOWN = "\x{25af}"; # ▯

sub debug 
{
	return;
	my $level = shift;
	return if $level > 0;
	print @_, "\n";
}


# main
{
	my %all_chars;
	my %all_colours;


	my $image = fetch_page($ARGV[0]) or die;
	my $chars = split_image($image);
	print print_page($chars);
	exit;

	for my $p (100..130)
	{
		print "Processing page $p\n";
		my $image = fetch_page($p) or next;
		my $chars = split_image($image);

		uniquify(\%all_chars,\%all_colours,$chars);
	}
	

	print_colours(keys %all_colours);
	exit;

	#print Dumper { %all_chars };
	for my $ch (values %all_chars)
	{
		print $ch->{id},"\n";
		print char2str($ch), "\n";
		print "\n";
	}
	printf(qq['%s' => ''\n],$_->{id})  for (values %all_chars)

}

sub fetch_page
{
	my $page = shift or die;
	my $subpage = 1;

	debug(0,"Fetching page $page/$subpage");

	my $url = sprintf($URL,$page,$subpage);
	my $content = get($url) or return;

	my ($fh,$filename) = tempfile( 'ttXXXXXX', TMPDIR=>1, UNLINK=>1 );
	binmode($fh,':bytes');
	print $fh $content;
	close $fh;

	debug(1,"Wrote image to `$filename'");

	my $image = Image::Imlib2->load($filename);
	unlink $filename;

	debug(1,"Loaded image from file");

	return $image
}

sub split_image
{
	my $image = shift or die;

	debug(0,"Splitting image");

	die unless $image->width  == NUM_COLS * CHAR_WIDTH;
	die unless $image->height == NUM_ROWS * CHAR_HEIGHT;

	my $chars = [];

	# iterate over chars
	for (my $y=0; $y<NUM_ROWS; $y++)
	{
		for (my $x=0;$x<NUM_COLS; $x++)
		{
			debug(2,"  --> now at char ($x,$y)");

			# iterate over pixels in char
			my ($colour1,$colour2);
			my @char; # contains individual pixels
			my $str = ''; # contains bytestring to calc digest
			for (my $j=0; $j<CHAR_HEIGHT; $j++)
			{
				for (my $i=0; $i<CHAR_WIDTH; $i++)
				{
					# extract pixel
					my $pos_x = $x*CHAR_WIDTH  + $i;
					my $pos_y = $y*CHAR_HEIGHT + $j;
					my ($r,$g,$b,$a) = $image->query_pixel($pos_x,$pos_y);

					debug(4,"    - now at subpixel ($i,$j) --> ($r,$g,$b)");

					# should be 8bit, but ok...
					my $colour = ( $r<<16 | $g<<8 | $b );
					debug(4, sprintf("    - coluor #%06x",$colour));

					# save 2 colours and binary image
					if ($i==0 and $j==0) { $colour1 = $colour };
					if ($colour!=$colour1) 
					{ 
						# check that only 2 colours appear in char
						$colour2 = $colour  unless  $colour2;
						die unless $colour==$colour2;

						$char[$i][$j] = 1;
						$str .= '1';
					}
					else 
					{
						$char[$i][$j] = 0;
						$str .= '0';
					}
				}
			}

			my $id = md5_base64($str);

			# save this char.  Note: c2 can be undef
			$chars->[$x][$y] = {
				'c1'   => $colour1,
				'c2'   => $colour2,
				'char' => \@char,
				'str'  => $str,
				'id'   => $id,
			}
		}
	}

	return $chars;
}

sub uniquify
{
	my $all_chars   = shift or die;
	my $all_colours = shift or die;
	my $chars   = shift or die;

	# iterate over chars
	for (my $y=0; $y<NUM_ROWS; $y++)
	{
		for (my $x=0;$x<NUM_COLS; $x++)
		{
			my $char = $chars->[$x][$y];

			# record colors;
			$all_colours->{ $char->{c1} } = 1;
			$all_colours->{ $char->{c2} } = 1  if   $char->{c2};

			# record char
			my $id = $char->{id};
			$all_chars->{$id} = $char
		}
	}
}

sub print_char
{
	my $chars = shift or die;
	my $x = shift || 0;
	my $y = shift || 0;

	my $char = $chars->[$x][$y];

	printf "Colour1: #%06x\n", $char->{c1};
	printf "Colour2: #%06x\n", ($char->{c2} || 0);
	print char2str($char);
}

sub char2str
{
	my $char = shift or die;
	my $str = '';
	for (my $j=0; $j<CHAR_HEIGHT; $j++)
	{
		for (my $i=0; $i<CHAR_WIDTH; $i++)
		{
			my $ch = $char->{char}->[$i][$j] ? '#' : '.';
			$str .= $ch;
		}
		$str .= "\n";
	}
	return $str;
}

# calculate id of a character:
# create a string of 1's and 0's (ASCII 48 and 49) describing the pixels 
# of the character in LR-TB ordering.  
# No line separators.  First character is always '0'
# Final id is (base64-encoded) MD5 of the string.
sub char2id
{
	my $char = shift or die;
	my $str = '';
	for (my $j=0; $j<CHAR_HEIGHT; $j++)
	{
		for (my $i=0; $i<CHAR_WIDTH; $i++)
		{
			my $ch = $char->{char}->[$i][$j] ? '1' : '0';
			$str .= $ch;
		}
	}
	my $digest = md5_base64($str);
	return $digest;
}

sub print_colours
{
	my @colours = @_ or die;

	foreach my $c (sort {$a<=>$b} @colours)
	{
		printf "#%06x\n", $c;
	}
}

sub color
{
	my $c1 = shift or die;
	my $c2 = shift || 0;

	# map colors to 3-bit vt100 type colors
	my $fg = 0;
	$fg |= 1  if  (($c2>>16)&0xff) > 128;
	$fg |= 2  if  (($c2>> 8)&0xff) > 128;
	$fg |= 4  if  (($c2>> 0)&0xff) > 128;

	my $bg = 0;
	$bg |= 1  if  (($c1>>16)&0xff) > 128;
	$bg |= 2  if  (($c1>> 8)&0xff) > 128;
	$bg |= 4  if  (($c1>> 0)&0xff) > 128;

	my $ansi = sprintf( "\e[%i;%im", 30+$fg, 40+$bg );
	return $ansi;
}

sub color_reset
{
	return "\e[0m";
}

sub print_page
{
	my $chars = shift or die;

	my %unknowns;

	my $str = '';
	for (my $y=0; $y<NUM_ROWS; $y++)
	{
		for (my $x=0;$x<NUM_COLS; $x++)
		{
			my $id = $chars->[$x][$y]->{id};
			my $c1 = $chars->[$x][$y]->{c1};
			my $c2 = $chars->[$x][$y]->{c2};

			$str .= color($c1,$c2);

			if (exists $CHARMAP{$id})
			{
				$str .= $CHARMAP{$id};
			}
			else
			{
				$str .= $UNKNOWN;

				if (not exists $unknowns{$id})
				{
					print "Unknown char at pos ($x,$y):\n";
					print "'$id' => '',\n";
					print char2str( $chars->[$x][$y] );
					print "\n";

					$unknowns{$id} = 1;
				}
			}
		}
		$str .= color_reset();
		$str .= "\n";
	}

	return $str;
}


__END__
