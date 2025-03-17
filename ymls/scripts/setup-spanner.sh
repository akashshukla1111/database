#!/bin/sh

echo "🚀 Starting Google Spanner Emulator..."
gcloud emulators spanner start --host-port=0.0.0.0:9010 &

# Wait for emulator to start
sleep 5

echo "🔧 Configuring gcloud for Spanner Emulator..."

# export SPANNER_EMULATOR_HOST=localhost:9010
# export GOOGLE_CLOUD_PROJECT=$PROJECT_ID
# export GOOGLE_APPLICATION_CREDENTIALS=""  # Disable authentication

gcloud config configurations create spanner-emulator || true
gcloud config set auth/disable_credentials true
gcloud config set project $PROJECT_ID
gcloud config set api_endpoint_overrides/spanner http://localhost:9020/

echo "🛠️ Creating Spanner Instance: $INSTANCE_ID"
gcloud spanner instances create $INSTANCE_ID --config=emulator-config --description="Local Spanner Instance" --nodes=1

echo "📦 Creating for project $PROJECT_ID and Database: $DATABASE_ID"
gcloud spanner databases create $DATABASE_ID --instance=$INSTANCE_ID

echo "✅ Spanner Emulator is ready! Running on localhost:9010"

# Keep container running
tail -f /dev/null
