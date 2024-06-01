# FROM makrov/hadoop-image
FROM alpine
VOLUME [ "/tmp/.X11-unix" ]
ENV DISPLAY=host.docker.internal:0
RUN apk add firefox fontconfig ttf-freefont font-noto terminus-font krb5
# bind bind-tools bind-dnssec-tools
# RUN apt install -y firefox
#COPY --chmod=777 ./Common/DNS_config/named.conf /etc/bind/
#COPY --chmod=777 ./Common/DNS_config/local.docker.net.conf /etc/bind/zone/
#COPY --chmod=777 ./Common/DNS_config/net.docker.conf /etc/bind/zone
#COPY --chmod=777 ./Common/DNS_config/0.0.127.in-addr.arpa.conf /etc/bind/zone
COPY ./Common/krb5.conf /etc/krb5.conf
# ENTRYPOINT firefox https://hadoop-master.docker.net:9871
ENTRYPOINT sh -c 'while true; do echo"!!!"; sleep 3; done'
#/usr/sbin/named -c /etc/bind/named.conf -f

# https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285
# Launch XQuartz. Under the XQuartz menu, select Preferences
# Go to the security tab and ensure "Allow connections from network clients" is checked.
# Run xhost + ${hostname} to allow connections to the macOS host *

# export KRB5_TRACE=/dev/stdout
# firefox
# about:config -> network.negotiate-auth.trusted-uris: docker.net -> hadoop-master.docker.net:9871
#network.automatic-ntlm-auth.trusted-uris

# wget http://releases.mozilla.org/pub/mozilla.org/firefox/releases/10.0.1/linux-x86_64/en-GB/firefox-10.0.1.tar.bz2
# apt install bzip2
# tar xjf firefox-10.0.1.tar.bz2

# wget https://ftp.mozilla.org/pub/firefox/releases/126.0b9/linux-x86_64/ru/firefox-126.0b9.tar.bz2
# tar xjf firefox-126.0b9.tar.bz2
# apt install libgtk-3-dev
# apt install libdbus-glib-1-2
# ./firefox/firefox

# TODO: настроить автоматический kinint по keytab-у
# сделать автозапуск firefox вместо while true...