extends Reference

var start_timings := {}
var timings := {}

func clear() -> void:
	start_timings.clear()
	timings.clear()

func start(name: String) -> void:
	start_timings[name] = OS.get_ticks_usec()

func stop(name: String) -> void:
	assert(start_timings.has(name), "stop() without start() for %s" % name)
	timings[name] = OS.get_ticks_usec() - start_timings[name]
	start_timings.erase(name)

func get_total() -> int:
	var total := 0
	for key in timings:
		total += timings[key]
	return total

func print_timings() -> void:
	assert(start_timings.size() == 0, "there are unstopped timers: %s" % str(start_timings.keys()))
	var total := get_total()
	for key in timings:
		print ("%s: %s ms" % [key, float(timings[key]) / 1000.0])
	print(" * total: %s" % (float(total) / 1000.0))
