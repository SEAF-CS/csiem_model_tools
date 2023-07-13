#!/bin/bash

export MODEL_VERS='csiem_model_tfvaed_1.0'
export MARVL_VERS='csiem_marvl'
export MODEL_BCS_PATH='s3://wamsi-westport-project-1/csiem-model'
export MARVL_DAT_PATH='s3://wamsi-westport-project-1/csiem_data/data-warehouse/mat'
export ACCESS_KEY_ID=''
export ACCESS_KEY_SECRET=''

export CREDS_FILE=''
export DEBUG=false

DO_MODEL=false
DO_MARVL=false

#
#===============================================================================
script_help () {
   echo "fetch_csiem.sh help"
#  echo " --debug            debug mode (prints stuff"
   echo " --model"
   echo "           download csiem model with default version"
   echo " --model <MODEL_VERS>"
   echo "           select <MODEL_VERS> to download [default is csiem_model_tfvaed_1.0]"
   echo " --bc-path <MODEL_BCS_PATH>"
   echo "           set <MODEL_BCS_PATH> to download [default is s3 from pawsey]"
   echo " --marvl"
   echo "           download csiem marvl with default version"
   echo " --marvl <MARVL_VERS>"
   echo "           select <MARVL_VERS> to download [default is csiem_data_1.0]"
   echo " --data-path <MARVL_DAT_PATH>"
   echo "           set <MARVL_DAT_PATH> to download [default is s3 from pawsey]"
   echo " --both"
   echo "           do both model and marvl"
   echo
   echo " --credsfile <CREDS_FILE>"
   echo "           get access credentials from the file <CREDS_FILE>"
   echo " --access-id <ACCESS_KEY_ID>"
   echo " --access-key <ACCESS_KEY_SECRET>"
   echo "           set access credentials"
   echo "           if no credentials are provided either here or through"
   echo "           a credentials file, you will be prompted for them"
   echo
   echo " without any arguments this script will download csiem tools which"
   echo " includes the latest version of this script"
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
      DO_MODEL=true
      if [ "`echo $2 | cut -c-2`" != "--" ] ; then
        shift
        export MODEL_VERS="$1"
      fi
      ;;
    --bc-path)
      DO_MODEL=true
      shift
      export MODEL_BCS_PATH="$1"
      ;;
    --marvl)
      DO_MARVL=true
      if [ "`echo $2 | cut -c-2`" != "--" ] ; then
        shift
        export MARVL_VERS="$1"
      fi
      ;;
    --marvl-data)
      DO_MARVL=true
      shift
      export MARVL_DAT_PATH="$1"
      ;;
    --both)
      DO_MODEL=true
      DO_MARVL=true
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

#   echo curl ${args[@]} -s -f -H \"Date: ${date}\" -H \"Authorization: ${authorization}\" \"https://projects.pawsey.org.au/${bucket}/${key}\"
    curl ${args[@]} -s -f -H "Date: ${date}" -H "Authorization: ${authorization}" "https://projects.pawsey.org.au/${bucket}/${key}"
#   echo $?
}
#-------------------------------------------------------------------------------
#

#===============================================================================
#
if [ "$DO_MODEL" = "true" ] ; then
  if [ "${MODEL_BCS_PATH:0:5}" = "s3://" ] ; then
    if [ -z "${ACCESS_KEY_ID-}" ]; then
      # prompt for access keys
      echo -n 'access key ID : '
      read ACCESS_KEY_ID
      echo -n 'access key secret : '
      read ACCESS_KEY_SECRET
    fi
  fi
elif [ "$DO_MARVL" = "true" ] ; then
  if [ "${MARVL_DAT_PATH:0:5}" = "s3://" ] ; then
    if [ -z "${ACCESS_KEY_ID-}" ]; then
      # prompt for access keys
      echo -n 'access key ID : '
      read ACCESS_KEY_ID
      echo -n 'access key secret : '
      read ACCESS_KEY_SECRET
    fi
  fi
fi
#
#
#-------------------------------------------------------------------------------
#
#
if [ ! -d csiem_model_tools ] ; then
  git clone https://github.com/AquaticEcoDynamics/csiem_model_tools
fi

#
#-------------------------------------------------------------------------------
#

if [ "$DO_MODEL" = "true" ] ; then
  if [ -d ${MODEL_VERS} ] ; then
    cd ${MODEL_VERS}
    git pull
    cd ..
  else
    git clone https://github.com/AquaticEcoDynamics/${MODEL_VERS}
  fi

  if [ -d ${MODEL_VERS} ] ; then
    cd ${MODEL_VERS}
    #
    if [ "${MODEL_BCS_PATH:0:5}" = "s3://" ] ; then
      s3simple ${MODEL_BCS_PATH}/${MODEL_VERS}/bc_repo.tar.xz bc_repo.tar.xz
    else
      cp ${MODEL_BCS_PATH}/${MODEL_VERS}/bc_repo.tar.xz bc_repo.tar.xz
    fi

    #
    #---------------------------------------------------------------------------
    #
    if [ -f bc_repo.tar.xz ] ; then
      tar xJf bc_repo.tar.xz
    else
      echo "Failed to get bc_repo"
    fi
  fi
fi

#
#-------------------------------------------------------------------------------
#

if [ "$DO_MARVL" = "true" ] ; then
  if [ -d ${MARVL_VERS} ] ; then
    cd ${MARVL_VERS}
    git pull  --recurse-submodules
    cd ..
  else
    git clone --recurse-submodules https://github.com/AquaticEcoDynamics/${MARVL_VERS}
  fi

  if [ -d ${MARVL_VERS} ] ; then
    cd ${MARVL_VERS}
    #
    if [ "${MARVL_DAT_PATH:0:5}" = "s3://" ] ; then
      s3simple ${MARVL_DAT_PATH}/csiem_data_${MARVL_VERS}.zip csiem_data_${MARVL_VERS}.zip
    else
      cp ${MARVL_DAT_PATH}/csiem_data_${MARVL_VERS}.zip csiem_data_${MARVL_VERS}.zip
    fi

    #
    #---------------------------------------------------------------------------
    #
    if [ -f csiem_data_${MARVL_VERS}.zip ] ; then
      unzip csiem_data_${MARVL_VERS}.zip
    else
      echo "Failed to get csiem_data_${MARVL_VERS}.zip"
    fi
  fi
fi

exit 0
