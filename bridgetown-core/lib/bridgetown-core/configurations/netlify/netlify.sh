#!/usr/bin/env bash
# Taken from https://docs.netlify.com/configure-builds/file-based-configuration/#inject-environment-variable-values

echo "Updating netlify.toml with references to our built files"

CSS_PATH=`find output/_bridgetown/static/css/*.css -type f | sed -e 's,output\/,/,g'`
JS_PATH=`find output/_bridgetown/static/js/*.js -type f | sed -e 's,output\/,/,g'`

echo "CSS Path: ${CSS_PATH}"
echo "JS Path: ${JS_PATH}"

sed -i s,CSS_PATH,${CSS_PATH},g netlify.toml
sed -i s,JS_PATH,${JS_PATH},g netlify.toml
sed -i s,NETLIFY_IMAGES_CDN_DOMAIN,${NETLIFY_IMAGES_CDN_DOMAIN},g netlify.toml
