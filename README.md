# QUtilityFunctions

Utility scripts to use in KDB processes

###  A) qscripts/util_depTree.q

**User Guide:**

i) Display of all functions within q instance

__Example:__

```
.util.getAllFns[]
```

ii) Display of all tables within q instance

__Example:__

```
.util.getAllTabs[]
```

iii) Tracing of Function Dependency Trees

__Example:__

```
@param  addFilter   {boolean}           Specifies if additional filter of "[(/[') ;@.]" to be appended to the regex specified
@param  isCase      {boolean}           Specifies if case sensitivity to the regex shall be applied
@param  regex       {symbol/string}     Regex to match the function spaces for  
```

```
.util.genDepTree[1b;1b;`.util.baseNS]
```

<br><br/>

### B) qscripts/util_html.q


**User Guide:**


i) Generation of verbose table meta information, i.e. dictionary of meta tables

__Example:__ 
```
.util.getTabMeta[]
```

__Additional Note:__

```
.util.writeXlsTab[\`test] to write the dictionary of meta tables generated above in xls format 
```

ii) Reverse xml (xls) files generated by q .h.edsn

__Example:__ 
```
.util.reverseEdsn[`test.xls]
```
<br><br/>

### C) HTML interface to utilise the various utility function above


**Initialisation Steps:**

i) q html_startup.q

Initialises the q process with the relevant qutils scripts above, as well as initialise a standard port number of 5014

ii) Click on either html/qutils_meta.html or html/qutils_tree.html

This would load the relevant html pages for one to use the functions defined above easily


