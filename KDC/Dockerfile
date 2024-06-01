FROM makrov/hadoop-kdc-server
VOLUME [ "/root/keytabs" ]
COPY ./Common/krb5.conf /etc/krb5.conf
COPY --chmod=777 ./KDC/init-script.sh /tmp/
COPY --chmod=777 ./KDC/create-principals.sh /tmp/
CMD /tmp/init-script.sh
