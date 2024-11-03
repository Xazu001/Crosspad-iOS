/*
 
 Copyright 2014 Takashi Mizuhiki
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "ViewController.h"
#import "WebViewDelegate.h"
#import "MIDIDriver.h"

@interface ViewController () <WKNavigationDelegate>
@property (nonatomic, strong) MIDIDriver *midiDriver;
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation ViewController


- (void)loadURL:(NSURL *)url
{
    // Load URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

#pragma mark -
#pragma mark View action handlers

- (void)onEditingDidEnd:(UITextField *)field
{
    [self loadURL:[NSURL URLWithString:field.text]];
}


#pragma mark -
#pragma mark View initializers

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Ukryj navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    _midiDriver = [[MIDIDriver alloc] init];
    
    // Utwórz konfigurację dla WebView z użyciem MIDIDriver
    WKWebViewConfiguration *configuration = [MIDIWebView createConfigurationWithMIDIDriver:_midiDriver sysexConfirmation:^(NSString *url) { return YES; }];

    // Utwórz WebView z konfiguracją
    MIDIWebView *webView = [[MIDIWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webView.scrollView.bounces = NO; // Wyłącz efekt przeciągania
    [self.view addSubview:webView];

    // Przypisz WebView do właściwości webView w ViewController
    self.webView = webView;

    // Dodaj widok ładowania
    UIView *loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    loadingView.backgroundColor = [UIColor blackColor];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    activityIndicator.center = loadingView.center;
    [activityIndicator startAnimating];
    [loadingView addSubview:activityIndicator];
    [self.view addSubview:loadingView];
    self.loadingView = loadingView;

    // Ustaw delegata WebView, aby usunąć widok ładowania po załadowaniu strony
    webView.navigationDelegate = self;

    // Otwórz określony URL
    NSURL *specificURL = [NSURL URLWithString:@"https://crosspad.app/mobile"];
    NSURLRequest *request = [NSURLRequest requestWithURL:specificURL];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.loadingView removeFromSuperview];
}

@end
