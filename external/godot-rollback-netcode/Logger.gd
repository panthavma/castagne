extends Reference

enum LogType {
	HEADER,
	FRAME,
	STATE,
	INPUT,
}

enum FrameType {
	INTERFRAME,
	TICK,
	INTERPOLATION_FRAME,
}

enum SkipReason {
	ADVANTAGE_ADJUSTMENT,
	INPUT_BUFFER_UNDERRUN,
	WAITING_TO_REGAIN_SYNC,
}

var data := {}

var _start_times := {}

var _writer_thread: Thread
var _writer_thread_semaphore: Semaphore
var _writer_thread_mutex: Mutex
var _write_queue := []
var _log_file: File
var _started := false

var SyncManager

func _init(_sync_manager) -> void:
	# Inject the SyncManager to prevent cyclic reference.
	SyncManager = _sync_manager
	
	_writer_thread_mutex = Mutex.new()
	_writer_thread_semaphore = Semaphore.new()
	_writer_thread = Thread.new()
	_log_file = File.new()

func start(log_file_name: String, peer_id: int) -> int:
	if not _started:
		var err: int
		
		err = _log_file.open(log_file_name, File.WRITE)
		if err != OK:
			return err
		
		var header := {
			log_type = LogType.HEADER,
			peer_id = peer_id,
		}
		_log_file.store_string(JSON.print(header) + "\n")
		
		_started = true
		_writer_thread.start(self, "_writer_thread_function")
	
	return OK

func stop() -> void:
	_writer_thread_mutex.lock()
	var is_running = _started
	_writer_thread_mutex.unlock()
	
	if is_running:
		if data.size() > 0:
			write_current_data()
		
		_writer_thread_mutex.lock()
		_started = false
		_writer_thread_mutex.unlock()
		
		_writer_thread_semaphore.post()
		_writer_thread.wait_to_finish()
		
		_log_file.close()
		_write_queue.clear()
		data.clear()
		_start_times.clear()

func _writer_thread_function() -> void:
	while true:
		_writer_thread_semaphore.wait()
		
		var data_to_write
		var should_exit: bool
		
		_writer_thread_mutex.lock()
		data_to_write = _write_queue.pop_front()
		should_exit = not _started
		_writer_thread_mutex.unlock()
		
		if data_to_write is Dictionary:
			_log_file.store_string(JSON.print(data_to_write) + "\n")
		elif should_exit:
			break

func write_current_data() -> void:
	if data.size() == 0:
		return
	
	var copy := data.duplicate(true)
	copy['log_type'] = LogType.FRAME
	
	if not copy.has('frame_type'):
		copy['frame_type'] = FrameType.INTERFRAME
	
	_writer_thread_mutex.lock()
	_write_queue.push_back(copy)
	_writer_thread_mutex.unlock()
	
	_writer_thread_semaphore.post()
	
	data.clear()

func write_state(tick: int, state: Dictionary, state_hash: int) -> void:
	var data_to_write := {
		'log_type': LogType.STATE,
		'tick': tick,
		'$': state_hash,
		'state': state.duplicate(true), 
	}
	
	_writer_thread_mutex.lock()
	_write_queue.push_back(data_to_write)
	_writer_thread_mutex.unlock()
	
	_writer_thread_semaphore.post()

func write_input(tick: int, input: Dictionary) -> void:
	var data_to_write := {
		log_type = LogType.INPUT,
		tick = tick,
		input = {},
	}
	for key in input.keys():
		data_to_write['input'][key] = SyncManager.hash_serializer.serialize(input[key].input.duplicate(true))
	
	_writer_thread_mutex.lock()
	_write_queue.push_back(data_to_write)
	_writer_thread_mutex.unlock()
	
	_writer_thread_semaphore.post()

func begin_interframe() -> void:
	if not data.has('frame_type'):
		data['frame_type'] = FrameType.INTERFRAME
	if not data.has('start_time'):
		data['start_time'] = OS.get_system_time_msecs()

func end_interframe() -> void:
	if not data.has('frame_type'):
		data['frame_type'] = FrameType.INTERFRAME
	if not data.has('start_time'):
		data['start_time'] = OS.get_system_time_msecs() - 1
	data['end_time'] = OS.get_system_time_msecs()
	write_current_data()

func begin_tick(tick: int) -> void:
	if data.size() > 0:
		end_interframe()
	
	data['frame_type'] = FrameType.TICK
	data['tick'] = tick
	data['start_time'] = OS.get_system_time_msecs()

func end_tick(start_ticks_usecs: int) -> void:
	data['end_time'] = OS.get_system_time_msecs()
	data['duration'] = float(OS.get_ticks_usec() - start_ticks_usecs) / 1000.0
	write_current_data()

func skip_tick(skip_reason: int, start_ticks_usecs: int) -> void:
	data['skipped'] = true
	data['skip_reason'] = skip_reason
	end_tick(start_ticks_usecs)

func begin_interpolation_frame(tick: int) -> void:
	if data.size() > 0:
		end_interframe()
	
	data['frame_type'] = FrameType.INTERPOLATION_FRAME
	data['tick'] = tick
	data['start_time'] = OS.get_system_time_msecs()

func end_interpolation_frame(start_ticks_usecs: int) -> void:
	data['end_time'] = OS.get_system_time_msecs()
	data['duration'] = float(OS.get_ticks_usec() - start_ticks_usecs) / 1000.0
	write_current_data()

func log_fatal_error(msg: String) -> void:
	if not data.has('end_time'):
		data['end_time'] = OS.get_system_time_msecs()
	data['fatal_error'] = true
	data['fatal_error_message'] = msg
	write_current_data()

func set_value(key: String, value) -> void:
	data[key] = value

func add_value(key: String, value) -> void:
	if not data.has(key):
		data[key] = []
	data[key].append(value)

func merge_array_value(key: String, value: Array) -> void:
	if not data.has(key):
		data[key] = value
	else:
		data[key] = data[key] + value

func increment_value(key: String, amount: int = 1) -> void:
	if not data.has(key):
		data[key] = amount
	else:
		data[key] += amount

func start_timing(timer: String) -> void:
	assert(not _start_times.has(timer), "Timer already exists: %s" % timer)
	_start_times[timer] = OS.get_ticks_usec()

func stop_timing(timer: String) -> void:
	assert(_start_times.has(timer), "No such timer: %s" % timer)
	if _start_times.has(timer):
		add_timing(timer, float(OS.get_ticks_usec() - _start_times[timer]) / 1000.0)
		_start_times.erase(timer)

func add_timing(timer: String, msecs: float) -> void:
	if not data.has('timings'):
		data['timings'] = {}
	assert(not data['timings'].has(timer), "Already added a timing for %s" % timer)
	data['timings'][timer] = msecs
