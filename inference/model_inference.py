import tensorflow as tf
from tensorflow.python.saved_model import loader
from tensorflow.python.saved_model import tag_constants
import numpy as np

'''
The directory conatining the saved model must look like this:
saved_model/
	|
	|saved_model.pb
	|variables/	
		|
		|variables.data-00000-of-00001
		|variables.index

Adjust for relative path locations as needed, but everything inside your 
`saved_model` directory needs these specific names for both the files
folders. 
'''

# Model directory where the `SavedModel` is stored
model_dir = "../saved_model/"

# Name of the input placeholder(tensor) that receives the input data
model_input = "Placeholder:0"

# Name of the output placeholder
model_outputs = "map_1/TensorArrayStack/TensorArrayGatherV3:0"

# Run our session
with tf.Session() as sess:
	# Print inputs and outputs (not required to run the script)
	graph = tf.Graph()
	with graph.as_default():
		metagraph = tf.saved_model.loader.load(sess, [tag_constants.SERVING],model_dir)
	inputs_mapping = dict(metagraph.signature_def['serving_default'].inputs)
	outputs_mapping = dict(metagraph.signature_def['serving_default'].outputs)
	#print (inputs_mapping)
	#print (outputs_mapping)

	'''
	Prepare the image to pass into the tf session. This will need to be improved
	to allow for all images in a given directory to be read as bytes, appended to
	a numpy array, then pass into the session.
	'''
	with open("StaM_6805_nf_duo_tripod_20171112_21_58_33p.JPG", "rb") as image:
		f = image.read()
		b = bytes(f)
		#print (b)

	# Run the inference
	loader.load(sess, [tag_constants.SERVING], model_dir).signature_def
	a = sess.run(model_outputs, feed_dict={model_input: np.array(b).reshape(-1)})
	print (a)

