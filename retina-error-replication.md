# Replicating the errors

Follow the [GCP tutorial](https://cloud.google.com/tpu/docs/tutorials/retinanet) up until the `Prepare the COCO dataset` section. In this section, the user downloads 100Gb of photos, which are then converted into TFRecords. These TFRecords are then copied over to your GCP Bucket. But we want to use the TFRecords for our own dataset. 

Instead, simply upload your TFRecords directly into the bucket. Then we try to run through the rest of the steps after `Prepare the COCO dataset` except changing names and directories when needed. 

### Then run these commands

The RetinaNet training application requires several extra packages. Install them now:
```
export STORAGE_BUCKET=gs://NAME-OF-YOUR-BUCKET
sudo apt-get install -y python-tk
pip install Cython matplotlib
pip install 'git+https://github.com/cocodataset/cocoapi#egg=pycocotools&subdirectory=PythonAPI'
```

These last commands are as far as we get before encountering the error. 

```
export RESNET_CHECKPOINT=gs://cloud-tpu-artifacts/resnet/resnet-nhwc-2018-10-14/model.ckpt-112602
export MODEL_DIR=${STORAGE_BUCKET}/retinanet-model

python tpu/models/official/retinanet/retinanet_main.py \
 --tpu=$TPU_NAME \
 --train_batch_size=64 \
 --training_file_pattern=${STORAGE_BUCKET}/pathTo/TFRecords/*train* \
 --resnet_checkpoint=${RESNET_CHECKPOINT} \
 --model_dir=${MODEL_DIR} \
 --hparams=image_size=640 \
 --num_examples_per_epoch=100 \
 --num_epochs=1
```

It will take a few moments to to eventually stop running, but you should expect an error similar to this.

` --training_file_pattern=${STORAGE_BUCKET}/pathTo/TFRecords/*train* \` is the only line that differs from the tutorial. We feel this should get the most attention as it points to the TFRecords we uploaded to the bucket. 

```
Error recorded from infeed: StringToNumberOp could not norrectly convert string: StaM_6701_NF_tripod_20161114_03_13_42.JPG
	[[{{node parser/StringToNumber}}]]
    [[node input_pipeline_task0/while/IteratorGetNext (defined at /usr/local/lib/python2.7/dist-packages/tensorflow_estimator/python/estimator/estimator.py:1112) ]]
```
