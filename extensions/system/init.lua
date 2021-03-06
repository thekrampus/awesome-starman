------------------------------------------------------------
--- system monitoring tools
--
-- @author Krampus &lt;tetramor.ph&gt;
-- @module system
------------------------------------------------------------

-- patch package.path to load this package
local my_path = debug.getinfo(1).short_src:match('(.*/)')
local old_path = package.path
package.path = package.path .. ';' .. my_path .. "?.lua"

local system = {}
system.monitor = require('monitor')
system.core_temp = require('core_temp')
system.cpu_usage = require('cpu_usage')
system.mem_usage = require('mem_usage')
system.disk_usage = require('disk_usage')

package.path = old_path

return system
