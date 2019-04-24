docker run -it --rm \
-v $PWD/data:/data \
preprocess \
-l /data/label.pbtxt \
--resize 960x540 \
-d /data/annotations \
--image_path /data/imgs \
-o /data/STAM_960x540_train.record \
-s train
