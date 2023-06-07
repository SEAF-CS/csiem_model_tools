#!/bin/bash

export MODEL_VERS='csiem_model_tfvaed_1.0'
export MODEL_BC_PATH='s3://wwmsp1/csiem-model/'
export ACCESS_KEY_ID=''
export ACCESS_KEY_SECRET=''

export CREDS_FILE=''
export DEBUG=false

#
#===============================================================================
script_help () {
   echo "fetch_csiem.sh help"
   echo " --debug            debug mode (prints stuff"
   echo " --model <MODEL_VERS>"
   echo "           select <MODEL_VERS> to download [default is csiem_model_tfvaed_1.0]"
   echo " --bc-path <MODEL_BC_PATH>"
   echo "           set <MODEL_BC_PATH> to download [default is s3 from pawsey]"
   echo " --credsfile <CREDS_FILE>"
   echo "           get access credentials from the file <CREDS_FILE>"
   echo " --access-id <ACCESS_KEY_ID>"
   echo " --access-key <ACCESS_KEY_SECRET>"
   echo "           set access credentials"
   echo "           if no credentials are provided either here or through"
   echo "           a credentials file, you will be prompted for them"
}
#-------------------------------------------------------------------------------

while [ $# -gt 0 ] ; do
  case $1 in
    --help)
      script_help
      exit 0
      ;;
    --debug)
      export DEBUG=true
      ;;
    --model)
      shift
      export MODEL_VERS="$1"
      ;;
    --bc-path)
      shift
      export MODEL_BC_PATH="$1"
      ;;
    --credsfile)
      shift
      . $1
      export CREDS_FILE="$1"
      ;;
    --access-id)
      shift
      export ACCESS_KEY_ID="$1"
      ;;
    --access-key)
      shift
      export ACCESS_KEY_SECRET="$1"
      ;;
    *)
      ;;
  esac
  shift
done
#
#===============================================================================
#
#
#
#===============================================================================
s3simple() {
    local url="$1"
    local file="${2:--}"

    if [ "${url:0:5}" != "s3://" ]; then
        echo "Need an s3 url"
        return 1
    fi
    local path="${url:5}"

    if [ -z "${ACCESS_KEY_ID-}" ]; then
        echo "Need ACCESS_KEY_ID to be set"
        return 1
    fi

    if [ -z "${ACCESS_KEY_SECRET-}" ]; then
        echo "Need ACCESS_KEY_SECRET to be set"
        return 1
    fi

    local method md5 args
    method="GET"
    md5=""
    args=(-o "$file")

    local aws_headers=""
    if [ -n "${SESSION_TOKEN-}" ]; then
        args=("${args[@]}" -H "x-amz-security-token: ${SESSION_TOKEN}")
        aws_headers="x-amz-security-token:${SESSION_TOKEN}\n"
    fi

    local date
    date="$(date -u '+%a, %e %b %Y %H:%M:%S +0000')"

    local string_to_sign
    printf -v string_to_sign "%s\n%s\n\n%s\n%b%s" "$method" "$md5" "$date" "$aws_headers" "/$path"

    local signature
    signature=$(echo -n "$string_to_sign" | openssl sha1 -binary -hmac "${ACCESS_KEY_SECRET}" | openssl base64)

    local authorization="AWS ${ACCESS_KEY_ID}:${signature}"

    local bucket="${path%%/*}"
    local key="${path#*/}"

echo    curl ${args[@]} -s -f -H \"Date: ${date}\" -H \"Authorization: ${authorization}\" \"https://projects.pawsey.org.au/${bucket}/${key}\"
    curl ${args[@]} -s -f -H "Date: ${date}" -H "Authorization: ${authorization}" "https://projects.pawsey.org.au/${bucket}/${key}"
#   echo $?
}
#-------------------------------------------------------------------------------
#

#===============================================================================
#
if [ "${MODEL_BC_PATH:0:5}" = "s3://" ] ; then
    if [ -z "${ACCESS_KEY_ID-}" ]; then
        # prompt for access keys
        echo -n 'access key ID : '
        read ACCESS_KEY_ID
        echo -n 'access key secret : '
        read ACCESS_KEY_SECRET
    fi
fi
#
#
git clone https://github.com/AquaticEcoDynamics/csiem_model_tools
git clone https://github.com/AquaticEcoDynamics/${MODEL_VERS}

cd ${MODEL_VERS}
#
if [ "${MODEL_BC_PATH:0:5}" = "s3://" ] ; then
    s3simple ${MODEL_BC_PATH}/${MODEL_VERS}/bc_repo.tar.xz bc_repo.tar.xz
else
    cp ${MODEL_BC_PATH}/${MODEL_VERS}/bc_repo.tar.xz bc_repo.tar.xz
fi

#
#-------------------------------------------------------------------------------
#
tar xJf ../bc_repo.tar.xz
#unzip bc_repo.zip

exit 0
