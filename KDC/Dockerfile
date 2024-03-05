FROM makrov/hadoop-kdc-server
VOLUME [ "/root/keytabs" ]
COPY --chmod=777 init-script.sh /tmp/
COPY --chmod=777 create-principals.sh /tmp/
CMD /tmp/init-script.sh
