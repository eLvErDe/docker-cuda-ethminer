# nvidia-docker image for CUDA ethminer

This image build [ethminer] from GitHub with CUDA support.
It requires a CUDA compatible docker implementation so you should probably go
for [nvidia-docker].
It has also been tested successfully on [Mesos] 1.2.1.

## Build images

```
git clone https://github.com/eLvErDe/docker-cuda-ethminer
cd docker-cuda-ethminer
docker build -t cuda-ethminer .
```

## Test it locally (benchmark mode)

```
nvidia-docker run -it --rm cuda-ethminer /root/ethminer -U -M
```

If it works correctly, it'll do a CUDA benchmarking:

```
[CUDA]:Using grid size 8192, block size 128

Benchmarking on platform: CUDA
Preparing DAG for block #0
Warming up...
  ℹ  07:45:28|cudaminer0  set work; seed: #00000000, target:  #000000000000
  ℹ  07:45:28|cudaminer0  Initialising miner...
Using device: GeForce GTX 1080 (Compute 6.1)
Generating DAG for GPU #0
CUDA#0: 0%
CUDA#0: 6%
CUDA#0: 12%
CUDA#0: 19%
CUDA#0: 25%
CUDA#0: 31%
CUDA#0: 38%
CUDA#0: 44%
CUDA#0: 50%
CUDA#0: 56%
CUDA#0: 62%
CUDA#0: 69%
CUDA#0: 75%
CUDA#0: 81%
CUDA#0: 88%
CUDA#0: 94%
Trial 1... 20971520
Trial 2... 20971520
Trial 3... 20971520
Trial 4... 21321045
Trial 5... 20971520
min/mean/max: 20971520/21041425/21321045 H/s
inner mean: 7107015 H/s
```

## Publish it somewhere

```
docker tag cuda-ethminer docker.domain.com/mining/cuda-ethminer
docker push docker.domain.com/mining/cuda-ethminer
```

## Use it with Mesos/Marathon

Edit `mesos_marathon.json` to replace ethermine.org by something else (not necessary), set your Ethereum mining key and change application path as well as docker image address.
Then simply run (adapt application name here too):

```
curl -X PUT -u marathon\_username:marathon\_password --header 'Content-Type: application/json' "http://marathon.domain.com:8080/v2/apps/mining/cuda-ethminer?force=true" -d@./mesos\_marathon.json
```

You can check CUDA usage on the mesos slave (executor host) by running `nvidia-smi` there:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 375.66                 Driver Version: 375.66                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 1080    Off  | 0000:82:00.0     Off |                  N/A |
| 45%   62C    P2   126W / 180W |   2221MiB /  8114MiB |    100%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID  Type  Process name                               Usage      |
|=============================================================================|
|    0     17667    C   /root/ethminer                                2219MiB |
+-----------------------------------------------------------------------------+
```

[ethminer]: https://github.com/ethereum-mining/ethminer
[nvidia-docker]: https://github.com/NVIDIA/nvidia-docker
[Mesos]: http://mesos.apache.org/documentation/latest/gpu-support/
