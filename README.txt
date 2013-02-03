In januari 2013, the Dutch public broadcasters decided to kill the tekst-baed
teletext service they were offering on http://nos.nl/teletekst.  Since then,
only a graphical version has been available, which is pretty useless for
anything except reading from a graphical browser.  And, really, if you have  a
graphical browser open to read the news, who on Earth would you prefer
Teletekst over, say, nu.nl, the BBC, or any of the local Dutch newspapers?!

Therefore, I decided to bring back text-based teleTEXT.  This is not as hard
as it might seem, as the images offered by the NOS site are rendered in a
fixed bitmap font.  Therefore, the only thing needed is some kind of
pixel-matching algorithm, and a mapping from each pixel pattern to the
corresponding Unicode character.  So, that's exactly what I've built.

The current code is a bit of a mess, but hey, it does the job.  It's written
in perl, currently (using Imlib2 for some image processing).  The image
processing isn't very much optimized, and thus the script isn't very fast
(takes ~1s to parse and display a page on my laptop).  I'll probably optimize
this a bit lateron.  My first goal, though, is to get the character mapping
complete.  

So, have fun!


Copyright (c) 2013, Bas Zoetekouw
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), but subject
to the ecpetions decribed below, to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

As an exception, these permissions are NOT granted to anyone employed by, or
any organisation that is part of, any of the Dutch public broadcasters, or any
of its associated organisations and companies.



TODO/Known bugs:
 - Character mapping is incomplete
 - Character mapping for boxes and line drawing characters is inconsistent
 - Some characters (in particular, those whose top-left pixel is not part of
   the background) are shown in reverse colours.
 - Character mapping for double-height characters is incomplete
 - Double-height character support is flakey
 - Parsing a page is slow as hell
 - Subpages are not supported
 - Need to iumplemente "page nog found" messages
