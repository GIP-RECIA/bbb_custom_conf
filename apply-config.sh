#!/bin/bash

# Public IP address of the BBB server
PUBLIC_IP="$(hostname -I | sed 's/ .*//g')"
CUSTOM_DIR=/home/recia/bbb_custom_conf

# Pull in the helper functions for configuring BigBlueButton
source /etc/bigbluebutton/bbb-conf/apply-lib.sh
#enableUFWRules

echo "  - Apply overriding conf"
# warning some files already exist with a generated conf !
cp -R $CUSTOM_DIR/etc/bigbluebutton/bbb-webrtc-sfu/ /etc/bigbluebutton/
# warning bbb-apps-akka.conf exist - not applyed here
# warning bbb-fsesl-akka.conf exist - not applyed here
# bbb-html5-with-roles.conf - not applyed here
cp $CUSTOM_DIR/etc/bigbluebutton/bbb-html5.yml /etc/bigbluebutton/
# Append custon conf to existing file
sed -i '/### BEGIN CUSTOM CONF/,/### END CUSTOM CONF/d' /etc/bigbluebutton/bbb-web.properties
if grep -q "### BEGIN CUSTOM CONF" /etc/bigbluebutton/bbb-web.properties; then echo "Echec de remplacement de conf" && exit 1;fi
cat $CUSTOM_DIR/etc/bigbluebutton/bbb-web.properties >> /etc/bigbluebutton/bbb-web.properties

# echo "  - Configure recordings features"
# partie template ansible
# doit être revu dans une version ultérieure de BBB, cf issue  https://github.com/bigbluebutton/bigbluebutton/issues/12241 et doc:  https://docs.bigbluebutton.org/2.3/install.html#installing-additional-recording-processing-formats
# pré-requis apt-get install bbb-playback-notes bbb-playback-screenshare bbb-playback-podcast
# fichier modifié /usr/local/bigbluebutton/core/scripts/bigbluebutton.yml

echo "  - Apply enableMultipleKurentos"
enableMultipleKurentos

echo "  - Apply dynamic Video Profile"
enableHTML5CameraQualityThresholds

echo "  - Apply Vidéo Pagination"
enableHTML5WebcamPagination

echo "  - Apply enableHTML5ClientLog"
enableHTML5ClientLog

echo "  - Change history and logging"
sed -i "s/^history=.*/history=31/g" /etc/cron.daily/bigbluebutton
#sed -i "s/^unrecorded_days=.*/unrecorded_days=30/g" /etc/cron.daily/bigbluebutton
#sed -i "s/^published_days=.*/published_days=30/g" /etc/cron.daily/bigbluebutton
sed -i "s/^log_history=.*/log_history=366/g" /etc/cron.daily/bigbluebutton
# important pour les access log car réglé à 14 jours sinon - commenté car appliqué via ansible
#xmlstarlet ed --inplace -u "/configuration/appender[@name='FILE']/rollingPolicy/MaxHistory" -v 366 /usr/share/bbb-web/WEB-INF/classes/logback.xml

echo "  - Apply fr_FR sounds"
# before install FR_FR with script as example https://raw.githubusercontent.com/joshebosh/signalwire/master/sh/stack_sound_file.sh
xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "sound_prefix=")]/@data' --value "sound_prefix=/opt/freeswitch/share/freeswitch/sounds/fr/fr/june" /opt/freeswitch/etc/freeswitch/vars.xml
# back to origin conf
#xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "sound_prefix=")]/@data' --value "sound_prefix=\$\${sounds_dir}/en/us/callie" /opt/freeswitch/etc/freeswitch/vars.xml



### CONF APPLIED ON BBB 2.2.36

#echo "  - Tune Audio Parameters"
#cat <<HERE > /opt/freeswitch/conf/autoload_configs/opus.conf.xml
#<configuration name="opus.conf">
#      <settings>
#        <param name="use-vbr" value="1"/>
#        <param name="use-dtx" value="0"/>
#        <param name="complexity" value="10"/>
#        <param name="packet-loss-percent" value="8"/>
#        <param name="keep-fec-enabled" value="1"/>
#        <param name="use-jb-lookahead" value="1"/>
#        <param name="advertise-useinbandfec" value="1"/>
#      </settings>
#</configuration>
#HERE

#xmlstarlet ed --inplace -u "/configuration/profiles/profile[@name='cdquality']/param[@name='interval']/@value" -v 10 /opt/freeswitch/conf/autoload_configs/conference.conf.xml
#xmlstarlet ed --inplace -u "/configuration/profiles/profile[@name='cdquality']/param[@name='energy-level']/@value" -v 80 /opt/freeswitch/conf/autoload_configs/conference.conf.xml


#echo "  - Improve NodeJS concurrent users"
# ajoute --max-old-space-size=4096 --max_semi_space_size=128 à la conf d'origine
#sed -i 's;PORT=3000 .*;PORT=3000 /usr/share/$NODE_VERSION/bin/node --max-old-space-size=4096 --max_semi_space_size=128 main.js;g' /usr/share/meteor/bundle/systemd_start.sh
# => DEVRAIT être du genre
# modifie --max-old-space-size=4096 à la conf d'origine
#sed -i 's;--max-old-space-size=2048;--max-old-space-size=4096;g' /usr/share/meteor/bundle/systemd_start.sh
#sed -i 's;--max-old-space-size=2048;--max-old-space-size=4096;g' /usr/share/meteor/bundle/systemd_start_frontend.sh
