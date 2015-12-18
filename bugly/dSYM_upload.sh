#!/bin/sh
# Copyright 2014-2015 Bugly @Tencent. All rights reserved.
#
# V 1.1
#
################################################################################
# 注意: 请配置下面的信息
################################################################################
BUGLY_APP_ID="900007462"
BUGLY_APP_KEY="CW0OcXMl7HbajZ4B"
BUNDLE_IDENTIFIER=${PRODUCT_BUNDLE_IDENTIFIER}
if [[ ${BUNDLE_IDENTIFIER} == "com.gaike.GetCarSwift.test" ]]; then
    BUGLY_APP_ID="900011518"
    BUGLY_APP_KEY="ReMUJrRI1isUhRmW"
fi
################################################################################
# 自定义配置
################################################################################
# Debug模式编译是否上传，1＝上传 0＝不上传，默认不上传
UPLOAD_DEBUG_SYMBOLS=0
#
# 模拟器编译是否上传，1=上传 0=不上传，默认不上传
UPLOAD_SIMULATOR_SYMBOLS=0
#
# buglySymboliOS.jar路径
BUGLY_SYMBOL_JAR_PATH="${SRCROOT}/bugly/buglySymboliOS.jar"
#
# # 脚本默认配置的版本格式为CFBundleShortVersionString(CFBundleVersion),  如果你修改默认的版本格式, 请设置此变量, 如果不想修改, 请忽略此设置
# CUSTOMIZED_APP_VERSION=""
#
#
#
# This script will extract symbols from the .dSYM and generate .symbol file(Bugly supported) and upload to server.
# You could visit http://bugly.qq.com to get more details about Bugly.
#
# Usage:
#   * The instructions assume you have copyed this script into your project int Xcode.
#   * Copy the "buglySymbolIOS.jar" file into the "~/bin" folder.
#   * Open the project editor, select your build target.
#   * Click "Build Phases" at the top of the project editor.
#   * Click "+" button in the top left corner and select "New Run Script Phase".
#   * Click "Run Script".
#   * Paste the following script into the dark text box. You will have to uncomment the lines (remove the #) of course.
#
# --- SCRIPT BEGINS ON NEXT LINE, COPY AND EDIT FROM THERE ---
#
#
#
# --- END OF SCRIPT ---


################################################################################
# 注意: 如果你不知道此脚本的执行流程和用法，请不要随便修改！
################################################################################

# 退出执行并打印提示信息
exitWithMessage() {
    echo "--------------------------------"
    echo -e "${1}"
    echo "--------------------------------"
    echo "No upload and exit."
    echo "----------------------------------------------------------------"
    exit ${2}
}

echo "----------------------------------------------------------------"
echo "Copyright 2014-2015 Bugly @Tencent. All rights reserved."

echo "This script will extract symbols from the .dSYM file and generate .symbol file(Bugly supported) and upload to server."
echo "You could visit http://bugly.qq.com to get more details about Bugly."
echo "----------------------------------------------------------------"

echo "Uploading dSYM to Bugly."
echo ""

# Bugly服务域名
DSYM_UPLOAD_DOMAIN="bugly.qq.com"

# 读取Info.plist文件中的版本信息
echo "Info.Plist : ${INFOPLIST_FILE}"

BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' "${INFOPLIST_FILE}")
BUNDLE_SHORT_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "${INFOPLIST_FILE}")

# 组装Bugly默认识别的版本信息(格式为CFBundleShortVersionString(CFBundleVersion), 例如: 1.0(1))
if [ ! "${CUSTOMIZED_APP_VERSION}" ]; then
BUGLY_APP_VERSION="${BUNDLE_SHORT_VERSION}(${BUNDLE_VERSION})"
else
BUGLY_APP_VERSION="${CUSTOMIZED_APP_VERSION}"
fi

echo "--------------------------------"
echo "Step 1: Prepare application information."
echo "--------------------------------"

echo "Product Name: ${PRODUCT_NAME}"
echo "Bundle Identifier: ${BUNDLE_IDENTIFIER}"
echo "Version: ${BUNDLE_SHORT_VERSION}"
echo "Build: ${BUNDLE_VERSION}"

echo "Bugly App ID: ${BUGLY_APP_ID}"
echo "Bugly App key: ${BUGLY_APP_KEY}"
echo "Bugly App Version: ${BUGLY_APP_VERSION}"

echo "--------------------------------"
echo "Step 2: Check the arguments ..."

# 检查模拟器编译是否允许上传符号
if [ "$EFFECTIVE_PLATFORM_NAME" == "-iphonesimulator" ]; then
if [ $UPLOAD_SIMULATOR_SYMBOLS -eq 0 ]; then
exitWithMessage "Warning: Build for simulator and skipping to upload. \nYou can modify 'UPLOAD_SIMULATOR_SYMBOLS' to 1 in the script." 0
fi
fi

if [ "${CONFIGURATION=}" == "Debug" ]; then
if [ $UPLOAD_DEBUG_SYMBOLS -eq 0 ]; then
exitWithMessage "Warning: Build for debug mode and skipping to upload. \nYou can modify 'UPLOAD_DEBUG_SYMBOLS' to 1 in the script." 0
fi
fi

# 检查必须参数是否设置
if [ ! "${BUGLY_APP_ID}" ]; then
exitWithMessage "Error: Bugly App ID not defined." 1
fi

if [ ! "${BUGLY_APP_KEY}" ]; then
exitWithMessage "Error: Bugly APP Key not defined." 1
fi

if [ ! "${BUNDLE_IDENTIFIER}" ]; then
exitWithMessage "Error: Bundle Identifier not defined." 1
fi

function uploadDSYM {
    DSYM_SRC="$1"
    echo ".dSYM file: ${DSYM_SRC}"
    if [ ! -d "$DSYM_SRC" ]; then
    exitWithMessage "dSYM source not found: ${DSYM_SRC}" 1
    fi
    DSYM_FILE_NAME=${DSYM_SRC##*/}
    DSYM_SYMBOL_OUT_ZIP_NAME="${DSYM_FILE_NAME}.bSymbol.zip"
    # 替换空格
    DSYM_SYMBOL_OUT_ZIP_NAME="${DSYM_SYMBOL_OUT_ZIP_NAME// /_}"
    DSYM_ZIP_FPATH="${BUILT_PRODUCTS_DIR}/${DSYM_SYMBOL_OUT_ZIP_NAME}"
        
    DSYM_SYMBOL_BACKUP_DIR=${BUILD_DIR}/Symbols
        
    if [ ! -e "${DSYM_SYMBOL_BACKUP_DIR}" ]; then
        mkdir ${DSYM_SYMBOL_BACKUP_DIR}
    fi
        
    # 备份并清理
    find ${BUILT_PRODUCTS_DIR} -name "*.zip" -print0 | xargs -0 -I {} mv {} ${DSYM_SYMBOL_BACKUP_DIR}
        /bin/rm -rf "${BUILT_PRODUCTS_DIR}/*.zip"
        
    echo "Extract symbols from dSYM to ${DSYM_ZIP_FPATH}."
        
    echo "--------------------------------"
        (/usr/bin/java -jar "${BUGLY_SYMBOL_JAR_PATH}" -i "${DSYM_SRC}" -o "${DSYM_ZIP_FPATH}" ) || exitWithMessage "Error: Failed to extract symbols." 1
    echo "--------------------------------"
        
    if [ ! -e "${DSYM_ZIP_FPATH}" ]; then
        DSYM_SYMBOL_OUT_ZIP_NAME=$(ls ${BUILT_PRODUCTS_DIR} | grep ".zip")
        DSYM_ZIP_FPATH="${BUILT_PRODUCTS_DIR}/${DSYM_SYMBOL_OUT_ZIP_NAME}"
        DSYM_SYMBOL_OUT_ZIP_NAME=${DSYM_SYMBOL_OUT_ZIP_NAME//&/_}
    fi
            
    if [ ! -e "${DSYM_ZIP_FPATH}" ] ; then
        exitWithMessage "no symbol file zip archive generated: ${DSYM_ZIP_FPATH}" 1
    fi
            
    # 提取符号信息
    echo "--------------------------------"
    echo "Step 3: Extract symbol info from .dSYM file."
            
    if [ ! -e "$BUGLY_SYMBOL_JAR_PATH" ]; then
        exitWithMessage "Error: Jar file '${BUGLY_SYMBOL_JAR_PATH}' was not found. \nPlease copy the jar file into ~/bin folder." 1
    fi
            
    echo "Step 4: Upload the symbols of dSYM."
    echo "--------------------------------"
    echo "zip : ${DSYM_SYMBOL_OUT_ZIP_NAME}"
    echo "dir : ${DSYM_ZIP_FPATH}"
            
    echo "dSYM upload domain: ${DSYM_UPLOAD_DOMAIN}"
    DSYM_UPLOAD_URL="http://${DSYM_UPLOAD_DOMAIN}/upload/dsym?app=${BUGLY_APP_ID}&pid=2&ver=${BUGLY_APP_VERSION}&n=${DSYM_SYMBOL_OUT_ZIP_NAME}&key=${BUGLY_APP_KEY}&bid=${BUNDLE_IDENTIFIER}"
    echo "dSYM upload url: ${DSYM_UPLOAD_URL}"
            
    # Upload dSYM to Bugly
    echo "curl --header "Content-Type:application/zip" --data-binary "@${DSYM_ZIP_FPATH}" "${DSYM_UPLOAD_URL}" --verbose"
            
    echo "--------------------------------"
    STATUS=$(/usr/bin/curl --header "Content-Type:application/zip" --data-binary "@${DSYM_ZIP_FPATH}" "${DSYM_UPLOAD_URL}" --verbose)
    echo "--------------------------------"
            
    UPLOAD_RESULT="FAILTURE"
    echo "Bugly server response: ${STATUS}"
    if [ ! "${STATUS}" ]; then
        echo "Error: Failed to upload the zip archive file."
    elif [[ "${STATUS}" == *":true"* ]]; then
        echo "Success to upload the dSYM for the app [${BUNDLE_IDENTIFIER} ${BUGLY_APP_VERSION}]"
        UPLOAD_RESULT="SUCCESS"
    else
        echo "Error: Failed to upload the zip archive file to Bugly."
    fi
            
    #Remove temp dSYM archive
    echo "Remove temporary zip archive: ${DSYM_ZIP_FPATH}"
            #/bin/rm -f "${DSYM_ZIP_FPATH}"
            
    if [ "$?" -ne 0 ]; then
        exitWithMessage "Error: Failed to remove temporary zip archive." 1
    fi
            
    echo "--------------------------------"
    echo "${UPLOAD_RESULT} - dSYM upload complete."
            
    if [[ "${UPLOAD_RESULT}" == "FAILTURE" ]]; then
        echo "--------------------------------"
        echo "Failed to upload the dSYM"
        echo "Please check the script and try it again."
    fi
            
    echo "----------------------------------------------------------------"
}
        
# .dSYM文件信息
        
echo "DSYM FOLDER ${DWARF_DSYM_FOLDER_PATH}"
        
DSYM_FOLDER="${DWARF_DSYM_FOLDER_PATH}"
        
IFS=$'\n'
        
for dsymFile in $(find "$DSYM_FOLDER" -name '*.dSYM'); do
    echo "Found dSYM file: $dsymFile"
    uploadDSYM $dsymFile
done
        
