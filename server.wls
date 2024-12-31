Print @ "Wolfram Expression Server 0.0.1 (alpha)";

Print @ "Usage: wolframserver.wls [port]\n";

If[Length[$ScriptCommandLine] == 2,
    port = ToExpression @ Part[$ScriptCommandLine, 2]
    ,
    port = 5860
];

Print["Port:       ", port];

Print["$ProcessID: ", $ProcessID];

$TemporaryOutput = {$TemporaryDirectory, "WolframKernelOutput"} // FileNameJoin;

If[# //
    DirectoryQ //
    Not,
        # // CreateDirectory
    ]& @ $TemporaryOutput;

WolframPlayer[box_, text_String] :=
    {
        "wolframplayer"
        ,
        Export[
            {$TemporaryOutput, CreateUUID["CDFOutput-"] <> ".cdf"} //
                 FileNameJoin
            ,
            Notebook[
                {
                  (* text //
                    ToExpression[#, StandardForm, Defer]& //
                    ToBoxes //
                    BoxData //
                    Cell
                    ,  *)
                    box //
                    ToBoxes //
                    BoxData //
                    Cell
                }
                ,
                WindowSize -> All
            ]
            ,
            "CDF"
        ]
        ,
        "&"
    } //
    StringRiffle //
    Run

ApacheDateString[] :=
    With[{tz = StringReplace[DateString["ISOTimeZone"], ":" -> ""]},
        DateString[{"[", "Day", "/", "Month", "/", "Year", ":", "Hour",
             ":", "Minute", ":", "Second", " ", tz, "]"}]
    ];

ApacheLog[str_String] :=
    Module[{},
        Print["127.0.0.1 - - " <> ApacheDateString[] <> " \"POST / HTTP/1.1\" 200 "
             <> StringTrim[str]]
    ];

(* 创建一个标记文件来表示服务器正在运行 *)
flagFile = FileNameJoin[{$TemporaryDirectory, "server-running.flag"}];
WriteString[flagFile, "1"];

listener =
    SocketListen[
        port
        ,
        Function[{assoc},
            With[{client = assoc["SourceSocket"], data = assoc["Data"
                ]},
                request = ImportString[data, "HTTPRequest"];
                origin = Association[request["Headers"]]["origin"];
                If[Head[origin] === Missing,
                    origin = ""
                ];
                calResult = request["Body"] // ToExpression[#, StandardForm
                    ]&;
                result =
                    calResult //
                    ToBoxes //
                    BoxData //
                    ToString;
                calResult // WolframPlayer[#, request["Body"]]&;
                response = ExportString[HTTPResponse[result, <|"StatusCode"
                     -> 200, "ContentType" -> "application/json", "Headers" -> {"Access-Control-Allow-Origin"
                     -> origin}|>], "HTTPResponse"];
                WriteString[client, response];
                ApacheLog[request["Body"]];
                Close[client]
            ]
        ]
    ];

url = URLBuild[<|"Scheme" -> "http", "Domain" -> First[listener["Socket"
    ]["DestinationIPAddress"]], "Port" -> listener["Socket"]["DestinationPort"
    ]|>];

Print["Listening:  ", url, "\n"];

(* 简单循环保持服务器运行 *)
While[FileExistsQ[flagFile],
    Pause[1]
];

Print["Exiting..."];

(* 清理工作 *)
If[FileExistsQ[flagFile],
    DeleteFile[flagFile]
];
