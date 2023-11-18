SCRIPT_NAME=$(basename "$(realpath "$(dirname "$0")")")
echo "Building $SCRIPT_NAME"

swift build -c release

if [ ! -f "../../bin/$SCRIPT_NAME" ]; then
  cd ../../bin
  ln -sn "../src/$SCRIPT_NAME/.build/release/$SCRIPT_NAME" "$SCRIPT_NAME"
fi

echo "$(realpath "../../bin/$SCRIPT_NAME")"