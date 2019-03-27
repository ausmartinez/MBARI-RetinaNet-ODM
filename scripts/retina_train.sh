export RESNET_CHECKPOINT=gs://cloud-tpu-artifacts/resnet/resnet-nhwc-2018-10-14/model.ckpt-112602
export MODEL_DIR=${STORAGE_BUCKET}/retinanet-model

python tpu/models/official/retinanet/retinanet_main.py \
 --tpu=$TPU_NAME \
 --train_batch_size=32 \
 --training_file_pattern=${STORAGE_BUCKET}/MBARI_BENTHIC_2017_960x540_train.record	 \
 --resnet_checkpoint=${RESNET_CHECKPOINT} \
 --model_dir=${MODEL_DIR} \
 --hparams=image_size=640 \
 --num_examples_per_epoch=50 \
 --num_epochs=1
