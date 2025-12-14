addon.name      = 'nomacrobars';
addon.author    = 'jquick';
addon.version   = '1.0';
addon.desc      = 'Disables macro bar display when holding ctrl or alt.';

require('common');
local chat = require('chat');

local nomacrobars = {
    ptrs = {},
};

ashita.events.register('load', 'load_cb', function ()
    local patched = 0;
    
    -- Signatures for the timer checks that control the macro bars
    -- Patch: sub eax,[esi+10] -> xor eax,eax; nop  (Forces timer difference to 0)
    local patterns = {
        { name = 'Ctrl Timer', pattern = '2B46103BC30F82', patch = { 0x31, 0xC0, 0x90 } },
        { name = 'Alt Timer',  pattern = '2B46103BC37273', patch = { 0x31, 0xC0, 0x90 } },
    };
    
    -- Apply patches
    for _, p in ipairs(patterns) do
        local addr = ashita.memory.find('FFXiMain.dll', 0, p.pattern, 0, 0);
        
        if (addr ~= 0) then
            -- Backup and patch
            local backup = ashita.memory.read_array(addr, #p.patch);
            ashita.memory.write_array(addr, p.patch);
            
            -- Store for restoration
            table.insert(nomacrobars.ptrs, { addr = addr, backup = backup });
            patched = patched + 1;
            
            print(chat.header(addon.name):append(chat.message(string.format('Disabled %s at 0x%08X', p.name, addr))));
        else
            print(chat.header(addon.name):append(chat.error(string.format('Failed to find pattern for %s', p.name))));
        end
    end
    
    if (patched == #patterns) then
        print(chat.header(addon.name):append(chat.success('Macro bars disabled successfully.')));
    end
end);

ashita.events.register('unload', 'unload_cb', function ()
    -- Restore patches to the original bytes
    for _, v in ipairs(nomacrobars.ptrs) do
        if (v.backup ~= nil and #v.backup > 0) then
            ashita.memory.write_array(v.addr, v.backup);
        end
    end
end);
