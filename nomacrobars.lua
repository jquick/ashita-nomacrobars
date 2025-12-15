addon.name      = 'nomacrobars';
addon.author    = 'jquick';
addon.version   = '1.3';
addon.desc      = 'Disables macro bar display. (not compatible with macrofix)';

require('common');
local chat = require('chat');

local nomacrobars = {
    ptrs = {},
};

ashita.events.register('load', 'load_cb', function ()
    local patched = 0;
    
    local patterns = {
        { name = 'Ctrl Timer', pattern = '2B46103BC3????????????68????????B9', off = 0x03, cnt = 0, patch = { 0xF9, 0x90 } },
        { name = 'Alt Timer',  pattern = '2B46103BC3????68????????B9',           off = 0x03, cnt = 0, patch = { 0xF9, 0x90 } },
    };

    for _, p in ipairs(patterns) do
        local scan_ptr = ashita.memory.find('FFXiMain.dll', 0, p.pattern, 0, p.cnt);
        
        if (scan_ptr ~= 0) then
            local patch_addr = scan_ptr + p.off;
            
            local backup = ashita.memory.read_array(patch_addr, #p.patch);
            ashita.memory.write_array(patch_addr, p.patch);
            
            table.insert(nomacrobars.ptrs, { addr = patch_addr, backup = backup });
            patched = patched + 1;
            
            print(chat.header(addon.name):append(chat.message(string.format('Patched %s at 0x%08X', p.name, patch_addr))));
        else
            print(chat.header(addon.name):append(chat.warning(string.format('Pattern not found: %s', p.name))));
        end
    end
    
    if (patched > 0) then
        print(chat.header(addon.name):append(chat.success(string.format('Successfully patched %d locations.', patched))));
    else
        print(chat.header(addon.name):append(chat.error('Failed to find any patterns.')));
    end
end);

ashita.events.register('unload', 'unload_cb', function ()
    for _, v in ipairs(nomacrobars.ptrs) do
        if (v.backup ~= nil and #v.backup > 0) then
            ashita.memory.write_array(v.addr, v.backup);
        end
    end
end);
