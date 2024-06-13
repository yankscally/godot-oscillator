extends AudioStreamWAV
class_name AudioStreamWaveform

@export_enum("sine", "square", "sawtooth", "triangle") var wave_type: int : set = bake_audio

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
	var frequency = 440.0 # Standard A note
	var sample_rate = 44100.0 # Standard sample rate
	match noise_type:
		0: # Sine
			for frame in range(frames_available):
				var phase = (frame / sample_rate) * frequency * TAU
				var sine = sin(phase)
				frames.append(Vector2(sine, sine))

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
