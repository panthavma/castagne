extends Reference

const DEFAULT_MESSAGE_BUFFER_SIZE = 1280

enum InputMessageKey {
	NEXT_INPUT_TICK_REQUESTED,
	INPUT,
	NEXT_HASH_TICK_REQUESTED,
	STATE_HASHES,
}

func serialize_input(input: Dictionary) -> PoolByteArray:
	return var2bytes(input)

func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	return bytes2var(serialized)

func serialize_message(msg: Dictionary) -> PoolByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(DEFAULT_MESSAGE_BUFFER_SIZE)

	buffer.put_u32(msg[InputMessageKey.NEXT_INPUT_TICK_REQUESTED])
	
	var input_ticks = msg[InputMessageKey.INPUT]
	buffer.put_u8(input_ticks.size())
	if input_ticks.size() > 0:
		var input_keys = input_ticks.keys()
		input_keys.sort()
		buffer.put_u32(input_keys[0])
		for input_key in input_keys:
			var input = input_ticks[input_key]
			buffer.put_u16(input.size())
			buffer.put_data(input)
	
	buffer.put_u32(msg[InputMessageKey.NEXT_HASH_TICK_REQUESTED])
	
	var state_hashes = msg[InputMessageKey.STATE_HASHES]
	buffer.put_u8(state_hashes.size())
	if state_hashes.size() > 0:
		var state_hash_keys = state_hashes.keys()
		state_hash_keys.sort()
		buffer.put_u32(state_hash_keys[0])
		for state_hash_key in state_hash_keys:
			buffer.put_u32(state_hashes[state_hash_key])
	
	buffer.resize(buffer.get_position())
	return buffer.data_array

func unserialize_message(serialized) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var msg := {
		InputMessageKey.INPUT: {},
		InputMessageKey.STATE_HASHES: {},
	}
	
	msg[InputMessageKey.NEXT_INPUT_TICK_REQUESTED] = buffer.get_u32()
	
	var input_tick_count = buffer.get_u8()
	if input_tick_count > 0:
		var input_tick = buffer.get_u32()
		for input_tick_index in range(input_tick_count):
			var input_size = buffer.get_u16()
			msg[InputMessageKey.INPUT][input_tick] = buffer.get_data(input_size)[1]
			input_tick += 1
	
	msg[InputMessageKey.NEXT_HASH_TICK_REQUESTED] = buffer.get_u32()
	
	var hash_tick_count = buffer.get_u8()
	if hash_tick_count > 0:
		var hash_tick = buffer.get_u32()
		for hash_tick_index in range(hash_tick_count):
			msg[InputMessageKey.STATE_HASHES][hash_tick] = buffer.get_u32()
			hash_tick += 1
	
	return msg
