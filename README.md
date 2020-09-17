flutter build appbundle -t lib/com/riversurfreport/androidclient/main.dart

java -jar ~/Downloads/bundletool-all-1.2.0.jar build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=riversurfreport.apks

export ANDROID_HOME=/Users/bsmith/Library/Android/sdk/
java -jar ~/Downloads/bundletool-all-1.2.0.jar install-apks --apks=riversurfreport.apks

