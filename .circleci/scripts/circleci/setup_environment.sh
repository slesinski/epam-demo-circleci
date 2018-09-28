#!/usr/bin/env bash

set -ev

# Allow MySQL to finish starting.
sleep 3

export PATH=${COMPOSER_BIN}:$PATH

# Create fake mailer.
echo 'max_execution_time = 120' >> /usr/local/etc/php/php.ini
echo 'sendmail_path = /bin/true' >> /usr/local/etc/php/php.ini

# Enable $_ENV variables in PHP.
echo 'variables_order = "EGPCS"' >> /usr/local/etc/php/php.ini
# Ensure that always_populate_raw_post_data PHP setting: Not set to -1 does not happen.
echo "always_populate_raw_post_data = -1" >> /usr/local/etc/php/php.ini
# Set PHP memory limit to something more realistic.
echo "memory_limit=512M" >> /usr/local/etc/php/php.ini

# Set git info.
git config --global user.name "Circle-CI"
git config --global user.email "noreply@circleci.com"

# Create MySQL DB.
mysql -u root -e "CREATE DATABASE drupal; CREATE USER 'drupal'@'localhost' IDENTIFIED BY 'drupal'; GRANT ALL ON drupal.* TO 'drupal'@'localhost';"

# Clear drush release history cache, to pick up new releases.
rm -f ~/.drush/cache/download/*---updates.drupal.org-release-history-*
# Verify that no git diffs (caused by line ending variation) exist.
# - git diff --exit-code

# sudo apt-get install xvfb
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

# Installs chromedriver to vendor/bin.
~/blt/vendor/acquia/blt/scripts/linux/install-chrome.sh ${COMPOSER_BIN}

set +v
