# MBARI-RetinaNet-ODM

* Andrea Cano
* Sampson Liao
* Austin Martinez
* Kirk Worley

## Install
System will require [Docker](https://www.docker.com/) and [Python 3](https://www.python.org/download/releases/3.0/).

* Run a `git pull` on this repository
* Switch to `macOS` branch using `git checkout macOS`
* Install Tensorflow Docker image using `docker pull tensorflow/tensorflow`
* Build Docker image with preprocess tag using `docker build -t preprocess .`
* Ensure proper permissions, then run `./train_test.sh`
