# MBARI-RetinaNet-ODM

This repo contains the Python and Bash scripts pipeline to prepare data and train the GCP RetinaNet TPU model MBARI's Station M Images via GCP's cloud architecture. All scripts run relative to our given data set. If you are using a different dataset, much of this repository won't work, but the primary methodology will still apply. This README will address these differences and what one might change in order to use a separate dataset. 

###### Authors

* Andrea Cano
* Sampson Liao
* Austin Martinez
* Kirk Worley

## Install
#### Base Installation 
* Download and install the latest version of docker [Docker](https://www.docker.com/)
* Download and install [Python 3](https://www.python.org/download/releases/3.0/).
* Install Tensorflow Docker image using `docker pull tensorflow/tensorflow`
* Run a `git pull` on this repository

#### CVAT 
Part of this project was setting up and configuring CVAT to label images. If you are attempting to install CVAT we have written some documentation on how to do so [here](https://docs.google.com/document/d/1277nbsISsqZBLsdxFQCm6-fhEhYLTtJpRFNCSxvR40I/edit?usp=sharing).

## Preparing the Data

##### *** All Scripts are destructive. Make sure to backup your data. ***

The primary operation of the `Dockerfile`, is to run `create_tfrecord.py`. The RetinaNet TPU accepts Tensorflow Records (tfrecords) for training/testing data input. We have not been able to successfully train the model using file types other than tfrecords. [Tutorials and documentation](https://cloud.google.com/tpu/docs/tutorials/retinanet) for RetinaNet operate under the assumption that you have properly formatted and saved tfrecords. 

The `create_tfrecord.py` file generates tfrecords specific to our Station M data. If you are looking to use custom data, you must construct tfrecords that adhere to it. We do not recommend an alteration of either the `Dockerfile` or the `create_tfrecords.py` file, as both adhere strictly to the file structure of our given data. Custom data will require a custom solution to generate tfrecords. You do not necessarily need to use Docker, for instance. 

[Here](https://medium.com/mostly-ai/tensorflow-records-what-they-are-and-how-to-use-them-c46bc4bbb564) is a helpful tutorial for understanding tfrecords.

#### Remove Non-numeric Characters from Files

Something important not mentioned by GCP, is that the names of your images must **only** consist of numbers, and the file extension must be removed before creating tfrecords. If you run into an error when training on the cloud that looks something like:
```
Error recorded from infeed: StringToNumberOp could not norrectly convert string
```
you need to remove all non-numeric characters from your images before you create tfrecords, which in our case, is before using the `Dockerfile` that runs `create_tfrecord.py`. 

`scripts/rename_data.sh` is a script that removes characters and extensions then propagates the names changes across all files necessary to create tfrecords via `create_tfrecord.py`. This script is only compatible with the `.pbtxt` file structure. However, one could use the same operations found in the script to rename their own data, revised as needed.

To run `scripts/rename_data.sh`, ensure proper execution permissions are set via `chmod` or equivalent permission methods, then run `./scripts/rename_data.sh` with `-a` tag to denote the annotation XML folder location and `-i` tag to denote the image folder location. The image names will be changed to only contain numbers, and their associated reference in the annotation XML files will reflect this change.

#### Generating tfrecords

After ensuring correct naming conventions (in this case, only numbers in the file names), the last step before training on the cloud is to generate the tfrecords:

* Build Docker image with preprocess tag using `docker build -t preprocess .`
* Ensure proper permissions, then run `./train_test.sh`.

If class labels within the protobuf text file (`labels.pbtxt`) do not match labels for the dataset, run `./scripts/enerate_labels.sh`

If using a custom dataset, a different pipeline may be needed to create tfrecords. The dockerfile will run `create_tfrecord.py` to create tfrecords in accordance with the data provided by MBARI. Testing on a different dataset with protobuf formatting has not been done.

If generating tfrecords for a custom dataset, the names for each element within the tfrecord will 

#### Training on the Cloud

After preparing your data and creating the tfrecords, the next step is to train the RetinaNet model on the cloud. The process heavily mirrors the process detailed in the [GCP tutorial](https://cloud.google.com/tpu/docs/tutorials/retinanet), however some parts of the tutorials don't work by themselves. So here is our process:

1. Create a GCP bucket and import your tfrecords into it using whatever file structure you would like. Take note of how you name the tfrecord file itself. 
2. Start up your CTPU: `ctpu up`, then install the RetinaNet model: `git clone https://github.com/tensorflow/tpu/`.
3. Link your ctpu instance to your storage bucket with: `export STORAGE_BUCKET=gs://YOUR-BUCKET-NAME`
4.  In this repo `scripts/retina_train.sh` contains the script to train the RetinaNet model. Run the script on your CTPU, changing flags and paths as needed.
	
    If we look closer at the script itself, we can see what needs to change according to the data being used. 
    
	`export MODEL_DIR=${STORAGE_BUCKET}/retinanet-model` details the location to where RetinaNet will export the saved model in your bucket. In this case, your bucket will have a folder called 'retinanet-model', which will contain tensorflow checkpoints and the `saved_model.pb` with variables after training. The export parameters are not controlled by the user, as may be the case with other models (at least not without modifying the source code).
    
    The `retinanet_main.py` flag, `--training_file_pattern` details the location of the training data in the form of tfrecords. Currently, the script points to the exact name exported from `create_tfrecords.py`, located inside the storage bucket: `--training_file_pattern=${STORAGE_BUCKET}/MBARI_BENTHIC_2017_960x540_train.record`. This can be changed to meet the naming of other data and supports globbing. For instance, if you have multiple training records located in a folder called 'data' in your storage bucket and each record follows a name of 'train_NUMBER.record', the flag may look like: `--training_file_pattern=${STORAGE_BUCKET}/data/train_*.record`
    
    A hyperparameter not mentioned in documentation is `num_classes`. The GCP TPU RetinaNet implementation is made with the COCO dataset, which has 81 label classes. However, the model does not auto detect the number of classes that exist in your tfrecords, as may be the case with other models. So you must define the number of classes in your data, otherwise it will assume and train for 81 classes. Define the number of classes using the hyperparameter flag like so: `--hparams=image_size=640,num_classes=9`. The model itself reshapes the images in a NxN shape denoted by `image_size=N`

#### Running Inference

Running inference is relatively simple. `inference/model_inference.py` contains some details written in the script's comments. The script itself contains the basic functionality to pass an unlabeled image through the model. If looking to pass a batch of images, additional functionality must be added, as the script simply uses a single image. This was done, as interpretation of the outputted weights was not achieved in this project. The [Focal Loss Research Paper](https://arxiv.org/pdf/1708.02002.pdf), from which RetinaNet is derived, says that RetinaNet's bounding box regression format is the same as Feature Pyramid Networks described by [this paper](http://openaccess.thecvf.com/content_cvpr_2017/papers/Lin_Feature_Pyramid_Networks_CVPR_2017_paper.pdf). However, proper interpretation of this output was above our skill level, and the inference methods provided by GCP are not fully compatible with the RetinaNet Model as of writing. We would suggest further research into the ins and outs of bounding box regression techniques to establish a solid understanding of this branch of machine learning before attempting to tackle the RetinaNet.
