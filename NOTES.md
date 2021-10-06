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
- Build Process (`php-docker/package-builder`)
    - Scripts
        - Review Changes/Additions to `functions.sh`
            - [x] `download_from_git` - still needed in interim
    - Libraries
        - [x] Fix Packaging for librabbitmq
        - [x] Remove Build of libvips, use bionic version
    - Extensions
        - References
            - [Pagely PHP Versions and Supported Extensions](https://support.pagely.com/hc/en-us/articles/360057574951-PHP-Versions-and-Supported-Extensions-Reference)
        - apcu
            - [x] Enabled in php8.0
        - apcu_bc
            - [x] Obsolete in php8.0
        - cassandra
            - [x] Fix invalid symlink for libcassandra.so
        - jsond/jsonc
            - included natively in 7.4+
        - Sodium
            - [ ] Enabled and test in 7.4 and 8.0
        - Phalcon
            - Requires v5.0 to be released for php8 support
            - [ ] PhalconTest removed for 8.0, determine how to skip/ignore
        - php-80
            - [ ] amqp
                - [ ] Test
            - [x] apcu
            - [ ] cassandra
            - [ ] hprose
            - [ ] lua
            - [ ] phalcon
            - [ ] stackdriver_debugger
                - [ ] Test
                - [ ] Submit PR
            - [ ] tcpwrap
            - [ ] v8js
            - [x] vips
            - [x] xmlrpc - added as extension
            - [x] xsl - part of xml,dom
- Tests
    - Structure
        - Switched to [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test)
        - Fix licensing tests or exclude the couple of packages causing an issue?
        - [ ] php-73
        - [ ] php-74
        - [ ] php-80
            - Cannot find the copyright files for the following libraries
            - libext2fs `/usr/share/doc/libext2fs/copyright`
            - libssl-dev `../libssl1.1/copyright` in `/usr/share/doc/libssl-dev/copyright`
            - openssl `../libssl1.1/copyright` in `/usr/share/doc/openssl/copyright`
    - Extension
        - [ ] php-73
        - [ ] php-74
        - [ ] php-80
    - Legacy Extension
        - [ ] php-73
        - [ ] php-74
        - [ ] php-80
    - Custom
        - [ ] php-73
        - [ ] php-74
        - [ ] php-80
    - Travis - check_versions
        - `VersionTest.php`
            - [x] Fix failures when searching for gcp-phpXX packages
            - [x] Need to point to custom built artifacts, not ones affiliated with Google.
        - [x] Reconfigure travis settings for testing custom build, if necessary
- nginx
    - [ ] Determine how to enable `ngx_http_lua_module` for bionic nginx OR determine if using PPA `ondrej/nginx-mainline` is suitable. (*see* `php-base/nginx.conf`)
