ASXMLParser
==============

ASXMLParser is based on Andrew Snowdens (https://github.com/andrewsnowden) java XML parser.

To use, 

call +(ASXMLParser*) parse:(NSString*) aData;

You will be returned an ASXMLParser which contain tags, attributes and data.
Use the findTag/findAttribute methods to find various nested xml tags or attributes.

You can also convert ASXMLParser objects back in to XML.


