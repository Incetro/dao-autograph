DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
cd "$DIR"

cd Sources/sandbox
pod install
open Sandbox.xcworkspace