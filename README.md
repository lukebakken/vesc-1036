# Reproducing VESC-1036

## Initial docker images

```
make image-base-3.8
make image-vesc-1036
```

## Start cluster

```
docker compose up
```

Management UI ports:
* Upstream cluster
  * `15682`
  * `15683`
  * `15684`
* Downstream cluster
  * `15672`
  * `15673`
  * `15674`

## Import definitions

Once the cluster has formed, run the following to import definitions:

```
./import-defs.sh
```

At this point PerfTest may have given up. You can restart with this command:

```
docker compose up --detach
```

## Confirm

Confirm that both clusters are running, and that you see messages flowing from
the `federated-direct` exchange to the downstream `federated-ds` queue, which
are then consumed by PerfTest. Confirm the running federation link in the
downstream cluster UI

## Upgrade

Upgrade the docker images:

```
make image-base
make image-vesc-1036
```

## Cluster upgrade

The upgrade script puts the node into maintenance mode, then restarts the
container using the new image. The hostname remains the same of course so that
the data volume directory volume.

* Upstream first:
    ```
    ./upgrade.sh us
    ```
* Downstream:
    ```
    ./upgrade.sh ds
    ```

At this point, go to the management UI on a downstream node and check the
federation link status. It will not be running. Re-importing the defs has no
effect, either.
