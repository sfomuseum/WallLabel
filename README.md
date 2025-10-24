# WallLabel

Swift package for deriving structured data for museum wall label text using on-device machine learning (large language) models.

## Motivation

This is a Swift package for deriving structured data for museum wall label text using on-device machine learning (large language) models. It was extracted from the [sfomuseum/Registrar](https://github.com/sfomuseum/Registrar) package in order to make it is easier to develop new parsers and to test existing ones independent of a GUI-based application..

## Usage

```
import Logging
import WallLabel

let parser_uri = "mlx://?model=llama3.2:1b"
let label_text = "YOUR LABEL TEXT HERE"

let logger = Logger(label: "org.sfomuseum.wall-label")

var label_parser: Parser
        
do {
	label_parser = try NewParser(parser_uri: parser_uri, logger: logger)
} catch {
	// throw error here...
}
        
let parse_rsp = await label_parser.parse(text: label_text)
        
switch parse_rsp {
case .success(let label):
	// do something with label here
case .failure(let error):
	// throw error here
}	
```

## Parsers


## Tools

### wall-label

```
$> wall-label parse -h
OVERVIEW: Parse the text of a wall label in to JSON-encoded structured data.

USAGE: wall-label parse [--parser_uri <parser_uri>] [--label_text <label_text>] [--verbose <verbose>]

OPTIONS:
  --parser_uri <parser_uri>
                          The parser scheme is to use for parsing wall label text. (default: mlx://?model=llama3.2:1b)
  --label_text <label_text>
                          The label text to parse in to structured data.
  --verbose <verbose>     Enable verbose logging (default: false)
  -h, --help              Show help information.
```

#### Building

The easiest thing to do is use the handy `cli` Makefile target. Note that it is necessary to build the `wall-label` command line tool with `xcodebuild` rather than `swift build`. This is because of the need to compile the tool with the Apple "Metal" dependencies.

```
$> make cli
xcodebuild build -scheme wall-label -destination 'platform=OS X'
Command line invocation:
    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -scheme wall-label -destination "platform=OS X"

Resolve Package Graph
2025-10-24 13:08:51.189 xcodebuild[11565:1131787] [MT] IDERunDestination: Supported platforms for the buildables in the current scheme is empty.

...All kinds of build gibberish and other output
```

This will build the `wall-label` tool in a folder called `{YOUR_HOMEDIR}/Library/Developer/Xcode/DerivedData/WallLabel-{SOME_RANDOM_STRING}/Build/Products/Debug/`. This is probably the correct thing to do from an overall security perspective but it's still kind of annoying since that path is not explicitly called out at the end and you have to fish around for it in the build gibberish. Oh well...

#### Example

```
$> {YOUR_HOMEDIR}/Library/Developer/Xcode/DerivedData/WallLabel-{SOME_RANDOM_STRING}/Build/Products/Debug/wall-label parse \
   	--parser_uri 'mlx://?model=llama3.2:1b' \
	--label_text 'Promotion, Chiat/ Day: Effective Brick Design Director: Tibor Kalman (American, b. Hungary, 1949–1999); Firm: M&Co (United States); USA offset lithography Gift of Tibor Kalman/ M & Co. Cooper Hewitt Smithsonian National Design Museum 1993-151-257-1' \

| jq

{
  "longitude": 0,
  "input": "Promotion, Chiat/ Day: Effective Brick Design Director: Tibor Kalman (American, b. Hungary, 1949–1999); Firm: M&Co (United States); USA offset lithography Gift of Tibor Kalman/ M & Co. Cooper Hewitt Smithsonian National Design Museum 1993-151-257-1",
  "date": "1993",
  "creator": "Tibor Kalman (American, b. Hungary, 1949–1999)",
  "creditline": "Cooper Hewitt Smithsonian National Design Museum",
  "accession_number": "151-257-1",
  "timestamp": 1761336687,
  "latitude": 0,
  "location": "1993-151-257-1",
  "title": "Effective Brick",
  "medium": "offset lithography"
}
```

Note that some models will still return JSON wrapped in Markdown. For example, using the `qwen2.5:1.5b` model:

```
$> {YOUR_HOMEDIR}/Library/Developer/Xcode/DerivedData/WallLabel-{SOME_RANDOM_STRING}/Build/Products/Debug/wall-label parse \
   	--parser_uri 'mlx://?model=qwen2.5:1.5b` \
    --verbose=true \       
	--label_text 'Promotion, Chiat/ Day: Effective Brick Design Director: Tibor Kalman (American, b. Hungary, 1949–1999); Firm: M&Co (United States); USA offset lithography Gift of Tibor Kalman/ M & Co. Cooper Hewitt Smithsonian National Design Museum 1993-151-257-1' \

| jq

2025-10-24T13:14:17-0700 debug org.sfomuseum.wall-label: [WallLabel] Load model qwen2.5:1.5b
2025-10-24T13:14:17-0700 debug org.sfomuseum.wall-label: [WallLabel] Load model (qwen2.5:1.5b) from source
2025-10-24T13:14:23-0700 debug org.sfomuseum.wall-label: [WallLabel] Loading model qwen2.5:1.5b 100.0% completed
2025-10-24T13:14:30-0700 debug org.sfomuseum.wall-label: [WallLabel] INFO GenerateCompletionInfo(promptTokenCount: 404, generationTokenCount: 105, promptTime: 0.22025799751281738, generateTime: 1.4748320579528809)
2025-10-24T13:14:30-0700 debug org.sfomuseum.wall-label: [WallLabel] DONE ```json
{
  "title": "Promotion",
  "date": "",
  "creator": "Chiat/ Day",
  "creditline": "Director: Tibor Kalman (American, b. Hungary, 1949–1999); Firm: M&Co (United States)",
  "location": "",
  "medium": "",
  "accession_number": "1993-151-257-1",
  "input": ""
}
```
Error: dataCorrupted(Swift.DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: Optional(Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character '`' around line 1, column 1." UserInfo={NSDebugDescription=Unexpected character '`' around line 1, column 1., NSJSONSerializationErrorIndex=0})))
```

