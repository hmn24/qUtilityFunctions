\d .util

// To convert strings/symbols
toString: {$[not type x; .z.s each x; 10h = abs type x; x; string x]};
toSymbol: {$[11h = abs type x; x; `$ toString x]};

// General/dynamic un-enumeration function 
unenumSyms: {
    ty: type x;
    $[not ty;                                   // Mixed lists
            .z.s each x; 
        abs[ty] in 20 21h;                      // Unenum enumerated syms
            value x; 
        98h = ty;                               // Tables
            flip .z.s each .Q.V x;
        99h = ty;                               // Dictionaries/Keyed Tables
            $[98h = type key x; .z.s[key x]!.z.s[value test]; .z.s each x]; 
        x                                       // Others -- Std. Recursion Base
    ]
 };

// Formatting Error Message
formatErr: {.Q.dw "<ERROR> ", x, "\n";()};

// Set default variables
setDefault: {x set @[value; x; y]};

// Inverse hsym
sliceColon: {(":" = first x) _ x};
hsymInv: {(sliceColon toString ::) each x};

// Run system commands -- No args limit 
/ E.g: [.util.sysCmd[`f;`.a] | .util.sysCmd[`f] | .util.sysCmd[`timeout;1]]  
sysCmd: {@[system; " " sv "" ,/: toString $[1 < count x; x; first x]; formatErr]} enlist ::;

// Check if its a File/Directory
isFileDir: {$[not type keyPath: key hsym toSymbol x; `; keyPath ~ x; `file; `dir]};

isQKFile: {$[`file = isFileDir x; x like "*.[qk]"; 0b]};

// Load a script
loadScript: {if[(::) ~ sysCmd[`l;x]; -1 "Loaded ", x, " successfully!"]};

// Load all q/k files within a directory (incl. subdirectories)
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