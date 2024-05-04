FROM alpine
VOLUME [ "/tmp/.X11-unix" ]
ENV DISPLAY=host.docker.internal:0
RUN apk add firefox fontconfig ttf-freefont font-noto terminus-font krb5 \
 && echo "default_realm = REALM.TLD" >> /etc/krb5.conf
COPY ./Common/krb5.conf /etc/krb5.conf
ENTRYPOINT firefox

# https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285
# Launch XQuartz. Under the XQuartz menu, select Preferences
# Go to the security tab and ensure "Allow connections from network clients" is checked.
# Run xhost + ${hostname} to allow connections to the macOS host *