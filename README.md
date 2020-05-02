[![View CONST structure on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/45636-const-structure)

[![Donate to Rody](https://i.stack.imgur.com/bneea.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4M7RMVNMKAXXQ&source=url)

# FEX-const

MATLAB's flexible nature is very convenient in most situations. However, this flexibility can also be the cause of hard-to-find bugs.
In many cases, it is desirable to have a data type which is CONST. That is, a datatype which cannot be changed after the first assignment. MATLAB has seen heavy criticism due to its lack of a CONST data type. Although the basic functionality of CONST variables can be achieved through a class with constant properties, that approach leaves much to be desired.

That is where this file comes in. It implements all the functionality of a basic, scalar MATLAB structure, but after a field has been added and assigned a value, that field can no longer be changed.

That means, it strikes a middle ground by offering the flexibility of adding fields dynamically, but disallowing *changing* of fields values.

A simple example session:

C = const; % empty const
C.myField = 'test'; % first assignment; OK
C.myField = 4; % ERROR!

Much more is possible; have a look at the function documentation inside const.m for more information.

If you like this work, please consider [a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4M7RMVNMKAXXQ&source=url).
