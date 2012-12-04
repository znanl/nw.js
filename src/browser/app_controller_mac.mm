// Copyright (c) 2012 Intel Corp
// Copyright (c) 2012 The Chromium Authors
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell co
// pies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in al
// l copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IM
// PLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNES
// S FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WH
// ETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "base/command_line.h"
#include "content/nw/src/api/app/app.h"
#import "content/nw/src/browser/app_controller_mac.h"
#include "content/nw/src/browser/standard_menus_mac.h"
#include "content/nw/src/nw_package.h"
#include "content/nw/src/nw_shell.h"
#include "content/nw/src/shell_browser_context.h"
#include "content/nw/src/shell_browser_main_parts.h"
#include "content/nw/src/shell_content_browser_client.h"

@implementation AppController

- (BOOL)application:(NSApplication*)sender
           openFile:(NSString*)filename {
  if (nw::Shell::windows().size() == 0) {
    CommandLine::ForCurrentProcess()->AppendArg([filename UTF8String]);
    return TRUE;
  }

  // Just pick a shell and get its package.
  nw::Package* package = nw::Shell::windows()[0]->GetPackage();

  if (package->self_extract()) {
    // Let the app deal with the opening event if it's a standalone app.
    api::App::EmitOpenEvent([filename UTF8String]);
  } else {
    // Or open a new app in the runtime mode.
  }

  return FALSE;
}

- (void) applicationDidFinishLaunching: (NSNotification *) note {
  // Initlialize everything here
  content::ShellContentBrowserClient* browser_client = 
      static_cast<content::ShellContentBrowserClient*>(
          content::GetContentClient()->browser());
  browser_client->shell_browser_main_parts()->Init();

  // And init menu.
  [NSApp setMainMenu:[[[NSMenu alloc] init] autorelease]];
  [[NSApp mainMenu] addItem:[[[NSMenuItem alloc]
      initWithTitle:@"" action:nil keyEquivalent:@""] autorelease]];
  nw::StandardMenusMac standard_menus(
      browser_client->shell_browser_main_parts()->package()->GetName());
  standard_menus.BuildAppleMenu();
  standard_menus.BuildEditMenu();
  standard_menus.BuildWindowMenu();
}

@end
