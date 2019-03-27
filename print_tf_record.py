import cv2
import tensorflow as tf

for example in tf.python_io.tf_record_iterator("STAM_1000x667_train.record"):
	result = tf.train.Example.FromString(example)
print (result)
