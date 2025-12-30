
docker run --name databend-meta    \
      --privileged \
      --network=host \
      -v /home/vagrant/meta:/var/lib/databend/meta \
      -v /data/databend/log:/var/log/databend \
      -v /etc/databend:/etc/databend \
      -e METASRV_CONFIG_FILE='/etc/databend/databend-meta.toml' \
      -d registry.databend.cn/public/databend-meta:v1.2.860-nightly


docker stop databend3307
docker rm databend3307
docker run --name databend3307    \
      --privileged \
      --network=host \
      -v /etc/databend:/etc/databend \
      -v /etc/localtime:/etc/localtime \
      -v /data/databend/3307:/var/log/databend \
      -v /data/databend/3307disk:/var/lib/databend \
      -e CONFIG_FILE="/etc/databend/databend-query-3307.toml" \
      -d registry.databend.cn/public/databend-query:v1.2.860-nightly
