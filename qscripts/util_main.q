\d .util

// Function to convert strings/symbols
toString: {$[not type x; .z.s each x; 10h = abs type x; x; string x]};
toSymbol: {$[11h = abs type x; x; `$ toString x]};

// Formatting Error Message
formatErr: {-1 "<ERROR> ", x;()};

// Set default variables
setDefault: {x set @[value; x; y]};

// Inverse hsym
sliceColon: {(":" = first x) _ x};
hsymInv: {(sliceColon toString ::) each x};

// Run system commands, e.g. .util.sysCmd[`f;`.a]
sysCmd: {@[system; raze toString (x;" ";y); formatErr]};

// Check if its a File/Directory
isFileDir: {$[not type keyPath: key hsym toSymbol x; `; keyPath ~ x; `file; `dir]};

isQKFile: {$[`file = isFileDir x; x like "*.[qk]"; 0b]};

// Load a script
loadScript: {if[(::) ~ sysCmd[`l;x]; -1 "Loaded ", x, " successfully!"]};

// Load a specific directory
loadDir: {[path]
    path: hsym toSymbol path;
    if[`dir = isFileDir path;
        keyPath: .Q.dd/:[path; key path];
        if[count keyPath;
            boolFlag: where isQKFile each keyPath;
            loadScript each hsymInv keyPath @ boolFlag;
            .z.s each keyPath @ not boolFlag; 
        ]
    ]
 };

\d .