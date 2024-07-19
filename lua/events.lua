local json = require("json")
local ao = require('ao')

Events = Events or {}
EventNum = EventNum or 0

Handlers.add(
    "Add",
    Handlers.utils.hasMatchingTag("Action", "Add"),
    function(msg)
        local id = EventNum + 1
        assert(type(msg.title) == 'string', 'title is required!')
        assert(type(msg.info) == 'string', 'info is required!')
        local date = tonumber(msg.date)
        assert(date and date > 0, 'date must be greater than 0')
        assert(not Events[id], 'event exists!')

        local event      = {
            title = msg.title,
            info = msg.info,
            id = id,
            date = tonumber(msg.date)
        }

        Events[event.id] = event
        EventNum         = EventNum + 1
        Handlers.utils.reply("event added!")(msg)
    end
)

Handlers.add(
    "List",
    Handlers.utils.hasMatchingTag("Action", "List"),
    function(msg)
        local arr = {}
        for _, event in pairs(Events) do
            table.insert(arr, event)
        end

        local order = msg.order or "desc"
        local limit = msg.limit or #arr
        local skip = msg.skip or 0

        table.sort(arr, function(a, b)
            if order == "asc" then
                return a.date < b.date
            else
                return a.date > b.date
            end
        end)

        local start = skip + 1
        local finish = start + limit - 1
        finish = math.min(finish, #arr)

        local slicedArr = {}
        for i = start, finish do
            table.insert(slicedArr, arr[i])
        end
        local isNext = (finish < #arr) and "true" or "false"
        ao.send({
            Target = msg.From,
            Events = json.encode(slicedArr),
            Count  = tostring(#arr),
            Next   = isNext
        })
    end
)
