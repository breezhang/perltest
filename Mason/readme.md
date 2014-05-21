1. TT is language-agnostic, and works well even in languages where whitespace matters.

2. TT provides heavy customization callbacks at each level of processing

3. TT has an embedded language that hides the difference between hashes and method calls 
so dumb hashes can be turned into smart objects later

4. TT plays well outside mod_perl as a static transformation tool (or even in CGI)

5. Mason has better "out of the box" caching, but TT has all the right hooks to write your own easily, 
probably better for real applications anyway

6. TT permits Embedded Perl to be turned off or on for a given input source, 
useful in an enviroment where full Perl interface would be dangerous or misleading

7. embedded TT triggers can be changed to suit the parsed language, 
and for HTML be selected so as to get into and out of WYSIWYG HTML wranglers without mangling

