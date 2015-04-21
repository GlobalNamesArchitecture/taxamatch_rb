taxamatch_rb
============

[![Gem Version][1]][2]
[![Continuous Integration Status][3]][4]
[![Dependency Status][5]][6]

`taxamatch_rb` is a ruby implementation of Taxamatch algorithms
[developed by Tony Rees][7]:

The purpose of Taxamatch gem is to facilitate fuzzy comparison of
two scientific name renderings to find out if they actually point to
the same scientific name.

```Ruby
require 'taxamatch_rb'
tm = Taxamatch::Base.new
tm.taxamatch('Homo sapien', 'Homo sapiens') #returns true
tm.taxamatch('Homo sapiens Linnaeus', 'Hommo sapens (Linn. 1758)') #returns true
tm.taxamatch('Homo sapiens Mozzherin', 'Homo sapiens Linnaeus') #returns false
```

`taxamatch_rb` is compatible with ruby versions 1.9.1 and higher

Installation
------------

    sudo gem install taxamatch_rb

Usage
-----

    require 'taxamatch_rb'

    tm = Taxamatch::Base.new

* compare full scientific names

    tm.taxamatch('Hommo sapiens L.', 'Homo sapiens Linnaeus')

* preparse names for the matching (necessary for large databases of scientific names)

    p = Taxamatch::Atomizer.new
    parsed_name1 = p.parse('Monacanthus fronticinctus Günther 1867 sec. Eschmeyer 2004')
    parsed_name2 = p.parse('Monacanthus fronticinctus (Gunther, 1867)')

* compare preparsed names

    tm.taxamatch_preparsed(parsed_name1, parsed_name2)

* compare genera

    tm.match_genera('Monacanthus', 'MONOCANTUS')

* compare species

    tm.match_species('fronticinctus', 'frontecinctus')

* compare authors and years

    Taxamatch::Authmatch.authmatch(['Linnaeus'], ['L','Muller'], [1786], [1787])


You can find more examples in spec section of the code

Copyright
---------

Copyright (c) 2009-2015 Marine Biological Laboratory. See LICENSE for details.

[1]: https://badge.fury.io/rb/taxamatch_rb.png
[2]: http://badge.fury.io/rb/taxamatch_rb
[3]: https://secure.travis-ci.org/GlobalNamesArchitecture/taxamatch_rb.png
[4]: http://travis-ci.org/GlobalNamesArchitecture/taxamatch_rb
[5]: https://gemnasium.com/GlobalNamesArchitecture/taxamatch_rb.png
[6]: https://gemnasium.com/GlobalNamesArchitecture/taxamatch_rb
[7]: http://www.cmar.csiro.au/datacentre/taxamatch.htm
