#!/bin/bash

## source: https://github.com/openshift/jenkins/blob/master/2/contrib/s2i/assemble

JENKINS_INSTALL_DIR=$(mktemp -d --suffix=jenkins)

shopt -s dotglob

echo "---> Copying repository files ..."
cp -Rf /tmp/src/. ${JENKINS_INSTALL_DIR}

# Install jenkins plugins using plugin installer if user has "plugins.txt" file
# in repository
if [ -f ${JENKINS_INSTALL_DIR}/plugins.txt ]; then
  echo "---> Installing Jenkins $(cat ${JENKINS_INSTALL_DIR}/plugins.txt|wc -l) plugins using ${IMAGE_CONFIG_DIR}/plugins.txt ..."
  /usr/local/bin/install-plugins.sh ${JENKINS_INSTALL_DIR}/plugins.txt
  if [[ "$?" != "0" ]]; then
    echo "Failed to install plugins."
    exit 1
  fi
  /usr/local/bin/fix-permissions ${IMAGE_CONFIG_DIR}/plugins
fi

if [ -d ${JENKINS_INSTALL_DIR}/plugins ]; then
  echo "---> Installing $(ls -l ${JENKINS_INSTALL_DIR}/plugins | grep ^- | wc -l) Jenkins plugins from plugins/ directory ..."
  cp -R ${JENKINS_INSTALL_DIR}/plugins/* ${IMAGE_CONFIG_DIR}/plugins/
  /usr/local/bin/fix-permissions ${IMAGE_CONFIG_DIR}/plugins
fi

if [ -d ${JENKINS_INSTALL_DIR}/configuration ]; then
  if [ -d ${JENKINS_INSTALL_DIR}/configuration/jobs ]; then
    echo "---> Removing sample Jenkins job ..."
    rm -rf ${IMAGE_CONFIG_DIR}/configuration/jobs
  fi
  echo "---> Installing new Jenkins configuration ..."
  /usr/local/bin/fix-permissions ${JENKINS_INSTALL_DIR}/configuration
  mv ${JENKINS_INSTALL_DIR}/configuration/* ${IMAGE_CONFIG_DIR}/configuration/
fi