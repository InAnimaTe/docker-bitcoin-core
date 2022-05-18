## Bitcoin Core Sample

This is an example `bitcoind` repository containing a Dockerfile, Kubernetes Resources, and Gitlab CI pipeline.

It also includes an ip-frequency program useful for sorting though web server logs.

Terraform module and Nomad WAGMI examples were not included as to provide more time for better runtime security (`deployment.yaml`) and creation of `ipfreq.py` in Python 3.

### Storage

`bitcoind` will require storage for blocks it collects on initial start. I've created a `pvc.yaml` to utilize a GCP persisitent disk alloting a bit over the usually recommended 250GB. This is an example so tuning may be required for practical usage.

### Security

Best Practices in term of Dockerfile image building (i.e. remove suid binaries) as well as Kubernetes runtime execution (i.e. disable privilege escalation) were used to ensure this container's attack surface is greatly reduced. Additionally, see `docker-scan-report.txt` in this repository for a Snyk `docker scan` report.

> Note: As of 05/17/22, there is a critical vulnerability in libssl which has not yet been patched.

### Why not Multi-Stage?

I decided against using multistage as we weren't exactly "building" assets, but instead leveraging an already built binary `bitcoind` as a the main container process.
I cleaned up the tools used fairly well within one `RUN` statement as to decrease size + layers while increasing build speed.

> If you delete a file that was created in a different layer, all the union filesystem does is register the filesystem change in a new layer, the file still exists in the previous layer and is shipped over the networked and stored on disk.

More [details](https://stackoverflow.com/a/39330458) on `RUN`, layering, and more.