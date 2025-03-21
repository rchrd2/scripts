SCRIPT_NAME=$(basename "$(realpath "$(dirname "$0")")")
echo "Building $SCRIPT_NAME"

swift build -c release

if [ ! -f "../../bin/$SCRIPT_NAME" ]; then
  pushd ../../bin
  echo ln -sn "../src/$SCRIPT_NAME/.build/release/$SCRIPT_NAME" "$SCRIPT_NAME"
  ln -sn "../src/$SCRIPT_NAME/.build/release/$SCRIPT_NAME" "$SCRIPT_NAME"
  popd
fi

echo "$(realpath "../../bin/$SCRIPT_NAME")"


# Cursor gave this build command
# cd src/upload-audio && swift package clean && swift package resolve && swift build