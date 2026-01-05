# # Makefile for Flutter project

# .PHONY: run_input_device

# run_input_device:
# 	@read -p "Enter device ID to run on: " device; \
# 	echo "Running on $$device"; \
# 	flutter run -d $$device



# Building release version of the app for android and iOS
.PHONY: build_app

build_app:
	@echo "Cleaning the repository"
	flutter clean
	@echo "Getting the dependencies"
	flutter pub get
	@echo "Building appbundle"
	flutter build appbundle
	@echo "Building ipa"
	flutter build ipa


# Building release version of the web and delpoying to firebase hosting
.PHONY: build_web change_app_name

build_web: change_app_name
	@echo "----Cleaning the repository----"
	flutter clean
	@echo "----Getting the dependencies----"
	flutter pub get
	@echo "----Building web----"
	flutter build web --release
	@echo "----Deploying to firebase hosting----"
	# firebase deploy


# Change App Name
.PHONY: change_app_name

change_app_name:
	@echo "--Changing App Name--"
	sed -i.bak "s/static const String appName = '.*';/static const String appName = 'PrimeLMS';/" lib/configs/app_config.dart
	@echo "--App Name Changed!--"


# Undo App Name Change
.PHONY: revert_app_name

revert_app_name:
	@echo "--Reverting App Name--"
	mv lib/configs/app_config.dart.bak lib/configs/app_config.dart
	@echo "--App Name Reverted!--"


.PHONY: generate_debug_certificate

generate_debug_certificate:
	@echo "Generating debug certificate"
	keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000
	@echo "Debug certificate generated"

