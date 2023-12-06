SCRIPT_NAME=$(basename "$(realpath "$(dirname "$0")")")
echo "Building $SCRIPT_NAME"

swift build -c release

