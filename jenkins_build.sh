export TEST_BUILD_DIR="${WORKSPACE}"
export HOME="${JENKINS_HOME}"
export GCLOUD_DIR="${HOME}/gcloud"
export GOOGLE_PROJECT_ID=php-mvm-a
export E2E_TEST_VERSION=jenkins-${BUILD_NUMBER}
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export PATH=${GCLOUD_DIR}/google-cloud-sdk/bin:${PATH}
export CLOUDSDK_ACTIVE_CONFIG_NAME=php-docker-e2e
export PHP_DOCKER_DEPLOY=true

gcloud info

scripts/run_test_suite.sh

unset CLOUDSDK_ACTIVE_CONFIG_NAME

CANDIDATE_NAME=`date +%Y-%m-%d_%H_%M`
echo "CANDIDATE_NAME:${CANDIDATE_NAME}"
IMAGE_NAME="gcr.io/${PRODUCTION_DOCKER_NAMESPACE}/php:${CANDIDATE_NAME}"
docker tag -f php-nginx "${IMAGE_NAME}"
gcloud docker -- push "${IMAGE_NAME}"

# Push the image to staging if UPLOAD_TO_STAGING is true
if [ "${UPLOAD_TO_STAGING}" = "true" ]; then 
  STAGING="gcr.io/${PRODUCTION_DOCKER_NAMESPACE}/php:staging"
  docker tag -f php-nginx "${STAGING}"
  gcloud docker -- push "${STAGING}"
fi
