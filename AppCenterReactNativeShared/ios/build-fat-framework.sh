# Sets the target folders and the final framework product.
FMK_NAME=AppCenterReactNativeShared

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR=${SRCROOT}/../Products
ZIP_FOLDER=${FMK_NAME}
TEMP_DIR=${PRODUCTS_DIR}/${ZIP_FOLDER}
INSTALL_DIR=${TEMP_DIR}/${FMK_NAME}.framework

# Working dir will be deleted after the framework creation.
WRK_DIR=build
DEVICE_DIR=${WRK_DIR}/Release-iphoneos
SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator

# Cleaning previous build
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${FMK_NAME}" clean

# Building both architectures.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${FMK_NAME}" -sdk iphoneos
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${FMK_NAME}" -sdk iphonesimulator

# Cleaning the oldest.
if [ -d "${TEMP_DIR}" ]
then
rm -rf "${TEMP_DIR}"
fi

# Creates and renews the final product folder.
mkdir -p "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/Headers"
mkdir -p "${INSTALL_DIR}/Modules"

# Copy the swift import file
cp -f "${SRCROOT}/${FMK_NAME}/Support/module.modulemap" "${INSTALL_DIR}/Modules/"

# Copies the headers and resources files to the final product folder.
cp -R "${SRCROOT}/${WRK_DIR}/Release-iphoneos/include/${FMK_NAME}/" "${INSTALL_DIR}/Headers/"

# Copies the license file to the products directory (required for cocoapods)
cp -f "../LICENSE" "${TEMP_DIR}"

# Uses the Lipo Tool to merge both binary files (i386 + armv6/armv7/armv7s/arm64) into one Universal final product.
lipo -create "${DEVICE_DIR}/lib${FMK_NAME}.a" "${SIMULATOR_DIR}/lib${FMK_NAME}.a" -output "${INSTALL_DIR}/${FMK_NAME}"

rm -r "${WRK_DIR}"
