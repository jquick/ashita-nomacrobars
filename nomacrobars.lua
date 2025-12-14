--[[
* nomacrobars
* Disables macro bar display by patching the timer calculation logic.
--]]

addon.name      = 'nomacrobars';
addon.author    = 'jquick';
addon.version   = '1.3';
addon.desc      = 'Disables macro bar display. (not compatible with macrofix)';

require('common');
local chat = require('chat');

local nomacrobars = {
    ptrs = {},
};

--[[
* event: load
* desc : Event called when the addon is being loaded.
--]]
ashita.events.register('load', 'load_cb', function ()
    local patched = 0;
    
    -- We patch the specific subtraction instruction (sub eax,[esi+10]) to be (xor eax,eax; nop)
    -- This forces the timer difference to be 0, preventing the macro bar from showing.
    local patterns = {
        -- Pattern for Ctrl Timer
        { name = 'Ctrl Timer', pattern = '2B46103BC3????????????68????????B9', off = 0x00, cnt = 0, patch = { 0x31, 0xC0, 0x90 } },
        
        -- Pattern for Alt Timer
        { name = 'Alt Timer',  pattern = '2B46103BC3????68????????B9',           off = 0x00, cnt = 0, patch = { 0x31, 0xC0, 0x90 } },
    };

    -- Apply patches
    for _, p in ipairs(patterns) do
        -- Find the pattern address
        local scan_ptr = ashita.memory.find('FFXiMain.dll', 0, p.pattern, 0, p.cnt);
        
        if (scan_ptr ~= 0) then
            -- Calculate the actual patch address using the offset
            local patch_addr = scan_ptr + p.off;
            
            -- Backup and patch
            local backup = ashita.memory.read_array(patch_addr, #p.patch);
            ashita.memory.write_array(patch_addr, p.patch);
            
            -- Store for restoration
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

--[[
* event: unload
* desc : Event called when the addon is being unloaded.
--]]
ashita.events.register('unload', 'unload_cb', function ()
    -- Restore patches to the original bytes
    for _, v in ipairs(nomacrobars.ptrs) do
        if (v.backup ~= nil and #v.backup > 0) then
            ashita.memory.write_array(v.addr, v.backup);
        end
    end
end);
