#OTHTTPRequest

A very light lib for http request.  

* Based on NSURLConnection
* Resume broken HTTP download
* Auto retry download for several times
* Average upload/download speed calculation
* Easy to install
* Delegate and block callback
* CPU time shorter than ASIHTTPRequest, both upload and download

<img src="https://raw.githubusercontent.com/OpenFibers/OTHTTPRequest/master/demo.png" alt="demo" width="487">

## How to install

1. Copy **OTHTTPRequest** to your project.
2. Add **MobileCoreServices** frame work to your target.

If you need to support ancient OS : iOS4.3 and OSX10.7.x, use v1.0, otherwise use the latest version.

## How to use

#### Get request

```objective-c
OTHTTPRequest *request = [[OTHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com"]];
request.delegate = self;
request.getParams = @{@"gws_rd": @"ssl"};
[request start];
```

#### Post request

```objective-c
OTHTTPRequest *request = [[OTHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com"]];
request.delegate = self;
request.postParams = @{@"gws_rd": @"ssl"};
[request start];
```

#### Upload request
```objective-c
OTHTTPRequest *request = [[OTHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com"]];
request.delegate = self;
request.postParams = @{@"gws_rd": @"ssl"};
[request addFileForKey:@"file" filePath:filePath fileName:@"Default.png" MIMEType:nil];
[request start];
```

#### Download request
```objective-c
OTHTTPDownloadRequest *request = [[OTHTTPDownloadRequest alloc] initWithURL:downloadURLString
                                                cacheFile:cacheFilePath
                                         finishedFilePath:finishedFilePath];
request.delegate = self;
[request start];
```

## License

Under MIT License.
