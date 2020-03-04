require "bootstrap-tests"

local effil = effil

test.thread_interrupt.tear_down = default_tear_down

local function interruption_test(worker)
    local state = effil.table({ stop = false })

    local ctx = effil.thread(worker)
    ctx.step = 0
    local thr = ctx(state)

    effil.sleep(500, 'ms') -- let thread starts

    local start_time = os.time()
    thr:cancel(1)

    test.equal(thr:status(), "canceled")
    test.almost_equal(os.time(), start_time, 1)
    state.stop = true
end

local get_thread_for_test = function(state)
    local runner = effil.thread(function()
        while not state.stop do end
    end)
    runner.step = 0
    return runner()
end

test.thread_interrupt.thread_wait_p = function(params)
    interruption_test(function(state)
        get_thread_for_test(state):wait(table.unpack(params))
    end)
end

test.thread_interrupt.thread_get_p = function(params)
    interruption_test(function(state)
        get_thread_for_test(state):get(table.unpack(params))
    end)
end

test.thread_interrupt.thread_cancel_p = function(params)
    interruption_test(function(state)
        get_thread_for_test(state):cancel(table.unpack(params))
    end)
end

test.thread_interrupt.thread_pause_p = function(params)
    interruption_test(function(state)
        get_thread_for_test(state):pause(table.unpack(params))
    end)
end

test.thread_interrupt.channel_pop_p = function(params)
    interruption_test(function()
        effil.channel():pop(table.unpack(params))
    end)
end

local test_timimgs = {
    {}, -- infinite wait
    {10, 's'},
}

for _, test_config in ipairs(test_timimgs) do
    test.thread_interrupt.thread_wait_p(test_config)
    test.thread_interrupt.thread_get_p(test_config)
    test.thread_interrupt.thread_cancel_p(test_config)
    test.thread_interrupt.thread_pause_p(test_config)
    test.thread_interrupt.channel_pop_p(test_config)
end

test.thread_interrupt.sleep = function()
    interruption_test(function()
        effil.sleep(20)
    end)
end

test.thread_interrupt.yield = function()
    interruption_test(function()
        while true do
            effil.yield()
        end
    end)
end
