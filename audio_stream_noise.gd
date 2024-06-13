extends AudioStreamWAV
class_name AudioStreamNoise

@export_enum("white", "pink", "brown") var noise_type: int : set = bake_audio

var frames_size = 44100 # the amount of frames it takes for noise not sound repeated.. 
var audio_frames = []
var playback: AudioStreamPlayback
var is_stereo

func _init():
	is_stereo = true
	format = FORMAT_16_BITS
	loop_end = frames_size 
	loop_mode = LOOP_FORWARD

func bake_audio(type):
	audio_frames = fill_frames(type)
	data = convert_frames_to_pcm(audio_frames, stereo)

func fill_frames(noise_type):
	var frames = []
	var frames_available = frames_size
	
	match noise_type:
		0: # White noise
			for i in range(frames_available):
				frames.append(Vector2(randi_range(-10000, 10000) / 10000.0, randi_range(-10000, 10000) / 10000.0))
		1: # Pink noise
			var white = []
			var b0 = 0.0
			var b1 = 0.0
			var b2 = 0.0
			var b3 = 0.0
			var b4 = 0.0
			var b5 = 0.0
			var b6 = 0.0
			for i in range(frames_available):
				white.append(randi_range(-10000, 10000) / 10000.0)
				b0 = 0.99886 * b0 + white[-1] * 0.0555179
				b1 = 0.99332 * b1 + white[-1] * 0.0750759
				b2 = 0.96900 * b2 + white[-1] * 0.1538520
				b3 = 0.86650 * b3 + white[-1] * 0.3104856
				b4 = 0.55000 * b4 + white[-1] * 0.5329522
				b5 = -0.7616 * b5 - white[-1] * 0.0168980
				var pink = b0 + b1 + b2 + b3 + b4 + b5 + white[-1] * 0.5362
				frames.append(Vector2(pink * 0.11, pink * 0.11))
		2: # Brown noise
			var last = 0.0
			for i in range(frames_available):
				var white = randi_range(-10000, 10000) / 10000.0
				last = (last + (0.02 * white)) / 1.02
				frames.append(Vector2(last * 3.5, last * 3.5))


	return frames

func convert_frames_to_pcm(frames, is_stereo):
	var bytes = PackedByteArray()
	var sample_count = frames.size()
	var channels = 2
	for frame in frames:
		var left_sample = int(frame.x * 32767.0)
		bytes.push_back(left_sample & 0xFF)
		bytes.push_back((left_sample >> 8) & 0xFF)
		if is_stereo:
			var right_sample = int(frame.y * 32767.0)
			bytes.push_back(right_sample & 0xFF)
			bytes.push_back((right_sample >> 8) & 0xFF)
	return bytes
