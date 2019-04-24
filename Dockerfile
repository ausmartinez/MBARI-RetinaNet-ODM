FROM tensorflow/tensorflow:latest

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y python3-pip && \
    apt-get install -y python3-tk && \
    apt-get install -y python-opencv && \
    apt-get install -y git && \
	apt-get install -y unzip

# Install needed proto binary and clean
WORKDIR /tmp/protoc3
RUN wget https://github.com/google/protobuf/releases/download/v3.4.0/protoc-3.4.0-linux-x86_64.zip
RUN unzip /tmp/protoc3/protoc-3.4.0-linux-x86_64.zip
RUN mv /tmp/protoc3/bin/* /usr/local/bin/
RUN mv /tmp/protoc3/include/* /usr/local/include/
RUN rm -Rf /tmp/protoc3

ENV APP_HOME /code
WORKDIR ${APP_HOME}
ENV PATH=${PATH}:${APP_HOME}

# Install Tensorflow models and object detection code
RUN git clone https://github.com/tensorflow/models.git tensorflow_models
ENV PYTHONPATH=${APP_HOME}:${APP_HOME}/tensorflow_models/research:${APP_HOME}/tensorflow_models/research/slim:${APP_HOME}/tensorflow_models/research/object_detection

# build protobufs
RUN cd ${APP_HOME}/tensorflow_models/research && protoc object_detection/protos/*.proto --python_out=.

WORKDIR /install
RUN pip3 install --upgrade pip
ADD requirements.txt /install
ADD create_tfrecord.py ${APP_HOME}
RUN pip3 install -r /install/requirements.txt

WORKDIR ${APP_HOME}
ENTRYPOINT ["python3", "create_tfrecord.py"]
