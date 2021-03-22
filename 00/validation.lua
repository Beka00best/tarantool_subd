local fiber = require('fiber')

local function get_space()
    local space = box.space.validation_queue
    if space ~= nil then
        return space
    end

    box.begin()

    space = box.schema.space.create('validation_queue')

    space:format({
        { name = 'email',   type = 'string',    is_nullable = false }
    })

    space:create_index('email', {
        type = 'HASH',
        unique = true,
        if_not_exists = true,
        parts = {{ field = 'email', type = 'string', collation = 'unicode_ci' }}
    })

    box.commit()

    return space
end

local function start_worker(has_job)
    while true do
        local space = get_space()

        for _, email in get_space():pairs() do
            print(email)
            space:delete(email)
        end

        has_job:wait()
    end
end

local has_job = fiber.cond()

fiber.create(start_worker, has_job)

local function process(user_info)
    local space = get_space()
    space:insert({ user_info.email })
    has_job:signal()
end

return {
    process = process
}