# Notes

When using Cloud Build for `build_packages.sh`, any of the packages that are built are not saved until the build completes for a PHP version.  Some of the libraries and extensions can take quite a while to build on Cloud Build - libv8, grpc, for example.

You can build those locally and upload them to the Bucket for Build Packages mentioned below and then run Cloud Build and it will create the rest in the same bucket.

## GCP Requirements

A Google Cloud Project  
`gsutil` and `gcloud` installed and configured.

Permissions and APIs enabled for:  
- Cloud Build
- Cloud Storage
    - Bucket for Build Packages *i.e. {your-unique-id}-php-mvm-a*
    - Bucket for Distributions *i.e. {your-unique-id}-gcp-php-packages*
- Container Registry
    - Built Images/Containers will be tagged, uploaded and affiliated with your GCP Project ID *i.e. gcr.io/your-project-123457/php*

## Building Packages
*see README in package-builder*

## Uploading Local Packages to GCS
After building the packages locally (php, extensions, libraries), you can upload the built artifacts directly to the `*-php-mvm-a` bucket.  

Navigate to the local directory where the `deb-package-builder` Docker image saved the packages that have been built, *i.e.*  

```bash
cd ~/gcloud/packages/pkg
gsutil -m rsync -d -r ./ gs://{your-unique-id}-php-mvm-a/ubuntu-packages
```

## Creating the Runtime Distribution

Processes packages for each version of php, their extensions and the shared libraries from the `*-php-mvm-a` gcs bucket and bundles them into distributions in the `*-gcp-php-packages` bucket.

Distributions include: stable, unstable and one according to the build time. These are used when building the Docker images later.

**Environment Variables:**

Specify the following variables when issuing commands or add them to your
environment:

**DEB_TMP_DIR**

> Directory on host OS where packages will be downloaded  
`/home/{user}/tmp/php-build`

**UBUNTU_GCS_PATH**
>   Google Cloud Storage Bucket from your GC Project used while 
>   building packages with Cloud Build (full path)  
>  `gs://{your-unique-id}-php-mvm-a/ubuntu-packages`

**GCP_PACKAGE_BUCKET**
>   Google Cloud Storage Bucket from your project that hosts the
>   runtime distribution for stable, unstable and each build
>   (collection of > deb packages) (fully qualified path)  
>   `gs://{your-unique-id}-gcp-php-packages`

**Parameters**  
  `debian` (default) OR `ubuntu`

**Steps**
```bash
cd php-docker  

DEB_TMP_DIR="/home/{user}/gcloud/tmp/php-build" \  
UBUNTU_GCS_PATH="gs://{your-unique-id}-php-mvm-a/ubuntu-packages" \  
GCP_PACKAGE_BUCKET="{your-unique-id}-gcp-php-packages" \  
./scripts/update-gcs.sh ubuntu
```
## Generating Images, Running Tests
**Environment Variables:**

**TAG**
>  Unique Identifier for the built images? (latest or custom?)

**Steps**
```bash
cd php-docker
GCP_PACKAGE_BUCKET={your_unique_id}-gcp-php-packages TAG={custom-tag} GOOGLE_PROJECT_ID=your-project-123456 ./scripts/build_images.sh
```    

## TODO
- Fix Packaging for librabbitmq
- Re-enable all Structure tests
    - Fix licensing tests or white list the couple of packages causing an issue
- Re-enable Extension and Custom tests
- The following extensions need updates to be compatible with php8
    - hprose
    - lua
    - phalcon
    - tcpwrap
    - v8js
- Sodium is included in 7.4 and 8.0, re-enable tests if necessary
- PhalconTest removed for 8.0, determine if annotation can skip instead
- Determine how to enable lua module for bionic nginx OR determine if using PPA is suitable
- Review Changes/Additions to `package-build/functions.sh`
- Reconfigure travis settings for testing custom build, if necessary
- `VersionTest.php`
    - Review changes
    - Need to point to custom built artifacts, not ones affiliated with Google.
