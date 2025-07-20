#!/bin/sh

# Determine the script's own path
MYSELF=$(which "$0" 2>/dev/null)
[ $? -gt 0 -a -f "$0" ] && MYSELF="./$0"

# Set the default java command
java=java

# Use JAVA_HOME if set
if [ -n "$JAVA_HOME" ]; then
    java="$JAVA_HOME/bin/java"
fi

# Capture all arguments passed to the script as VM and program arguments
VM_ARGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    -D*|-X*) VM_ARGS="$VM_ARGS $1"; shift ;;
    *) break ;;
  esac
done

# Echo the command to be executed (for debugging purposes)
echo "Running command: $java $VM_ARGS -jar $MYSELF $@"

# Execute the jar with java, passing VM arguments and remaining arguments
exec "$java" $VM_ARGS -jar "$MYSELF" "$@"

# Exit with an error if the exec fails
exit 1

# cat stub.sh securekafka.jar > sk && chmod +x sk
