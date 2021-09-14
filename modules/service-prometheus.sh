## Add service users - for Prometheus
groupadd prometheus
useradd --system -g prometheus --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /opt/prometheus
chown -R prometheus:prometheus /opt/prometheus
cd /opt/prometheus
curl -LOk https://github.com/prometheus/prometheus/releases/download/v2.23.0/prometheus-2.23.0.linux-amd64.tar.gz
tar xvf prometheus-2.23.0.linux-amd64.tar.gz
cp prometheus-2.23.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.23.0.linux-amd64/promtool /usr/local/bin/
chown -R prometheus:prometheus /usr/local/bin/prometheus
chown -R prometheus:prometheus /usr/local/bin/promtool
cp -r prometheus-2.23.0.linux-amd64/consoles /etc/prometheus/
cp -r prometheus-2.23.0.linux-amd64/console_libraries /etc/prometheus/
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /opt/prometheus
rm -rf /opt/prometheus-2.23.0.linux-amd64*

mv /tmp/kickstart/stakingnode/openSUSE/etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
chown prometheus:prometheus /etc/prometheus/prometheus.yml
chmod 600 /etc/prometheus/prometheus.yml

mv /tmp/kickstart/stakingnode/openSUSE/etc/systemd/system/prometheus.service /etc/systemd/system/
chown root:root /etc/systemd/system/prometheus.service
chmod 644 /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
