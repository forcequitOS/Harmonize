# Playcuts.
### Bridge your Swift Playgrounds Apps to everyone's favorite mobile scripting system (Or anything.)

![Playcuts displaying a pairing code (8098) UI with the subtitle "Shortcuts Setup"](https://github.com/forcequitOS/Playcuts/blob/main/playcuts.png?raw=true)

**Why?** You can't use App Intents within Swift Playgrounds.

**How?** Hosting a server which awaits an HTTP POST request and then handles this data to pass to your app.

**When?** Probably never.

**Who?** Me.

**Where?** Your iPad.

**What?** Playcuts is a Swift Package that handles UI, security, and other boring stuff you wouldn't want to bother with when integrating an App Intents-like solution in your app.

Limitations:
1. The server will eventually be killed in the background by iOS, no getting around that (However I do notice it honestly takes quite a while before this happens, in my testing.)
2. Only one app can use Playcuts at a time (Unless apps all specify a specific port number they want to use, which Playcuts will support in the future if I care enough to update it)
3. Playcuts kinda breaks if you use it on multiple iPads, due to pairing codes being reliant on the app's persistent storage. You can get around this by using multiple Playcuts Shortcuts for your many iPads.

Usage:

Examples coming soon

Depends on [Swifter](https:/github.com/HTTPSwift/Swifter) for actually running a web server, I'm not smart enough to do that myself.
