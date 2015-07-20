# Varnish with GeoIP Docker container

> Debian 8
> Varnish 4.x
> GeoIP

## Usage

In order to use this container, you shoud provide a valid 4.0 varnish configuration file.

```
docker run -d \
  --restart=always \
  --name varnish_geoip \
  -p 80:6081 \
  -v CONFIG_DIR/default.vcl:/etc/varnish/default.vcl:ro \
  bqitdevops/varnish4-geoip
```

In this container, varnish listens on its default port, which is 6081. You should link your desired port on the host machine to the varnish one (port 80 by default).

In order to use the GeoIP library, you shoud import it:

```
import geoip;

sub vcl_recv {
        # This sets req.http.X-Country-Code to the country code
        # associated with the client IP address
        set req.http.X-Country-Code = geoip.country_code(client.ip);
}
```

## GeoIP License and updates

By default, this container uses the GeoLite2 database (free, updated monthly).
If you want to use a purchased database, you should link the license file with the container one:

```
-p LICENSE_DIR/GeoIP.conf /usr/local/etc/GeoIP.conf 
```

In addition this containers has geoipupdate, which (via cron) updates the databases every friday.

## Links to software used

> [Varnish](https://www.varnish-cache.org/)
> [Varnish GeoIP library](https://github.com/varnish/libvmod-geoip)
> [GeoIP](https://www.maxmind.com/en/geoip2-databases)
> [GeoIP Update](https://github.com/maxmind/geoipupdate)

## Author(s)

* Julio Chana (<julio.chana@bq.com>)

---
**Sponsored by** [BQ](http://www.bq.com)
